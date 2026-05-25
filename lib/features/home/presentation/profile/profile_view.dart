import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/i18n/i18n_keys.dart';
import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/features/home/presentation/profile/profile_controller.dart';

/// Profile / settings screen. Demonstrates:
///
/// * Reading from global controllers (`AuthController`, `ThemeController`,
///   `LocaleController`, `AppInfoService`) without prop-drilling.
/// * The canonical theme + language switcher UX.
/// * Logout flow — single call to `AuthController.logout()` handles
///   navigation + storage + telemetry teardown.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.profile.tr)),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16.w,
          vertical: AppDimensions.spacing16.h,
        ),
        children: [
          _UserHeader(controller: controller),
          SizedBox(height: AppDimensions.spacing24.h),
          _SectionHeader(label: I18n.theme.tr),
          _ThemePicker(controller: controller),
          SizedBox(height: AppDimensions.spacing24.h),
          _SectionHeader(label: I18n.language.tr),
          _LanguagePicker(controller: controller),
          SizedBox(height: AppDimensions.spacing24.h),
          _VersionTile(controller: controller),
          SizedBox(height: AppDimensions.spacing32.h),
          OutlinedButton.icon(
            onPressed: controller.onLogout,
            icon: const Icon(Icons.logout),
            label: Text(I18n.logout.tr),
          ),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.auth.user.value;
      final name = (user?.fullName.isNotEmpty ?? false) ? user!.fullName : I18n.profile.tr;
      return Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.containerFillColor,
            child: Icon(Icons.person_outline, size: 32),
          ),
          SizedBox(width: AppDimensions.spacing12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, textSize: TextSize.title_18, textWeight: TextWeight.w600),
                if (user?.email != null) ...[
                  const SizedBox(height: AppDimensions.spacing2),
                  AppText(user!.email!, textSize: TextSize.medium_14, textColor: AppColors.darkGreyTextColor),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spacing8.h),
      child: AppText(
        label,
        textSize: TextSize.medium_14,
        textWeight: TextWeight.w600,
        textColor: AppColors.darkGreyTextColor,
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.theme.mode.value;
      return Card(
        child: Column(
          children: [
            _ThemeTile(label: I18n.themeLight.tr, mode: ThemeMode.light, current: current, onTap: controller.onChangeTheme),
            const Divider(height: 1),
            _ThemeTile(label: I18n.themeDark.tr, mode: ThemeMode.dark, current: current, onTap: controller.onChangeTheme),
            const Divider(height: 1),
            _ThemeTile(label: I18n.themeSystem.tr, mode: ThemeMode.system, current: current, onTap: controller.onChangeTheme),
          ],
        ),
      );
    });
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.label,
    required this.mode,
    required this.current,
    required this.onTap,
  });

  final String label;
  final ThemeMode mode;
  final ThemeMode current;
  final Future<void> Function(ThemeMode) onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: AppText(label),
      trailing: current == mode ? const Icon(Icons.check) : null,
      onTap: () => onTap(mode),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.locale.currentLocale.value;
      return Card(
        child: Column(
          children: [
            for (var i = 0; i < controller.supportedLocales.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              ListTile(
                title: AppText(_displayName(controller.supportedLocales[i])),
                trailing: current.languageCode == controller.supportedLocales[i].languageCode
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => controller.onChangeLocale(controller.supportedLocales[i]),
              ),
            ],
          ],
        ),
      );
    });
  }

  String _displayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return I18n.languageEnglish.tr;
      case 'hi':
        return I18n.languageHindi.tr;
      default:
        return locale.languageCode;
    }
  }
}

class _VersionTile extends StatelessWidget {
  const _VersionTile({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final version = controller.appInfo.fullVersion;
    if (version.isEmpty) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        title: AppText(I18n.version.tr),
        trailing: AppText(version, textColor: AppColors.darkGreyTextColor),
      ),
    );
  }
}
