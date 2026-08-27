package profile

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/auth"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/httperr"
)

// Handler profil HTTP endpointlari.
type Handler struct {
	service *Service
}

// NewHandler yangi handler yaratadi.
func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// Register profil yo'llarini ro'yxatdan o'tkazadi.
//
// Ikkala yo'l ham autentifikatsiya middleware'i ostida — profil hech qachon
// tokensiz ochilmaydi.
func (h *Handler) Register(r gin.IRouter, tokens *auth.TokenIssuer) {
	group := r.Group("/api/v1/profile", auth.Middleware(tokens))
	group.GET("", h.get)
	group.PUT("", h.update)
}

type updateRequest struct {
	Name               string `json:"name"`
	LearningLanguage   string `json:"learning_language"`
	PronunciationGoal  string `json:"pronunciation_goal"`
	PronunciationLevel string `json:"pronunciation_level"`
	DailyGoalMinutes   int    `json:"daily_goal_minutes"`
}

type profileResponse struct {
	Success bool        `json:"success"`
	Data    profileData `json:"data"`
}

type profileData struct {
	Profile View `json:"profile"`
}

func (h *Handler) get(c *gin.Context) {
	userID, ok := auth.UserID(c)
	if !ok {
		httperr.Write(c, http.StatusUnauthorized, httperr.CodeUnauthorized,
			"Authentication required.")
		return
	}

	view, err := h.service.Get(c.Request.Context(), userID)
	if err != nil {
		h.writeError(c, err)
		return
	}

	c.JSON(http.StatusOK, profileResponse{Success: true, Data: profileData{Profile: view}})
}

func (h *Handler) update(c *gin.Context) {
	// Foydalanuvchi identifikatori faqat JWT'dan olinadi.
	//
	// So'rov tanasida `user_id` maydoni umuman o'qilmaydi, shuning uchun
	// boshqa foydalanuvchining profilini o'zgartirib bo'lmaydi.
	userID, ok := auth.UserID(c)
	if !ok {
		httperr.Write(c, http.StatusUnauthorized, httperr.CodeUnauthorized,
			"Authentication required.")
		return
	}

	var req updateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httperr.Write(c, http.StatusBadRequest, httperr.CodeValidation,
			"Please check the information you entered.")
		return
	}

	view, err := h.service.Update(c.Request.Context(), userID, UpdateInput{
		Name:               req.Name,
		LearningLanguage:   req.LearningLanguage,
		PronunciationGoal:  req.PronunciationGoal,
		PronunciationLevel: req.PronunciationLevel,
		DailyGoalMinutes:   req.DailyGoalMinutes,
	})
	if err != nil {
		h.writeError(c, err)
		return
	}

	c.JSON(http.StatusOK, profileResponse{Success: true, Data: profileData{Profile: view}})
}

func (h *Handler) writeError(c *gin.Context, err error) {
	var validationErr ValidationError
	switch {
	case errors.As(err, &validationErr):
		httperr.Write(c, http.StatusUnprocessableEntity, httperr.CodeValidation,
			validationErr.Message)
	case errors.Is(err, ErrUserNotFound):
		httperr.Write(c, http.StatusUnauthorized, httperr.CodeUnauthorized,
			"Your session is no longer valid. Please sign in again.")
	default:
		slog.Error("profile request failed", "error", err)
		httperr.Write(c, http.StatusInternalServerError, httperr.CodeInternal,
			"Something went wrong. Please try again.")
	}
}
