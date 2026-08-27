// Package migrations SQL migratsiya fayllarini binarga joylashtiradi.
//
// Fayllar binar ichida bo'lgani uchun ilovani ishga tushirish uchun tashqi
// migratsiya vositasi ham, fayl tizimidagi yo'l ham kerak emas.
package migrations

import "embed"

// FS barcha "up" migratsiyalari.
//
//go:embed *.up.sql
var FS embed.FS
