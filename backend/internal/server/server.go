// Package server AI Pronunciation Coach API ning HTTP qatlamini ulaydi.
//
// Bu paketda biznes mantiq bo'lmaydi — u faqat marshrutlarni tegishli
// handlerlarga bog'laydi.
package server

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/auth"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/user"
)

// Deps router qurish uchun zarur bog'liqliklar.
type Deps struct {
	// Users `nil` bo'lsa autentifikatsiya yo'llari ro'yxatdan o'tmaydi.
	// Bu health endpoint'ini bazasiz test qilish imkonini beradi.
	Users  *user.Handler
	Tokens *auth.TokenIssuer
}

// NewRouter mavjud yo'llar bilan Gin engine quradi.
func NewRouter(deps Deps) *gin.Engine {
	r := gin.New()
	r.Use(gin.Logger(), gin.Recovery())

	r.GET("/health", health)

	if deps.Users != nil && deps.Tokens != nil {
		deps.Users.Register(r, deps.Tokens)
	}

	return r
}

// health jarayon ishlayotganini va so'rovlarga javob berayotganini bildiradi.
func health(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
