package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
)

func main() {
	router := chi.NewRouter()

	hello := os.Getenv("HELLO")
	if hello == "" {
		hello = "[unknown]"
	}

	router.Get("/hello", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello %s!", hello)
	})

	router.Get("/env", func(w http.ResponseWriter, r *http.Request) {
		for _, env := range os.Environ() {
			fmt.Fprintln(w, env)
		}
	})

	router.Get("/env/{key}", func(w http.ResponseWriter, r *http.Request) {
		key := chi.URLParam(r, "key")

		value, ok := os.LookupEnv(key)
		if ok {
			fmt.Fprint(w, value)
		}
	})

	err := http.ListenAndServe(":8080", router)
	if err != nil && err != http.ErrServerClosed {
		panic(err)
	}
}
