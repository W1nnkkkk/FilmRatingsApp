package config

import (
	"fmt"
	"log"

	"github.com/BurntSushi/toml"
)

type Config struct {
	Server struct {
		Port int    `toml:"portServer"`
		Host string `toml:"hostServer"`
	}
	Database struct {
		Host       string `toml:"hostDB"`
		Port       int    `toml:"portDB"`
		Database   string `toml:"database"`
		Collection string `toml:"collection"`
	}
	Logger struct {
		LogPath string `toml:"logPath"`
	}
}

func ConfigInit() (Config, error) {
	var conf Config

	if _, err := toml.DecodeFile("./config/data.toml", &conf); err != nil {
		log.Default().Println("Ошибка считывания конфига")
		fmt.Println(err)
		return Config{}, err
	}

	return conf, nil
}

func (c *Config) GetLogPath() string {
	return c.Logger.LogPath
}
