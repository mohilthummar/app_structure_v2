/// Typed constants for every translation key. Always use these instead
/// of raw string literals so renames are compile-checked and missing
/// translations surface as an unresolved identifier rather than a silent
/// fallback to the key.
///
/// Usage in views: `Text(I18n.signIn.tr)` (GetX's `.tr` extension reads
/// from `AppTranslations.keys`).
///
/// Conventions:
/// * Constants are grouped by namespace (auth, common, home, settings).
/// * String values are dot-namespaced (`auth.signIn`) so the JSON
///   dictionaries stay flat and grep-able.
/// * Every key must exist in `assets/i18n/en.json` (the fallback locale)
///   or `.tr` will return the raw key.
class I18n {
  I18n._();

  // ── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'app.name';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String signIn = 'auth.signIn';
  static const String signUp = 'auth.signUp';
  static const String email = 'auth.email';
  static const String password = 'auth.password';
  static const String emailHint = 'auth.emailHint';
  static const String passwordHint = 'auth.passwordHint';
  static const String phoneNumber = 'auth.phoneNumber';
  static const String phoneHint = 'auth.phoneHint';
  static const String fullName = 'auth.fullName';
  static const String fullNameHint = 'auth.fullNameHint';
  static const String forgotPassword = 'auth.forgotPassword';
  static const String forgotPasswordTitle = 'auth.forgotPasswordTitle';
  static const String resetEmailIntro = 'auth.resetEmailIntro';
  static const String sendResetLink = 'auth.sendResetLink';
  static const String resetLinkSent = 'auth.resetLinkSent';
  static const String otpTitle = 'auth.otpTitle';
  static const String otpSubtitle = 'auth.otpSubtitle';
  static const String didNotReceiveCode = 'auth.didNotReceiveCode';
  static const String resendCode = 'auth.resendCode';
  static const String verify = 'auth.verify';
  static const String dontHaveAccount = 'auth.dontHaveAccount';
  static const String pleaseEnterCredentials = 'auth.pleaseEnterCredentials';
  static const String createAccountIntro = 'auth.createAccountIntro';

  // ── Common ───────────────────────────────────────────────────────────────
  static const String cancel = 'common.cancel';
  static const String save = 'common.save';
  static const String delete = 'common.delete';
  static const String confirm = 'common.confirm';
  static const String retry = 'common.retry';
  static const String loading = 'common.loading';
  static const String empty = 'common.empty';
  static const String error = 'common.error';
  static const String offline = 'common.offline';

  // ── Home / dashboard / profile ───────────────────────────────────────────
  static const String dashboard = 'home.dashboard';
  static const String profile = 'home.profile';
  static const String logout = 'home.logout';

  // ── Settings ─────────────────────────────────────────────────────────────
  static const String theme = 'settings.theme';
  static const String themeLight = 'settings.themeLight';
  static const String themeDark = 'settings.themeDark';
  static const String themeSystem = 'settings.themeSystem';
  static const String language = 'settings.language';
  static const String languageEnglish = 'settings.languageEnglish';
  static const String languageHindi = 'settings.languageHindi';
  static const String version = 'settings.version';
}
