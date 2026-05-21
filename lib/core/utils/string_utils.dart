/// Generic string helpers.
///
/// **Why:** the backend often ships type/status/category strings in
/// `snake_case` (e.g. `new_team_member_added`) — never display them
/// verbatim. Always run them through [prettyType] so the UI shows
/// `New Team Member Added`. Same helper handles `camelCase` and mixed
/// inputs.
library;

/// Converts a `snake_case` / `camelCase` / `Mixed-Strings` value into a
/// human-readable Title Case label.
///
/// Examples:
/// - `new_team_member_added` → `New Team Member Added`
/// - `vetAppointment` → `Vet Appointment`
/// - `' booking_request '` → `Booking Request`
/// - `''` → `''`
String prettyType(String? raw) {
  if (raw == null) return '';
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';

  final spaced = trimmed.replaceAllMapped(RegExp(r'([a-z\d])([A-Z])'), (m) => '${m[1]} ${m[2]}').replaceAll(RegExp(r'[_\-]+'), ' ');

  return spaced.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).map((w) => w.length == 1 ? w.toUpperCase() : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}').join(' ');
}
