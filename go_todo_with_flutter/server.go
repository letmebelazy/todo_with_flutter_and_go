package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

const port = ":5500"

type Todo struct {
	Index string `json:"index"`
	Task  string `json:"task"`
	Name  string `json:"name"`
}

var TodoList []Todo = []Todo{
	{Index: "0", Name: "J", Task: "Make money"},
}

func main() {

	router := mux.NewRouter()
	router.HandleFunc("/", getRootPage)
	router.HandleFunc("/todos/{index}", getTodoByIndex).Methods("GET")
	router.HandleFunc("/todos", getAllTodos).Methods("GET")
	router.HandleFunc("/todos", createNewTodo).Methods("POST")
	router.HandleFunc("/todos/{index}", deleteTodo).Methods("DELETE")
	router.HandleFunc("/todos/{index}", updateTodo).Methods("PATCH")

	fmt.Println("Serving at http://127.0.0.1" + port)
	fmt.Println(TodoList)
	log.Fatal(http.ListenAndServe(port, router))
}

func getRootPage(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("This is root page."))
	fmt.Println("rootpage")
}

func getAllTodos(w http.ResponseWriter, r *http.Request) {
	fmt.Println("get all")
	fmt.Println(TodoList)
	json.NewEncoder(w).Encode(TodoList)
}

func getTodoByIndex(w http.ResponseWriter, r *http.Request) {
	fmt.Println("get by one")
	vars := mux.Vars(r)
	index := vars["index"]

	for _, todo := range TodoList {
		if todo.Index == index {
			json.NewEncoder(w).Encode(todo)
		}
	}
}

func createNewTodo(w http.ResponseWriter, r *http.Request) {
	fmt.Println("create")
	var todo Todo
	err := json.NewDecoder(r.Body).Decode(&todo)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	todo.Index = strconv.Itoa(len(TodoList))
	fmt.Println(todo.Index)
	TodoList = append(TodoList, todo)
	fmt.Println(TodoList)
	w.WriteHeader(http.StatusCreated)
}

func deleteTodo(w http.ResponseWriter, r *http.Request) {
	fmt.Println(TodoList)
	fmt.Println("delete")
	vars := mux.Vars(r)
	index, _ := vars["index"]

	for i, todo := range TodoList {
		if todo.Index == index {
			TodoList = append(TodoList[:i], TodoList[i+1:]...)
		}
	}
	w.WriteHeader(http.StatusOK)
}

func updateTodo(w http.ResponseWriter, r *http.Request) {
	fmt.Println(TodoList)
	fmt.Println("patch")
	vars := mux.Vars(r)
	index := vars["index"]
	var updatedTodo Todo

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		w.Write([]byte(err.Error()))
	}
	fmt.Println(reqBody, r.Body, "//", vars["name"], "//", vars)
	json.Unmarshal(reqBody, &updatedTodo)

	fmt.Println(updatedTodo)
	for i, todo := range TodoList {
		if todo.Index == index {
			todo.Task = updatedTodo.Task
			todo.Name = updatedTodo.Name
			TodoList = append(TodoList[:i], todo)
			json.NewEncoder(w).Encode(todo)
		}
	}
}
