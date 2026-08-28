package practice

import (
	"context"
	"fmt"
	"math"
	"time"

	"github.com/google/uuid"
)

// Service mashq sessiyasining biznes mantiqi va holat o'tishlari.
//
// HTTP haqida hech narsa bilmaydi. Foydalanuvchi identifikatori chaqiruvchidan
// keladi — u esa uni JWT'dan oladi.
type Service struct {
	repo Repository
	now  func() time.Time
}

// NewService yangi xizmat yaratadi.
func NewService(repo Repository) *Service {
	return &Service{repo: repo, now: func() time.Time { return time.Now().UTC() }}
}

// Create yangi sessiya boshlaydi.
func (s *Service) Create(ctx context.Context, userID string) (View, error) {
	now := s.now()

	session := Session{
		ID:        uuid.NewString(),
		UserID:    userID,
		Status:    StatusCreated,
		StartedAt: now,
		CreatedAt: now,
		UpdatedAt: now,
	}

	if err := s.repo.Create(ctx, session); err != nil {
		return View{}, err
	}
	return session.ToView(), nil
}

// Get sessiyani qaytaradi.
func (s *Service) Get(ctx context.Context, userID, sessionID string) (View, error) {
	session, err := s.repo.Find(ctx, userID, sessionID)
	if err != nil {
		return View{}, err
	}
	return session.ToView(), nil
}

// Start yozib olish boshlanganini belgilaydi.
//
// Davomiylik shu paytdan hisoblanadi, sessiya yaratilgan vaqtdan emas.
//
// Takroriy chaqiruv xato emas: tarmoq qayta urinishi sessiyani buzmasligi
// kerak, shuning uchun allaqachon `recording` bo'lsa holat o'zgarmaydi.
func (s *Service) Start(ctx context.Context, userID, sessionID string) (View, error) {
	session, err := s.repo.Find(ctx, userID, sessionID)
	if err != nil {
		return View{}, err
	}

	if session.Status == StatusRecording {
		return session.ToView(), nil
	}
	if session.Status != StatusCreated {
		return View{}, fmt.Errorf("%w: %s -> %s",
			ErrInvalidTransition, session.Status, StatusRecording)
	}

	now := s.now()
	session.Status = StatusRecording
	session.RecordingStartedAt = &now

	if err := s.repo.Update(ctx, userID, session); err != nil {
		return View{}, err
	}
	return session.ToView(), nil
}

// Complete sessiyani yakunlaydi.
//
// Davomiylik **server vaqtlaridan** hisoblanadi — mijoz yuborgan qiymatga
// tayanilmaydi.
//
// Takroriy chaqiruv xavfsiz: sessiya allaqachon yakunlangan bo'lsa mavjud
// natija qaytariladi va vaqtlar qayta yozilmaydi.
func (s *Service) Complete(ctx context.Context, userID, sessionID string) (View, error) {
	session, err := s.repo.Find(ctx, userID, sessionID)
	if err != nil {
		return View{}, err
	}

	if session.Status == StatusCompleted {
		return session.ToView(), nil
	}
	if session.Status != StatusRecording {
		return View{}, fmt.Errorf("%w: %s -> %s",
			ErrInvalidTransition, session.Status, StatusCompleted)
	}

	now := s.now()
	duration := s.durationSeconds(session.RecordingStartedAt, now)

	session.Status = StatusCompleted
	session.CompletedAt = &now
	session.DurationSeconds = &duration

	if err := s.repo.Update(ctx, userID, session); err != nil {
		return View{}, err
	}
	return session.ToView(), nil
}

// Cancel sessiyani bekor qiladi.
//
// Yakunlangan sessiyani bekor qilib bo'lmaydi. Allaqachon bekor qilingan
// bo'lsa takroriy so'rov xavfsiz.
func (s *Service) Cancel(ctx context.Context, userID, sessionID string) (View, error) {
	session, err := s.repo.Find(ctx, userID, sessionID)
	if err != nil {
		return View{}, err
	}

	if session.Status == StatusCancelled {
		return session.ToView(), nil
	}
	if session.Status.IsFinal() {
		return View{}, fmt.Errorf("%w: %s -> %s",
			ErrInvalidTransition, session.Status, StatusCancelled)
	}

	now := s.now()
	session.Status = StatusCancelled
	session.CompletedAt = &now

	if err := s.repo.Update(ctx, userID, session); err != nil {
		return View{}, err
	}
	return session.ToView(), nil
}

// durationSeconds yozuv davomiyligini hisoblaydi.
//
// Qiymat 0 dan [MaxRecordingSeconds] gacha cheklanadi: soat noto'g'ri
// bo'lsa yoki so'rov juda kech kelsa ham bazaga mantiqsiz raqam tushmaydi.
func (s *Service) durationSeconds(startedAt *time.Time, completedAt time.Time) int {
	if startedAt == nil {
		return 0
	}

	elapsed := completedAt.Sub(*startedAt).Seconds()
	if math.IsNaN(elapsed) || elapsed < 0 {
		return 0
	}

	rounded := int(math.Round(elapsed))
	if rounded > MaxRecordingSeconds {
		return MaxRecordingSeconds
	}
	return rounded
}
