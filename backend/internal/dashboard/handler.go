package dashboard

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/auth"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/httperr"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/profile"
)

// Handler bosh ekran endpointi.
type Handler struct {
	service *Service
}

// NewHandler yangi handler yaratadi.
func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// Register bosh ekran yo'lini ro'yxatdan o'tkazadi.
func (h *Handler) Register(r gin.IRouter, tokens *auth.TokenIssuer) {
	r.GET("/api/v1/dashboard", auth.Middleware(tokens), h.get)
}

type response struct {
	Success bool `json:"success"`
	Data    data `json:"data"`
}

type data struct {
	Dashboard View `json:"dashboard"`
}

func (h *Handler) get(c *gin.Context) {
	// Identifikator faqat JWT'dan olinadi — so'rovdagi hech qanday maydon
	// o'qilmaydi, shuning uchun boshqa foydalanuvchining ma'lumotini
	// so'rab bo'lmaydi.
	userID, ok := auth.UserID(c)
	if !ok {
		httperr.Write(c, http.StatusUnauthorized, httperr.CodeUnauthorized,
			"Authentication required.")
		return
	}

	view, err := h.service.Get(c.Request.Context(), userID)
	if err != nil {
		if errors.Is(err, profile.ErrUserNotFound) {
			httperr.Write(c, http.StatusUnauthorized, httperr.CodeUnauthorized,
				"Your session is no longer valid. Please sign in again.")
			return
		}
		slog.Error("dashboard request failed", "error", err)
		httperr.Write(c, http.StatusInternalServerError, httperr.CodeInternal,
			"Something went wrong. Please try again.")
		return
	}

	c.JSON(http.StatusOK, response{Success: true, Data: data{Dashboard: view}})
}
