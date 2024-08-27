package apiserver

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"

	backReader "github.com/W1nnkkkk/FileBackReader"
	"github.com/W1nnkkkk/FilmRatingsApp.git/config"
	"github.com/W1nnkkkk/FilmRatingsApp.git/internal/app/store"
	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Server struct {
	router     mux.Router
	store      store.Store
	pathImages string
}

func Start(config config.Config) error {
	store, err := store.InitStore(config.Database.Host, config.Database.Database, config.Database.Collection,
		config.Database.Port, config.GetLogPath())
	if err != nil {
		store.Logger.LogErrToFile(err)
		return err
	}

	server := newServer(store, config)
	return http.ListenAndServe(config.Server.Host+fmt.Sprint(config.Server.Port), &server)
}

func newServer(store store.Store, conf config.Config) Server {
	s := Server{
		router: *mux.NewRouter(),
		store:  store,
		pathImages: conf.Images.ImagePath,
	}

	s.configureRouter()

	return s
}

func (s *Server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.router.ServeHTTP(w, r)
}

func (s *Server) configureRouter() {
	s.router.HandleFunc("/movie/find", s.handleMovieFind()).Methods("GET")
	s.router.HandleFunc("/movie/review/find", s.handleReviewFind()).Methods("GET")
	s.router.HandleFunc("/movie/review/create", s.handleReviewCreate()).Methods("POST")
	s.router.HandleFunc("/logs", s.handleGetLogs()).Methods("GET")
	s.router.HandleFunc("/upload", s.handleCreateImage()).Methods("POST")
	s.router.HandleFunc("/image/{filename}", s.handleGetImage()).Methods("GET")
}

func (s *Server) handleMovieFind() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		filter := bson.D{}
		for key, values := range r.URL.Query() {
			if strings.Contains(key, "[") {
				parts := strings.Split(key, "[")
				//fieldName := parts[0]
				fieldName := parts[1][:len(parts[1])-1]

				arrayFilter := bson.D{{Key: "$regex", Value: ""}, {"$options", "i"}}
				for _, value := range values {
					re, err := regexp.Compile(value)
					if err != nil {
						s.store.Logger.LogErrToFile(err)
					}
					arrayFilter = append(arrayFilter, bson.E{Key: "$regex", Value: re.String()})
				}

				filter = append(filter, bson.E{Key: fieldName,
					Value: bson.D{{Key: "$elemMatch", Value: arrayFilter}}})
			} else {
				filter = append(filter, bson.E{Key: key, Value: bson.D{
					{"$regex", values[0]},
					{"$options", "i"},
				}})
			}
		}

		movie, err := s.store.FindMovie(filter)
		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusNotFound, err)
			return
		}

		s.respond(w, r, http.StatusOK, movie)
	}
}

func (s *Server) handleReviewCreate() http.HandlerFunc {
	type updateData struct {
		UpdateData bson.M `json:"update"`
		Filter     bson.D `json:"filter"`
	}

	type updateDataJSON struct {
		Update map[string]interface{} `json:"update"`
		Filter map[string]interface{} `json:"filter"`
	}

	return func(w http.ResponseWriter, r *http.Request) {
		upd := &updateData{}

		body, err := io.ReadAll(r.Body)
		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusBadRequest, err)
			return
		}

		updTemp := updateDataJSON{}
		err = json.Unmarshal(body, &updTemp)
		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusBadRequest, err)
			return
		}

		upd.UpdateData = bson.M(updTemp.Update)

		id, err := primitive.ObjectIDFromHex(updTemp.Filter["_id"].(string))
		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusBadRequest, err)
			return
		}
		upd.Filter = bson.D{{Key: "_id", Value: id}}

		err = s.store.UpdateData(upd.Filter, upd.UpdateData)
		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusBadGateway, err)
			return
		}

		review, _ := s.store.FindReview(upd.Filter)

		s.respond(w, r, http.StatusOK, review)
	}
}

func (s *Server) handleReviewFind() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		filter := bson.D{}
		for key, values := range r.URL.Query() {
			id, _ := primitive.ObjectIDFromHex(values[0])
			filter = append(filter, bson.E{Key: key, Value: id})
		}

		review, err := s.store.FindReview(filter)
		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusNotFound, err)
			return
		}

		s.respond(w, r, http.StatusOK, review)
	}
}

func (s *Server) handleGetLogs() http.HandlerFunc {
	type Log struct {
		Date string `json:"date"`
		Time string `json:"time"`
		Text string `json:"text"`
	}

	return func(w http.ResponseWriter, r *http.Request) {
		countRows, err := strconv.Atoi(r.URL.Query().Get("count"))
		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusBadGateway, err)
			return
		}

		logsStringArr, err := backReader.ReadFromEndFile(s.store.Logger.LogPath, countRows)

		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusBadGateway, err)
			return
		}

		logs := []Log{}

		for i := 0; i < len(logsStringArr); i++ {
			data := strings.Split(logsStringArr[i], " ")
			msg := ""
			date := data[0]
			time := data[1]
			for j := 2; j < len(data); j++ {
				msg += data[j] + " "
			}

			logs = append(logs, Log{Date: date, Time: time, Text: msg})
		}

		s.respond(w, r, http.StatusOK, logs)
	}
}

func (s *Server) handleCreateImage() http.HandlerFunc {
	type Data struct {
		Image    []byte `json: "image"`
		FileName string `json: "filename"`
	}

	return func(w http.ResponseWriter, r *http.Request) {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusBadRequest, err)
			return
		}

		newFile := Data{}
		var data map[string]interface{}
		if err := json.Unmarshal(body, &data); err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusBadRequest, err)
			return
		}

		newFile.FileName = data["filename"].(string)
		if(strings.Contains(newFile.FileName, " ")) {
			newFile.FileName = strings.Replace(newFile.FileName, " ", "", len(newFile.FileName))
		}
		newFile.Image, err = base64.StdEncoding.DecodeString(data["image"].(string))
		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusInternalServerError, err)
			return
		}

		out, err := os.Create(s.pathImages + newFile.FileName + ".jpg")
		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusInternalServerError, err)
			return
		}

		_, err = out.Write(newFile.Image)
		if err != nil {
			s.store.Logger.LogErrToFile(err)
			s.error(w, r, http.StatusInternalServerError, err)
			return
		}

		s.respond(w, r, http.StatusOK, "Картинка загружена")
	}
}

func (s *Server) handleGetImage() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        vars := mux.Vars(r)
        filename := vars["filename"]

        filePath := s.pathImages + filename

        w.Header().Set("Access-Control-Allow-Origin", "*")

        file, err := os.Open(filePath)
        if err != nil {
            s.store.Logger.LogErrToFile(fmt.Errorf("Ошибка в открытии файла"))
			s.error(w, r, http.StatusInternalServerError, err)
            return
        }
        defer file.Close()

        contentType := "image/jpeg" 
        w.Header().Set("Content-Type", contentType)

        http.ServeContent(w, r, filename, time.Now(), file)
    }
}


func (s *Server) error(w http.ResponseWriter, r *http.Request, code int, err error) {
	s.respond(w, r, code, map[string]string{"error": err.Error()})
}

func (s *Server) respond(w http.ResponseWriter, r *http.Request, code int, data interface{}) {
	w.WriteHeader(code)
	if data != nil {
		json.NewEncoder(w).Encode(data)
	}
}
