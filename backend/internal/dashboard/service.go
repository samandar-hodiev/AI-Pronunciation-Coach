package dashboard

import (
	"context"
	"fmt"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/profile"
)

// Service bosh ekran ma'lumotlarini yig'adi.
//
// O'z repozitoriysi yo'q: mavjud profil repozitoriysidan foydalanadi.
// Bosh ekran uchun alohida jadval ham, alohida SQL ham kerak emas.
type Service struct {
	profiles profile.Repository
}

// NewService yangi xizmat yaratadi.
func NewService(profiles profile.Repository) *Service {
	return &Service{profiles: profiles}
}

// Get berilgan foydalanuvchining bosh ekran ma'lumotini qaytaradi.
//
// Foydalanuvchi identifikatori chaqiruvchidan keladi — u esa uni JWT'dan
// oladi. Mijoz yuborgan identifikatorga hech qachon ishonilmaydi.
func (s *Service) Get(ctx context.Context, userID string) (View, error) {
	p, name, err := s.profiles.GetOrCreate(ctx, userID)
	if err != nil {
		return View{}, fmt.Errorf("load profile: %w", err)
	}

	return View{
		User:                     UserView{Name: name},
		DailyPracticeGoalMinutes: p.DailyGoalMinutes,
		Today: TodayView{
			// Mashq funksiyasi hali yo'q, shuning uchun o'lchov ham yo'q.
			TrackingAvailable: false,
			CompletedMinutes:  nil,
		},
		// Talaffuz ballari va mashq tarixi hali saqlanmaydi.
		Progress:       SectionState{Available: false},
		RecentPractice: SectionState{Available: false},
	}, nil
}
