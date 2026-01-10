package controllers

import (
	"net/http"

	// "github.com/jamessouth/clean-tablet/go/db"
	"github.com/jamessouth/clean-tablet/go/middleware"
)

// wraps mw handler that wraps db pool
type DBHandler struct {
	middleware.Handler
}

// User represents the user data that will be sent to the client
type User struct {
	Username       string `json:"username"`
	Email          string `json:"email"`
	FirstName      string `json:"first_name"`
	LastName       string `json:"last_name"`
	LoginStreak    int32  `json:"login_streak"`
	CreatedAt      string `json:"created_at"`
	NumClasses     int    `json:"numClasses"`
	CardsStudied   int    `json:"cardsStudied"`
	TotalCardViews any    `json:"totalCardViews"`
	TotalScore     any    `json:"totalScore"`
}

type Class struct {
	ID               int32
	ClassName        string
	ClassDescription string
	CreatedAt        string
	UpdatedAt        string
	Role             string
}

type FlashcardSet struct {
	ID             int32
	SetName        string
	SetDescription string
	CreatedAt      string
	UpdatedAt      string
	Role           string
}

// LoginRequest represents the login request body
type LoginRequest struct {
	Id int32
	// Email    string
	// Password string
}

// SignupRequest represents the signup request body
type SignupRequest struct {
	Username  string
	Email     string
	Password  string
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
}

// AuthReply is the login reply
type AuthReply struct {
	Success bool  `json:"success"`
	UserID  int32 `json:"userID"`
}

// var errContext error = errors.New("error retrieving from context")
// var errHeader error = errors.New("error retrieving from headers")

// const (
// 	back              string = "back"
// 	card_id           string = "card_id"
// 	class_description string = "class_description"
// 	class_id          string = "class_id"
// 	class_name        string = "class_name"
// 	correct           string = "correct"
// 	email             string = "email"
// 	first_name        string = "first_name"
// 	front             string = "front"
// 	id                string = "id"
// 	incorrect         string = "incorrect"
// 	last_name         string = "last_name"
// 	owner             string = "owner"
// 	password          string = "password"
// 	roleStr           string = "role"
// 	set_description   string = "set_description"
// 	set_id            string = "set_id"
// 	set_name          string = "set_name"
// 	student_id        string = "student_id"
// 	teacher           string = "teacher"
// 	username          string = "username"
// 	token             string = "token"
// )

func logAndSendError(w http.ResponseWriter, err error, msg string, statusCode int) {
	middleware.LogAndSendError(w, err, msg, statusCode)
}

// func getInt32Id(val string) (id int32, err error) {
// 	return middleware.GetInt32Id(val)
// }

// func getHeaderVals(r *http.Request, headers ...string) (map[string]string, error) {
// 	return middleware.GetHeaderVals(r, headers...)
// }

// func getQueryConnAndContext(r *http.Request, h *DBHandler) (query *db.Queries, ctx context.Context, conn *pgxpool.Conn, err error) {
// 	ctx = r.Context()

// 	conn, err = h.DB.Acquire(ctx)
// 	if err != nil {
// 		return nil, nil, nil, err
// 	}

// 	query = db.New(conn)

// 	return
// }

// keygen:
// key := make([]byte, num)
// rand.Read(key)
// dst := make([]byte, base64.StdEncoding.EncodedLen(len(key)))
// base64.StdEncoding.Encode(dst, key)
// fmt.Println(string(dst))

// k := paseto.NewV4SymmetricKey()
// fmt.Println(k.ExportHex())
// https://go.dev/play/p/bClzAlvZnnq

// package main

// import (
// 	"crypto/rand"
// 	"crypto/sha256"
// 	"encoding/hex"
// 	"fmt"
// 	"log"
// )

// // GenerateMagicToken creates a raw token for the email and a hash for the DB
// func GenerateMagicToken() (rawToken string, tokenHash string, err error) {
// 	// 1. Generate 32 bytes of high-entropy randomness
// 	b := make([]byte, 32)
// 	if _, err := rand.Read(b); err != nil {
// 		return "", "", err
// 	}

// 	// 2. Convert to a hex string (this is what the user gets in the email)
// 	rawToken = hex.EncodeToString(b)

// 	// 3. Create a SHA-256 hash of the raw token (this is what goes in the DB)
// 	hash := sha256.Sum256([]byte(rawToken))
// 	tokenHash = hex.EncodeToString(hash[:])

// 	return rawToken, tokenHash, nil
// }

// func main() {
// 	raw, hash, _ := GenerateMagicToken()

// 	fmt.Printf("📧 SEND TO USER (Raw): %s\n", raw)
// 	fmt.Printf("🗄️  STORE IN DB (Hash): %s\n", hash)
// }

// When the user clicks the link, your Go backend will receive the rawToken. You must hash it again to find the match in your database.

// func VerifyToken(providedRawToken string) {
//     // 1. Hash the token provided by the user's click
//     hashBytes := sha256.Sum256([]byte(providedRawToken))
//     providedHash := hex.EncodeToString(hashBytes[:])

//     // 2. Query the database
//     // SELECT player_id FROM auth_tokens WHERE token_hash = $1 AND expires_at > NOW()
//     // (If a row exists, the user is logged in!)
// }
