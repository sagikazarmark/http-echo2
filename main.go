package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	router := http.NewServeMux()

	hello := os.Getenv("HELLO")
	if hello == "" {
		hello = "[unknown]"
	}

	router.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello %s!", hello)
	})

	err := http.ListenAndServe(":8080", router)
	if err != nil && err != http.ErrServerClosed {
		panic(err)
	}
}
