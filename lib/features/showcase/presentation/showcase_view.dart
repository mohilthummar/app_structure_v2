import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/enums/view_state.dart';
import 'package:app_structure/core/extensions/currency_extension.dart';
import 'package:app_structure/core/extensions/date_extension.dart';
import 'package:app_structure/core/extensions/number_extension.dart';
import 'package:app_structure/core/i18n/i18n_keys.dart';
import 'package:app_structure/core/mixins/validation_mixin.dart';
import 'package:app_structure/core/services/file_picker_service.dart';
import 'package:app_structure/core/services/image_picker_service.dart';
import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/core/theme/app_typography.dart';
import 'package:app_structure/core/utils/app_loader.dart';
import 'package:app_structure/core/utils/app_shimmers.dart';
import 'package:app_structure/core/utils/app_snack_bar.dart';
import 'package:app_structure/core/utils/string_utils.dart';
import 'package:app_structure/shared/models/drop_down_model.dart';
import 'package:app_structure/shared/widgets/app_app_bar.dart';
import 'package:app_structure/shared/widgets/app_button.dart';
import 'package:app_structure/shared/widgets/app_drop_down.dart';
import 'package:app_structure/shared/widgets/app_empty_state.dart';
import 'package:app_structure/shared/widgets/app_icon_button.dart';
import 'package:app_structure/shared/widgets/app_loading.dart';
import 'package:app_structure/shared/widgets/app_pin_code_field.dart';
import 'package:app_structure/shared/widgets/app_text_field.dart';
import 'package:app_structure/shared/widgets/bottom_border_container.dart';
import 'package:app_structure/shared/widgets/offline_banner.dart';
import 'package:app_structure/shared/widgets/screen_header.dart';
import 'package:app_structure/shared/widgets/state_switch.dart';

/// Live gallery of every shared widget, design token, and utility in the
/// skeleton.
///
/// This is a developer-only screen — it ships with the app so you can
/// eyeball every component side-by-side on a real device, but it's never
/// part of a normal user flow. Reach it from the profile screen's
/// "Component Showcase" action, or visit [RouteNames.showcase] directly.
///
/// Each section in the scroll view demos one family of components,
/// followed by a code-style note describing what to use it for and where
/// to find it.

/// Holds a [ValidationMixin] instance so the showcase can demo validators
/// outside a controller. Real screens mix [ValidationMixin] into their
/// controller and call `controller.emailValidator` instead.
class _ShowcaseValidators with ValidationMixin {}

final _validators = _ShowcaseValidators();

class ShowcaseView extends StatefulWidget {
  /// Creates the showcase view.
  const ShowcaseView({super.key});

  @override
  State<ShowcaseView> createState() => _ShowcaseViewState();
}

class _ShowcaseViewState extends State<ShowcaseView> {
  late final TextEditingController _textController;
  late final TextEditingController _emailController;
  late final TextEditingController _pinController;
  DropDownModel? _selectedDropDown;
  ViewState _switchedState = ViewState.loading;
  bool _shimmerOn = true;
  XFile? _pickedImage;
  String? _pickedFileName;

  static final List<DropDownModel> _dropDownItems = [
    DropDownModel(id: 1, title: 'Option One'),
    DropDownModel(id: 2, title: 'Option Two'),
    DropDownModel(id: 3, title: 'Option Three'),
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _emailController = TextEditingController();
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: I18n.showcase.tr),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16.w,
                vertical: AppDimensions.spacing16.h,
              ),
              children: [
                _Section(
                  title: 'Typography (AppText + AppTypography)',
                  hint: 'lib/core/theme/app_text.dart · app_typography.dart',
                  child: _TypographySection(),
                ),
                const _Section(
                  title: 'Color tokens (AppColors)',
                  hint: 'lib/core/constants/app_colors.dart',
                  child: _ColorSection(),
                ),
                const _Section(
                  title: 'Spacing & radius (AppDimensions)',
                  hint: 'lib/core/theme/app_dimensions.dart',
                  child: _DimensionSection(),
                ),
                const _Section(
                  title: 'Buttons (AppButton, AppIconButton)',
                  hint: 'lib/shared/widgets/app_button.dart · app_icon_button.dart',
                  child: _ButtonSection(),
                ),
                _Section(
                  title: 'Text fields (AppTextField, AppPinCodeField, AppDropDown)',
                  hint: 'lib/shared/widgets/app_text_field.dart · …',
                  child: _InputSection(
                    text: _textController,
                    email: _emailController,
                    pin: _pinController,
                    dropdownValue: _selectedDropDown,
                    dropdownItems: _dropDownItems,
                    onDropdownChanged: (m) => setState(() => _selectedDropDown = m),
                  ),
                ),
                _Section(
                  title: 'View state (StateSwitch)',
                  hint: 'lib/shared/widgets/state_switch.dart',
                  child: _StateSwitchSection(
                    current: _switchedState,
                    onChanged: (s) => setState(() => _switchedState = s),
                  ),
                ),
                _Section(
                  title: 'Loaders & shimmers (AppLoader, AppLoading, AppShimmers)',
                  hint: 'lib/core/utils/app_loader.dart · app_shimmers.dart',
                  child: _LoaderSection(
                    shimmerOn: _shimmerOn,
                    onToggle: () => setState(() => _shimmerOn = !_shimmerOn),
                  ),
                ),
                const _Section(
                  title: 'Snackbars (AppSnackBar)',
                  hint: 'lib/core/utils/app_snack_bar.dart',
                  child: _SnackbarSection(),
                ),
                _Section(
                  title: 'Pickers (image · file)',
                  hint: 'lib/core/services/image_picker_service.dart · file_picker_service.dart',
                  child: _PickerSection(
                    pickedImage: _pickedImage,
                    pickedFile: _pickedFileName,
                    onImage: (x) => setState(() => _pickedImage = x),
                    onFile: (name) => setState(() => _pickedFileName = name),
                  ),
                ),
                const _Section(
                  title: 'Dates & numbers (extensions)',
                  hint: 'lib/core/extensions/*.dart',
                  child: _FormattingSection(),
                ),
                const _Section(
                  title: 'Validators (ValidationMixin)',
                  hint: 'lib/core/mixins/validation_mixin.dart',
                  child: _ValidatorSection(),
                ),
                const _Section(
                  title: 'Misc (ScreenHeader, BottomBorderContainer, EmptyState)',
                  hint: 'lib/shared/widgets/*.dart',
                  child: _MiscSection(),
                ),
                SizedBox(height: AppDimensions.spacing48.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps each demo block with a consistent header + hint footer so the
/// showcase reads top-to-bottom like a printed component guide.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.hint, required this.child});

  final String title;
  final String hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacing24.h),
      padding: EdgeInsets.all(AppDimensions.spacing16.w),
      decoration: BoxDecoration(
        color: AppColors.containerFillColor,
        borderRadius: AppDimensions.borderRadius12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            title,
            textSize: TextSize.large_16,
            textWeight: TextWeight.w600,
            textColor: AppColors.primaryTextColor,
          ),
          SizedBox(height: AppDimensions.spacing4.h),
          AppText(
            hint,
            textSize: TextSize.extraSmall_10,
            textColor: AppColors.darkGreyTextColor,
            multiLine: true,
            maxLines: 2,
          ),
          SizedBox(height: AppDimensions.spacing16.h),
          child,
        ],
      ),
    );
  }
}

class _TypographySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final samples = <(String, TextSize, TextWeight)>[
      ('Headline 24 / w600', TextSize.headline_24, TextWeight.w600),
      ('Large title 20 / w500', TextSize.largeTitle_20, TextWeight.w500),
      ('Title 18 / w600', TextSize.title_18, TextWeight.w600),
      ('Large 16 / w500', TextSize.large_16, TextWeight.w500),
      ('Medium 14 / w400', TextSize.medium_14, TextWeight.w400),
      ('Small 12 / w400', TextSize.small_12, TextWeight.w400),
      ('Extra small 10 / w400', TextSize.extraSmall_10, TextWeight.w400),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, size, weight) in samples) ...[
          AppText(label, textSize: size, textWeight: weight),
          const SizedBox(height: AppDimensions.spacing6),
        ],
        const SizedBox(height: 6),
        Text(
          'AppTypography.semibold(AppTypography.xl)',
          style: AppTypography.semibold(AppTypography.xl).copyWith(
            fontSize: AppTypography.xl.fontSize!.sp,
          ),
        ),
      ],
    );
  }
}

class _ColorSection extends StatelessWidget {
  const _ColorSection();

  @override
  Widget build(BuildContext context) {
    final swatches = <(String, Color)>[
      ('primary', AppColors.primaryColor),
      ('background', AppColors.backgroundColor),
      ('container', AppColors.containerFillColor),
      ('text', AppColors.primaryTextColor),
      ('text-dark', AppColors.darkGreyTextColor),
      ('divider', AppColors.dividerAndBorderColor),
      ('success', AppColors.toastSuccess),
      ('warning', AppColors.toastWarning),
      ('error', AppColors.toastError),
      ('info', AppColors.toastInfo),
      ('successBg', AppColors.successBg),
      ('errorBg', AppColors.errorBg),
    ];
    return Wrap(
      spacing: AppDimensions.spacing8,
      runSpacing: AppDimensions.spacing8,
      children: [
        for (final (name, color) in swatches) _Swatch(label: name, color: color),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92.w,
      padding: const EdgeInsets.all(AppDimensions.spacing6),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: AppDimensions.borderRadius4,
        border: Border.all(color: AppColors.dividerAndBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppDimensions.borderRadius4,
              border: Border.all(color: AppColors.dividerAndBorderColor.withValues(alpha: 0.4)),
            ),
          ),
          const SizedBox(height: 4),
          AppText(label, textSize: TextSize.extraSmall_10, textWeight: TextWeight.w500),
        ],
      ),
    );
  }
}

class _DimensionSection extends StatelessWidget {
  const _DimensionSection();

  @override
  Widget build(BuildContext context) {
    const steps = <double>[
      AppDimensions.spacing4,
      AppDimensions.spacing8,
      AppDimensions.spacing12,
      AppDimensions.spacing16,
      AppDimensions.spacing24,
      AppDimensions.spacing32,
      AppDimensions.spacing48,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final step in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacing4),
            child: Row(
              children: [
                SizedBox(width: 48, child: AppText('${step.toInt()}')),
                Expanded(
                  child: Container(
                    height: 10,
                    width: step,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: AppDimensions.borderRadius4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: AppDimensions.spacing8.h),
        Row(
          children: [
            for (final r in const [AppDimensions.radius4, AppDimensions.radius10, AppDimensions.radius16, AppDimensions.radius20])
              Padding(
                padding: const EdgeInsets.only(right: AppDimensions.spacing8),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(r),
                      ),
                    ),
                    AppText('r${r.toInt()}', textSize: TextSize.extraSmall_10),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ButtonSection extends StatelessWidget {
  const _ButtonSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(onPressed: () {}, label: 'Primary'),
        SizedBox(height: AppDimensions.spacing8.h),
        AppButton(onPressed: () {}, label: 'Loading…', isLoading: true),
        SizedBox(height: AppDimensions.spacing8.h),
        const AppButton(onPressed: null, label: 'Disabled', disable: true),
        SizedBox(height: AppDimensions.spacing8.h),
        AppButton.outlined(onPressed: () {}, label: 'Outlined'),
        SizedBox(height: AppDimensions.spacing8.h),
        AppButton(
          onPressed: () {},
          label: 'With icon',
          icon: Icons.bolt_rounded,
          imageAlign: ImageAlign.start,
        ),
        SizedBox(height: AppDimensions.spacing12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppIconButton(onTap: () {}, icon: Icons.favorite_border),
            AppIconButton(
              onTap: () {},
              icon: Icons.add,
              decoration: IconButtonStyle.fillPrimary,
              iconColor: AppColors.white,
            ),
            AppIconButton(
              onTap: () {},
              icon: Icons.settings_outlined,
              decoration: IconButtonStyle.fillContainerColor,
            ),
          ],
        ),
      ],
    );
  }
}

class _InputSection extends StatelessWidget {
  const _InputSection({
    required this.text,
    required this.email,
    required this.pin,
    required this.dropdownValue,
    required this.dropdownItems,
    required this.onDropdownChanged,
  });

  final TextEditingController text;
  final TextEditingController email;
  final TextEditingController pin;
  final DropDownModel? dropdownValue;
  final List<DropDownModel> dropdownItems;
  final ValueChanged<DropDownModel?> onDropdownChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: text,
          label: 'Name',
          hintText: 'Enter your name',
        ),
        SizedBox(height: AppDimensions.spacing12.h),
        AppTextField(
          controller: email,
          label: 'Email',
          hintText: 'name@example.com',
          keyboardType: TextInputType.emailAddress,
          validator: _validators.emailValidator,
        ),
        SizedBox(height: AppDimensions.spacing12.h),
        AppPinCodeField(
          controller: pin,
          label: 'OTP',
          autoFocus: false,
          onChanged: (_) {},
        ),
        SizedBox(height: AppDimensions.spacing12.h),
        AppDropDown(
          label: 'Pick one',
          hintText: 'Choose an option',
          items: dropdownItems,
          value: dropdownValue,
          onChanged: onDropdownChanged,
        ),
      ],
    );
  }
}

class _StateSwitchSection extends StatelessWidget {
  const _StateSwitchSection({required this.current, required this.onChanged});

  final ViewState current;
  final ValueChanged<ViewState> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppDimensions.spacing6,
          children: [
            for (final s in ViewState.values)
              ChoiceChip(
                label: AppText(s.name),
                selected: current == s,
                onSelected: (_) => onChanged(s),
              ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing12.h),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: AppDimensions.borderRadius10,
            border: Border.all(color: AppColors.dividerAndBorderColor),
          ),
          padding: const EdgeInsets.all(AppDimensions.spacing12),
          child: StateSwitch(
            state: current,
            onLoading: (_) => const AppLoading(),
            onEmpty: (_) => const AppEmptyState(title: 'Nothing here'),
            onError: (_) => const AppEmptyState(
              title: 'Something went wrong',
              icon: Icons.error_outline,
            ),
            onSuccess: (_) => const Center(
              child: AppText(
                'Success content',
                textSize: TextSize.large_16,
                textWeight: TextWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoaderSection extends StatelessWidget {
  const _LoaderSection({required this.shimmerOn, required this.onToggle});

  final bool shimmerOn;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const CircularLoader(color: AppColors.primaryColor),
            const SizedBox(width: AppDimensions.spacing16),
            const AppLoading(color: AppColors.primaryColor),
            const SizedBox(width: AppDimensions.spacing16),
            Expanded(
              child: AppButton.outlined(
                onPressed: onToggle,
                label: shimmerOn ? 'Stop shimmer' : 'Start shimmer',
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing12.h),
        AppShimmers.wrap(
          showShimmer: shimmerOn,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmers.box(height: 16, width: 180),
              const SizedBox(height: AppDimensions.spacing8),
              AppShimmers.box(height: 12, width: 240),
              const SizedBox(height: AppDimensions.spacing8),
              AppShimmers.box(height: 12, width: 120),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.spacing12.h),
        SizedBox(
          height: 120,
          child: ClipRRect(
            borderRadius: AppDimensions.borderRadius12,
            child: const AppLoader(label: 'Full-screen loader'),
          ),
        ),
      ],
    );
  }
}

class _SnackbarSection extends StatelessWidget {
  const _SnackbarSection();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacing8,
      runSpacing: AppDimensions.spacing8,
      children: [
        OutlinedButton(
          onPressed: () => AppSnackBar.success(message: 'Saved successfully'),
          child: const Text('success'),
        ),
        OutlinedButton(
          onPressed: () => AppSnackBar.info(message: 'Just so you know…'),
          child: const Text('info'),
        ),
        OutlinedButton(
          onPressed: () => AppSnackBar.warning(message: 'Heads up — check your input'),
          child: const Text('warning'),
        ),
        OutlinedButton(
          onPressed: () => AppSnackBar.error(message: 'Something broke'),
          child: const Text('error'),
        ),
        OutlinedButton(
          onPressed: () => HapticFeedback.lightImpact(),
          child: const Text('haptic'),
        ),
      ],
    );
  }
}

class _PickerSection extends StatelessWidget {
  const _PickerSection({
    required this.pickedImage,
    required this.pickedFile,
    required this.onImage,
    required this.onFile,
  });

  final XFile? pickedImage;
  final String? pickedFile;
  final ValueChanged<XFile?> onImage;
  final ValueChanged<String?> onFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton.outlined(
                onPressed: () async {
                  final file = await ImagePickerService.pickFromSheet();
                  onImage(file);
                },
                label: 'Pick image',
              ),
            ),
            const SizedBox(width: AppDimensions.spacing8),
            Expanded(
              child: AppButton.outlined(
                onPressed: () async {
                  final file = await FilePickerService.pick();
                  if (file != null) {
                    onFile('${file.name} · ${FilePickerService.formatFileSize(file.size)}');
                  }
                },
                label: 'Pick PDF',
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing8.h),
        AppText(
          pickedImage == null ? 'No image picked' : 'Image: ${pickedImage!.name}',
          textColor: AppColors.darkGreyTextColor,
        ),
        AppText(
          pickedFile ?? 'No file picked',
          textColor: AppColors.darkGreyTextColor,
        ),
      ],
    );
  }
}

class _FormattingSection extends StatelessWidget {
  const _FormattingSection();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(hours: 5, minutes: 12));
    final lines = <(String, String)>[
      ('now.formatDate()', now.formatDate()),
      ('now.formatDateTime()', now.formatDateTime()),
      ('now.isToday', '${now.isToday}'),
      ('5h12m.timeAgo()', earlier.timeAgo()),
      ('123456.formatNumber()', 123456.formatNumber()),
      ('99999.99.toCurrency()', (99999.99).toCurrency()),
      ('150000.toCompactCurrency()', 150000.toCompactCurrency()),
      ('"new_team_member".prettyType', prettyType('new_team_member')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, value) in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacing4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: AppText(
                    label,
                    textSize: TextSize.small_12,
                    textColor: AppColors.darkGreyTextColor,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: AppText(
                    value,
                    textSize: TextSize.small_12,
                    textWeight: TextWeight.w500,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ValidatorSection extends StatelessWidget {
  const _ValidatorSection();

  @override
  Widget build(BuildContext context) {
    final cases = <(String, String?)>[
      ('emailValidator("foo")', _validators.emailValidator('foo')),
      ('emailValidator("a@b.co")', _validators.emailValidator('a@b.co')),
      ('passwordValidator("short")', _validators.passwordValidator('short')),
      ('passwordValidator("StrongPass1!")', _validators.passwordValidator('StrongPass1!')),
      ('otpValidator("123")', _validators.otpValidator('123')),
      ('otpValidator("123456")', _validators.otpValidator('123456')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (input, output) in cases)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacing4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: AppText(
                    input,
                    textSize: TextSize.small_12,
                    textColor: AppColors.darkGreyTextColor,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: AppText(
                    output ?? 'valid ✓',
                    textSize: TextSize.small_12,
                    textWeight: TextWeight.w500,
                    textAlign: TextAlign.right,
                    textColor: output == null ? AppColors.toastSuccess : AppColors.toastError,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MiscSection extends StatelessWidget {
  const _MiscSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ScreenHeader(
          title: 'Section title',
          subtitle: 'Subtitle goes below in muted text',
        ),
        SizedBox(height: AppDimensions.spacing8.h),
        const Row(
          children: [
            Expanded(
              child: BottomBorderContainer(
                isSelected: true,
                color: AppColors.primaryColor,
                padding: EdgeInsets.all(AppDimensions.spacing12),
                child: Center(child: AppText('Selected')),
              ),
            ),
            SizedBox(width: AppDimensions.spacing8),
            Expanded(
              child: BottomBorderContainer(
                isSelected: false,
                color: AppColors.dividerAndBorderColor,
                padding: EdgeInsets.all(AppDimensions.spacing12),
                child: Center(child: AppText('Idle')),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing16.h),
        const SizedBox(
          height: 120,
          child: AppEmptyState(
            title: 'Nothing here yet',
            subtitle: 'AppEmptyState — drop into StateSwitch.onEmpty',
          ),
        ),
      ],
    );
  }
}
