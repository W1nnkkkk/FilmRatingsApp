package main

import (
	"log"

	"github.com/W1nnkkkk/FilmRatingsApp.git/config"
	"github.com/W1nnkkkk/FilmRatingsApp.git/internal/app/apiserver"
)

func main() {
	conf, err := config.ConfigInit()
	if err != nil {
		log.Default().Println("Ошибка конфигурации БД")
		log.Default().Println(err)
		return
	}

	apiserver.Start(conf)
}
