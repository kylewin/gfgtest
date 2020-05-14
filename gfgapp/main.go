package main

import (
	"database/sql"
	"fmt"
	_ "github.com/lib/pq"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", Hello)
	http.HandleFunc("/getdata", GetData)
	fmt.Println("Starting web server...")
	http.ListenAndServe(":80", nil)
}

func Hello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "App is working")
}

func GetData(w http.ResponseWriter, r *http.Request) {
	var (
		host     = os.Getenv("GFGAPP_DB_HOST")
		password = os.Getenv("GFGAPP_DB_PASSWORD")
	)

	// init conn string
	psqlInfo := fmt.Sprintf("host=%s port=5432 user=gfg password=%s dbname=gfgdb sslmode=disable", host, password)

	// open connection to db
	fmt.Println("Connecting to Postgres...\n")
	fmt.Println("Connstr: %s", psqlInfo)
	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		panic(err)
	}
	defer db.Close()
	fmt.Fprintf(w, "Connected !\n")

	// Create a table in database gfgdb
	_, err = db.Query(`CREATE TABLE IF NOT EXISTS dummycontent(id serial PRIMARY KEY, content VARCHAR (50) NOT NULL)`)
	if err != nil {
		panic(err)
	}

	// Insert data to the table
	_, err = db.Query(`INSERT INTO dummycontent(content) VALUES('This is the content from Postgres')`)
	if err != nil {
		panic(err)
	}

	// fetch data from the table
	rows, err := db.Query(`SELECT content FROM dummycontent`)
	if err != nil {
		panic(err)
	}
	for rows.Next() {
		var content string
		if e := rows.Scan(&content); e != nil {
		}
		fmt.Fprintf(w, content+"\n")
	}
}
