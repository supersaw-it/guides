package main

import (
	"fmt"
	"log"

	"github.com/gocql/gocql"
)

func main() {
	// Connect to the Scylla cluster
	cluster := gocql.NewCluster("127.0.0.1") // Replace with your Scylla service IP or DNS
	// cluster.Port = 9042

	// cluster.ProtoVersion = 4 // Protocol version 4 as an example.
	// cluster.DisableInitialHostLookup = true
	// cluster.Timeout = time.Duration(10) * time.Second // Example for 10 seconds
	cluster.Consistency = gocql.Quorum

	// Create a new session without specifying a keyspace
	initialSession, err := cluster.CreateSession()
	if err != nil {
		log.Fatalf("Failed to connect to Scylla: %v", err)
	}
	defer initialSession.Close()

	// Create a keyspace
	err = initialSession.Query(`
		CREATE KEYSPACE IF NOT EXISTS testkeyspace WITH REPLICATION = {
			'class' : 'SimpleStrategy',
			'replication_factor' : 1
		};
	`).Exec()
	if err != nil {
		log.Fatalf("Failed to create keyspace: %v", err)
	}

	// Set the keyspace to the newly created keyspace
	cluster.Keyspace = "testkeyspace"

	// Create a new session with the specified keyspace
	session, err := cluster.CreateSession()
	if err != nil {
		log.Fatalf("Failed to connect to Scylla: %v", err)
	}
	defer session.Close()

	// Create a table
	err = session.Query(`
		CREATE TABLE IF NOT EXISTS users (
			user_id UUID,
			username TEXT,
			email TEXT,
			PRIMARY KEY (user_id)
		);
	`).Exec()
	if err != nil {
		log.Fatalf("Failed to create table: %v", err)
	}

	// Insert a record
	if err := session.Query(`INSERT INTO users (user_id, username, email) VALUES (?, ?, ?)`,
		gocql.TimeUUID(), "john_doe", "john.doe@example.com").Exec(); err != nil {
		log.Fatal(err)
	}

	// Query the database
	var userID gocql.UUID
	var username string
	var email string

	iter := session.Query(`SELECT user_id, username, email FROM users`).Iter()
	for iter.Scan(&userID, &username, &email) {
		fmt.Println("User:", userID, username, email)

		// Delete the record after printing it
		if err := session.Query(`DELETE FROM users WHERE user_id = ?`, userID).Exec(); err != nil {
			log.Fatalf("Failed to delete user: %v", err)
		} else {
			fmt.Printf("User with ID %v successfully deleted\n", userID)
		}
	}

	if err := iter.Close(); err != nil {
		log.Fatal(err)
	}
}
