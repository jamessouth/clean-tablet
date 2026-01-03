package routes

import (
	"github.com/go-chi/chi/v5"
	"github.com/jamessouth/clean-tablet/go/controllers"
)

// every protected route is preceded by /api
func Protected(r *chi.Mux, h *controllers.DBHandler) {

}

// auth
func Unprotected(r *chi.Mux, h *controllers.DBHandler) {
	r.Post("/login", h.Login)
	// r.Post("/signup", h.Signup)
	// r.Post("/send-reset-password-token", h.SendResetPasswordToken)
	// r.Post("/reset-password", h.ResetPassword)
}
