library;

///! WARNINGS:
///* =>> Don't change any enum INDEX (Positions)

/// ***********************************************************************************
/// *                                  LOCAL ENUMS                                    *
/// ***********************************************************************************

///* APPLICATION ENVIRONMENT TYPES - USE IN API STATES
enum EnvironmentType {
  local(id: 0, label: 'Local', slug: 'local'),
  development(id: 1, label: 'Development', slug: 'development'),
  staging(id: 2, label: 'Q&A', slug: 'qa'),
  production(id: 3, label: 'Production', slug: 'production');

  final int id;
  final String label;
  final String slug;

  const EnvironmentType({required this.id, required this.label, required this.slug});

  static EnvironmentType fromSlug(String slug) {
    return EnvironmentType.values.firstWhere((e) => e.slug == slug);
  }
}
