import 'package:flutter/foundation.dart';

/// Mashq sessiyasining holati.
///
/// Qiymatlar backend'dagi ro'yxat bilan bir xil.
enum PracticeStatus {
  created,
  recording,
  completed,
  cancelled;

  static PracticeStatus fromName(String? value) {
    return PracticeStatus.values.firstWhere(
      (PracticeStatus s) => s.name == value,
      // Noma'lum holat kelsa ilova buzilmasligi kerak.
      orElse: () => PracticeStatus.created,
    );
  }
}

/// Backenddagi mashq sessiyasi.
@immutable
class PracticeSession {
  const PracticeSession({
    required this.id,
    required this.status,
    this.durationSeconds,
  });

  final String id;
  final PracticeStatus status;

  /// Server hisoblagan davomiylik. Yakunlangunicha `null`.
  final int? durationSeconds;

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      id: json['id'] as String? ?? '',
      status: PracticeStatus.fromName(json['status'] as String?),
      durationSeconds: json['duration_seconds'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PracticeSession &&
      other.id == id &&
      other.status == status &&
      other.durationSeconds == durationSeconds;

  @override
  int get hashCode => Object.hash(id, status, durationSeconds);
}
