package store

import (
	"context"
	"errors"
	"fmt"

	"github.com/W1nnkkkk/FilmRatingsApp.git/internal/app/logger"
	"github.com/W1nnkkkk/FilmRatingsApp.git/internal/app/model"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Store struct {
	client     *mongo.Client
	collection *mongo.Collection
	Logger     logger.Logger
}

func InitStore(host, database, collection string, port int, path string) (Store, error) {
	var store Store
	store.Logger = logger.Logger{path}
	client, err := mongo.Connect(context.TODO(), options.Client().ApplyURI(host+fmt.Sprint(port)))
	if err != nil {
		store.Logger.LogErrToFile(err)
		return store, err
	}
	store.client = client
	store.collection = store.client.Database(database).Collection(collection)

	return store, nil
}

func (s *Store) FindMovie(filter bson.D) ([]model.Movie, error) {
    results := []model.Movie{}

    cur, err := s.collection.Find(context.TODO(), filter)
    if err != nil {
        s.Logger.LogErrToFile(err)
        return nil, err
    }
    defer cur.Close(context.TODO())

    for cur.Next(context.TODO()) {
        var result model.Movie
        if err := cur.Decode(&result); err != nil {
            s.Logger.LogErrToFile(err)
            return nil, err
        }

		if imageBinary, ok := result.Image.(primitive.Binary); ok {
            result.Image = imageBinary.Data
        } else {
            s.Logger.LogErrToFile(fmt.Errorf("Ошибка при извлечении данных изображения: %v", result.Image))
        }



        results = append(results, result)
    }

    if err := cur.Err(); err != nil {
        s.Logger.LogErrToFile(err)
        return nil, err
    }

    return results, nil
}


func (s *Store) FindReview(filter bson.D) ([]model.Review, error) {
	type ReviewResponse struct {
		Review []model.Review `bson:"review"`
	}
	var reviewResponse ReviewResponse
	cur, err := s.collection.Find(context.TODO(), filter)
	if err != nil {
		s.Logger.LogErrToFile(err)
		return nil, err
	}
	defer cur.Close(context.TODO())

	if cur.Next(context.TODO()) {
		if err := cur.Decode(&reviewResponse); err != nil {
			s.Logger.LogErrToFile(err)
			return nil, err
		}
	} else if err := cur.Err(); err != nil {
		s.Logger.LogErrToFile(err)
		return nil, err
	}

	return reviewResponse.Review, nil
}

func (s *Store) UpdateData(filter bson.D, update bson.M) error {

	//{filter} { $push: { 'review': { "name": "Кирилл", "comment": "Хороший фильм топчик чуваува" } } }

	res, err := s.collection.UpdateOne(context.TODO(), filter, bson.M{"$push": update})
	if err != nil {
		s.Logger.LogErrToFile(err)
		return err
	}

	if res.MatchedCount == 0 {
		s.Logger.LogErrToFile(err)
		return errors.New("Film not find")
	}

	return nil
}
