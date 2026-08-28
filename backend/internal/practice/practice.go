// Package practice mashq sessiyalarini boshqaradi.
//
// Bu bosqichda audio serverga yuklanmaydi va talaffuz tahlili qilinmaydi —
// paket faqat sessiya hayot siklini kuzatadi.
package practice

import (
	"errors"
	"time"
)

// Status sessiyaning holati.
//
// Matn sifatida saqlanadi, lekin ruxsat etilgan qiymatlar shu yerda
// cheklangan — bazaga ixtiyoriy satr tushmaydi.
type Status string

const (
	// StatusCreated sessiya yaratilgan, yozib olish hali boshlanmagan.
	StatusCreated Status = "created"

	// StatusRecording yozib olish davom etmoqda.
	StatusRecording Status = "recording"

	// StatusCompleted sessiya muvaffaqiyatli yakunlangan.
	StatusCompleted Status = "completed"

	// StatusCancelled foydalanuvchi sessiyani bekor qilgan.
	StatusCancelled Status = "cancelled"
)

// IsValid holat ruxsat etilganlar ro'yxatidami.
func (s Status) IsValid() bool {
	switch s {
	case StatusCreated, StatusRecording, StatusCompleted, StatusCancelled:
		return true
	default:
		return false
	}
}

// IsFinal holat yakuniymi — bunday sessiyani boshqa o'zgartirib bo'lmaydi.
func (s Status) IsFinal() bool {
	return s == StatusCompleted || s == StatusCancelled
}

// MaxRecordingSeconds bitta yozuvning eng uzun davomiyligi.
//
// Cheksiz yozib olishga yo'l qo'yilmaydi: uzoq audio keyinchalik tahlil
// uchun qimmat va foydalanuvchiga ham foydasi yo'q.
const MaxRecordingSeconds = 60

// Session mashq sessiyasi.
type Session struct {
	ID                 string
	UserID             string
	Status             Status
	StartedAt          time.Time
	RecordingStartedAt *time.Time
	CompletedAt        *time.Time
	DurationSeconds    *int
	AudioReference     *string
	CreatedAt          time.Time
	UpdatedAt          time.Time
}

// View mijozga qaytariladigan ko'rinish.
//
// `user_id` ataylab yo'q: mijoz uni bilishi shart emas va u faqat tokendan
// aniqlanadi.
type View struct {
	ID              string  `json:"id"`
	Status          string  `json:"status"`
	StartedAt       string  `json:"started_at"`
	CompletedAt     *string `json:"completed_at"`
	DurationSeconds *int    `json:"duration_seconds"`
}

// Xatolar.
var (
	// ErrNotFound sessiya topilmadi yoki boshqa foydalanuvchiga tegishli.
	//
	// Ikkala holat uchun bitta xato ishlatiladi: aks holda boshqa
	// foydalanuvchining sessiyasi mavjudligini aniqlash mumkin bo'lardi.
	ErrNotFound = errors.New("practice session not found")

	// ErrInvalidTransition holatni bunday o'zgartirib bo'lmaydi.
	ErrInvalidTransition = errors.New("invalid session state transition")
)

// ToView xavfsiz ko'rinishga o'giradi.
func (s Session) ToView() View {
	const layout = time.RFC3339

	var completedAt *string
	if s.CompletedAt != nil {
		formatted := s.CompletedAt.UTC().Format(layout)
		completedAt = &formatted
	}

	return View{
		ID:              s.ID,
		Status:          string(s.Status),
		StartedAt:       s.StartedAt.UTC().Format(layout),
		CompletedAt:     completedAt,
		DurationSeconds: s.DurationSeconds,
	}
}
