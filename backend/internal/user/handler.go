package user

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/auth"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/httperr"
)

// Handler autentifikatsiya HTTP endpointlari.
//
// Bu yerda biznes mantiq yo'q — faqat so'rovni o'qish, xizmatni chaqirish va
// javobni yozish.
type Handler struct {
	service *Service
}

// NewHandler yangi handler yaratadi.
func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// Register maxfiy yo'llarni ro'yxatdan o'tkazadi.
func (h *Handler) Register(r gin.IRouter, tokens *auth.TokenIssuer) {
	group := r.Group("/api/v1/auth")
	group.POST("/register", h.register)
	group.POST("/login", h.login)
	group.GET("/me", auth.Middleware(tokens), h.me)
}

type registerRequest struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type sessionResponse struct {
	Success bool        `json:"success"`
	Data    sessionData `json:"data"`
}

type sessionData struct {
	User        Public `json:"user"`
	AccessToken string `json:"access_token"`
	ExpiresAt   string `json:"expires_at"`
}

type userResponse struct {
	Success bool     `json:"success"`
	Data    userData `json:"data"`
}

type userData struct {
	User Public `json:"user"`
}

func (h *Handler) register(c *gin.Context) {
	var req registerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httperr.Write(c, http.StatusBadRequest, httperr.CodeValidation,
			"Please check the information you entered.")
		return
	}

	session, err := h.service.Register(c.Request.Context(), RegisterInput{
		Name:     req.Name,
		Email:    req.Email,
		Password: req.Password,
	})
	if err != nil {
		h.writeAuthError(c, err)
		return
	}

	c.JSON(http.StatusCreated, newSessionResponse(session))
}

func (h *Handler) login(c *gin.Context) {
	var req loginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httperr.Write(c, http.StatusBadRequest, httperr.CodeValidation,
			"Please check the information you entered.")
		return
	}

	session, err := h.service.Login(c.Request.Context(), LoginInput{
		Email:    req.Email,
		Password: req.Password,
	})
	if err != nil {
		h.writeAuthError(c, err)
		return
	}

	c.JSON(http.StatusOK, newSessionResponse(session))
}

func (h *Handler) me(c *gin.Context) {
	userID, ok := auth.UserID(c)
	if !ok {
		httperr.Write(c, http.StatusUnauthorized, httperr.CodeUnauthorized,
			"Authentication required.")
		return
	}

	public, err := h.service.CurrentUser(c.Request.Context(), userID)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			// Token yaroqli, lekin foydalanuvchi o'chirilgan.
			httperr.Write(c, http.StatusUnauthorized, httperr.CodeUnauthorized,
				"Your session is no longer valid. Please sign in again.")
			return
		}
		slog.Error("fetch current user failed", "error", err)
		httperr.Write(c, http.StatusInternalServerError, httperr.CodeInternal,
			"Something went wrong. Please try again.")
		return
	}

	c.JSON(http.StatusOK, userResponse{Success: true, Data: userData{User: public}})
}

// writeAuthError xizmat xatosini mijozga xavfsiz javobga o'giradi.
//
// Ichki xato matni hech qachon mijozga yuborilmaydi — u faqat log qilinadi.
func (h *Handler) writeAuthError(c *gin.Context, err error) {
	var validationErr ValidationError
	switch {
	case errors.As(err, &validationErr):
		httperr.Write(c, http.StatusUnprocessableEntity, httperr.CodeValidation,
			validationErr.Message)
	case errors.Is(err, ErrEmailTaken):
		httperr.Write(c, http.StatusConflict, httperr.CodeEmailTaken,
			"An account with this email already exists.")
	case errors.Is(err, ErrInvalidCredentials):
		httperr.Write(c, http.StatusUnauthorized, httperr.CodeInvalidCreds,
			"Incorrect email or password.")
	default:
		slog.Error("authentication request failed", "error", err)
		httperr.Write(c, http.StatusInternalServerError, httperr.CodeInternal,
			"Something went wrong. Please try again.")
	}
}

func newSessionResponse(s Session) sessionResponse {
	return sessionResponse{
		Success: true,
		Data: sessionData{
			User:        s.User,
			AccessToken: s.AccessToken,
			ExpiresAt:   s.ExpiresAt.UTC().Format("2006-01-02T15:04:05Z07:00"),
		},
	}
}
