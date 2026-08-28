package practice

import (
	"context"
	"errors"
	"log/slog"
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/auth"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/httperr"
)

// Handler mashq sessiyasi endpointlari.
type Handler struct {
	service *Service
}

// NewHandler yangi handler yaratadi.
func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// Register mashq yo'llarini ro'yxatdan o'tkazadi.
//
// Barchasi autentifikatsiya middleware'i ostida.
func (h *Handler) Register(r gin.IRouter, tokens *auth.TokenIssuer) {
	group := r.Group("/api/v1/practice/sessions", auth.Middleware(tokens))
	group.POST("", h.create)
	group.GET("/:id", h.get)
	group.POST("/:id/start", h.start)
	group.POST("/:id/complete", h.complete)
	group.POST("/:id/cancel", h.cancel)
}

type response struct {
	Success bool `json:"success"`
	Data    data `json:"data"`
}

type data struct {
	Session View `json:"session"`
}

func (h *Handler) create(c *gin.Context) {
	userID, ok := h.userID(c)
	if !ok {
		return
	}

	view, err := h.service.Create(c.Request.Context(), userID)
	if err != nil {
		h.writeError(c, err)
		return
	}
	c.JSON(http.StatusCreated, response{Success: true, Data: data{Session: view}})
}

func (h *Handler) get(c *gin.Context) { h.respond(c, h.service.Get) }

func (h *Handler) start(c *gin.Context) { h.respond(c, h.service.Start) }

func (h *Handler) complete(c *gin.Context) { h.respond(c, h.service.Complete) }

func (h *Handler) cancel(c *gin.Context) { h.respond(c, h.service.Cancel) }

// sessionAction sessiya identifikatori bilan ishlaydigan xizmat metodi.
type sessionAction func(ctx context.Context, userID, sessionID string) (View, error)

// respond identifikatorli amallar uchun umumiy javob mantiqi.
//
// To'rtta endpoint bir xil ishni bajaradi: tokendan foydalanuvchini oladi,
// yo'ldan identifikatorni oladi, xizmatni chaqiradi va javob yozadi.
func (h *Handler) respond(c *gin.Context, action sessionAction) {
	userID, ok := h.userID(c)
	if !ok {
		return
	}

	sessionID := c.Param("id")
	if sessionID == "" {
		httperr.Write(c, http.StatusNotFound, httperr.CodeNotFound,
			"Practice session not found.")
		return
	}

	view, err := action(c.Request.Context(), userID, sessionID)
	if err != nil {
		h.writeError(c, err)
		return
	}
	c.JSON(http.StatusOK, response{Success: true, Data: data{Session: view}})
}

// userID tokendan foydalanuvchi identifikatorini oladi.
//
// So'rov tanasidagi yoki yo'ldagi hech qanday foydalanuvchi identifikatori
// o'qilmaydi.
func (h *Handler) userID(c *gin.Context) (string, bool) {
	userID, ok := auth.UserID(c)
	if !ok {
		httperr.Write(c, http.StatusUnauthorized, httperr.CodeUnauthorized,
			"Authentication required.")
		return "", false
	}
	return userID, true
}

func (h *Handler) writeError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, ErrNotFound):
		// Boshqa foydalanuvchining sessiyasi ham shu javobni oladi —
		// mavjudligi oshkor qilinmaydi.
		httperr.Write(c, http.StatusNotFound, httperr.CodeNotFound,
			"Practice session not found.")
	case errors.Is(err, ErrInvalidTransition):
		httperr.Write(c, http.StatusConflict, httperr.CodeInvalidState,
			"This practice session can no longer be changed.")
	default:
		slog.Error("practice request failed", "error", err)
		httperr.Write(c, http.StatusInternalServerError, httperr.CodeInternal,
			"Something went wrong. Please try again.")
	}
}
