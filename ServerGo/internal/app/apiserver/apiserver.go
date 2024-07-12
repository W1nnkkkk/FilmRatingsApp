package apiserver

import (
	"encoding/json"
	"io"
	"net/http"
	"regexp"
	"strings"

	"github.com/W1nnkkkk/FilmRatingsApp.git/config"
	"github.com/W1nnkkkk/FilmRatingsApp.git/internal/app/store"
	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Server struct {
	router mux.Router
	store  store.Store
}

func Start(config config.Config) error {
	store, err := store.InitStore(config.Database.Host, config.Database.Database, config.Database.Collection,
		config.Database.Port, config.GetLogPath())
	if err != nil {
		store.Logger.LogErrToFile(err)
		return err
	}

	server := newServer(store)
	return http.ListenAndServe("localhost:7172", &server)
}

func newServer(store store.Store) Server {
	s := Server{
		router: *mux.NewRouter(),
		store:  store,
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

func (s *Server) error(w http.ResponseWriter, r *http.Request, code int, err error) {
	s.respond(w, r, code, map[string]string{"error": err.Error()})
}

func (s *Server) respond(w http.ResponseWriter, r *http.Request, code int, data interface{}) {
	w.WriteHeader(code)
	if data != nil {
		json.NewEncoder(w).Encode(data)
	}
}
