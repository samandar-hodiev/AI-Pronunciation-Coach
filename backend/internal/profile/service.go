package profile

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"unicode/utf8"
)

// ErrValidation kirish ma'lumotlari noto'g'ri bo'lganda qaytariladi.
var ErrValidation = errors.New("validation failed")

// ValidationError qaysi maydon noto'g'ri ekanini bildiradi.
type ValidationError struct {
	Field   string
	Message string
}

func (e ValidationError) Error() string { return e.Field + ": " + e.Message }

// Is [ErrValidation] bilan taqqoslash uchun.
func (e ValidationError) Is(target error) bool { return target == ErrValidation }

const maxNameLength = 100

// Service profil biznes mantiqi.
//
// HTTP haqida hech narsa bilmaydi va foydalanuvchi identifikatorini faqat
// chaqiruvchidan oladi — u esa uni JWT'dan oladi. Shu sababli mijoz
// yuborgan identifikatorga hech qachon ishonilmaydi.
type Service struct {
	repo Repository
}

// NewService yangi xizmat yaratadi.
func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

// Get foydalanuvchining profilini qaytaradi, kerak bo'lsa yaratadi.
func (s *Service) Get(ctx context.Context, userID string) (View, error) {
	p, name, err := s.repo.GetOrCreate(ctx, userID)
	if err != nil {
		return View{}, err
	}
	return toView(p, name), nil
}

// UpdateInput mijozdan kelgan xom qiymatlar.
//
// Bu yerda faqat sozlashga tegishli maydonlar bor. `setup_completed`,
// `user_id` yoki vaqt belgilari ataylab yo'q — ularni mijoz o'zgartira
// olmasligi kerak (mass assignment himoyasi).
type UpdateInput struct {
	Name               string
	LearningLanguage   string
	PronunciationGoal  string
	PronunciationLevel string
	DailyGoalMinutes   int
}

// Update profilni tekshiradi va saqlaydi.
//
// Muvaffaqiyatli saqlangach `setup_completed` doim `true` bo'ladi: to'liq
// tekshirilgan profil sozlash tugagani degani.
func (s *Service) Update(ctx context.Context, userID string, in UpdateInput) (View, error) {
	name := strings.TrimSpace(in.Name)
	language := strings.TrimSpace(in.LearningLanguage)

	if name == "" {
		return View{}, ValidationError{Field: "name", Message: "Name is required."}
	}
	if utf8.RuneCountInString(name) > maxNameLength {
		return View{}, ValidationError{Field: "name", Message: "Name is too long."}
	}

	// Til berilmasa standart qiymat ishlatiladi — hozircha bitta til bor va
	// mobil ilovada uni tanlash oynasi yo'q.
	if language == "" {
		language = AllowedLanguages[0]
	}
	if !allowedString(AllowedLanguages, language) {
		return View{}, ValidationError{
			Field:   "learning_language",
			Message: "This learning language is not supported yet.",
		}
	}

	if !allowedString(AllowedGoals, in.PronunciationGoal) {
		return View{}, ValidationError{
			Field:   "pronunciation_goal",
			Message: "Please choose a pronunciation goal.",
		}
	}
	if !allowedString(AllowedLevels, in.PronunciationLevel) {
		return View{}, ValidationError{
			Field:   "pronunciation_level",
			Message: "Please select your pronunciation level.",
		}
	}
	if !allowedInt(AllowedDailyGoalMinutes, in.DailyGoalMinutes) {
		return View{}, ValidationError{
			Field:   "daily_goal_minutes",
			Message: "Please choose a daily practice goal.",
		}
	}

	p, savedName, err := s.repo.Save(ctx, userID, SaveInput{
		Name:               name,
		LearningLanguage:   language,
		PronunciationGoal:  in.PronunciationGoal,
		PronunciationLevel: in.PronunciationLevel,
		DailyGoalMinutes:   in.DailyGoalMinutes,
	})
	if err != nil {
		return View{}, fmt.Errorf("save profile: %w", err)
	}

	return toView(p, savedName), nil
}

func toView(p Profile, name string) View {
	return View{
		Name:               name,
		LearningLanguage:   p.LearningLanguage,
		PronunciationGoal:  p.PronunciationGoal,
		PronunciationLevel: p.PronunciationLevel,
		DailyGoalMinutes:   p.DailyGoalMinutes,
		SetupCompleted:     p.SetupCompleted,
	}
}
