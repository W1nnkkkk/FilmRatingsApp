package logger

import (
	"fmt"
	"os"
	"time"
)

type Logger struct {
	LogPath string
}

func (l *Logger) LogErrToFile(err error) {
	currentTime := time.Now()

	errorMessage := fmt.Sprintf("%s ERROR %v\n", currentTime.Format("2006-01-02 15:04:05"), err)

	file, err := os.OpenFile(l.LogPath, os.O_RDWR|os.O_CREATE|os.O_APPEND, 0644)
	if err != nil {
		fmt.Println("Ошибка открытия файла:", err)
		return
	}
	defer file.Close()

	_, err = file.WriteString(errorMessage)
	if err != nil {
		fmt.Println("Ошибка записи в файл:", err)
		return
	}
}
