package model

type Movie struct {
	Id           interface{} `bson:"_id"`
	Image        interface{} `bson:"image"`
	Name         interface{} `bson:"name" bsonindex:"text"`
	OriginalName interface{} `bson:"originalName" bsonindex:"text"`
	Year         interface{} `bson:"year"`
	ReleaseDate  interface{} `bson:"releaseDate"`
	Country      interface{} `bson:"country"`
	Director     interface{} `bson:"director" bsonindex:"text"`
	Duration     interface{} `bson:"duration"`
	Genre        interface{} `bson:"genre" bsonindex:"text"`
	Starring     interface{} `bson:"starring" bsonindex:"text"`
}

type Review struct {
	Name    interface{} `bson:"name"`
	Comment interface{} `bson:"comment"`
}
