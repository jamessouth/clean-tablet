package utils

import (
	"log"
	"math/rand"
	"time"

	"github.com/gorilla/websocket"
	"github.com/jamessouth/blank-slate/src/server/structs"
)

// GetPlayers loops through the clients map and extracts the names
func GetPlayers(m map[*websocket.Conn]structs.Player) []structs.Player {
	var list []structs.Player
	for _, v := range m {
		list = append(list, v)
	}
	return list
}

// NameCheck checks for duplicate names entered by users
func NameCheck(s string, names []string) bool {
	for _, n := range names {
		if n == s {
			return true
		}
	}
	return false
}

// StringList type to hold shuffle method
type StringList []string

// ShuffleList method shuffles a list of strings
func (l StringList) ShuffleList() []string {
	t := time.Now().UnixNano()
	rand.Seed(t)

	rand.Shuffle(len(l), func(i, j int) {
		l[i], l[j] = l[j], l[i]
	})
	return l
}

func forEach(s []*websocket.Conn, clients map[*websocket.Conn]structs.Player, n int) {
	for _, v := range s {
		clients[v] = clients[v].UpdateScore(n)
	}
}

// ScoreAnswers updates every player's score each round
func ScoreAnswers(answers map[string][]*websocket.Conn, clients map[*websocket.Conn]structs.Player) {
	for _, v := range answers {
		log.Println(v)
		if len(v) > 2 {
			forEach(v, clients, 1)
		} else if len(v) == 2 {
			forEach(v, clients, 3)
		}
	}
}

func CheckForWin(clients map[*websocket.Conn]structs.Player) {
	for _, v := range clients {
		log.Println(v)
	}
	// return
}
