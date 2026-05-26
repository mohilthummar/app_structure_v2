import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/shared/models/drop_down_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:app_structure/core/utils/app_loader.dart';

/// Single-select dropdown that takes a list of [DropDownModel]. The
/// dropdown arrow flips to a spinner while [isLoading] is `true` — use
/// that while async-loading options instead of disabling the widget.
///
/// Usage:
/// ```dart
/// AppDropDown(
///   label: 'Country',
///   hintText: 'Select a country',
///   items: controller.countries,
///   value: controller.selectedCountry.value,
///   onChanged: controller.onCountryChanged,
/// );
/// ```
class AppDropDown extends StatelessWidget {
  final List<DropDownModel> items;
  final DropDownModel? value;
  final ValueChanged<DropDownModel?>? onChanged;
  final String? hintText;
  final String? label;
  final String? prefixIcon;

  /// Show a spinner in place of the dropdown arrow. Use while options
  /// are loading rather than disabling the widget entirely.
  final bool isLoading;

  final String? Function(DropDownModel?)? validator;
  final Color? hintTextColor;

  const AppDropDown({super.key, required this.items, this.value, this.onChanged, this.hintText, this.label, this.prefixIcon, this.isLoading = false, this.validator, this.hintTextColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: AppText(label!, textSize: TextSize.small_12, textColor: AppColors.darkGreyTextColor),
          ),

        // Dropdown Button
        Theme(
          data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
          child: DropdownButtonFormField2<DropDownModel>(
            isExpanded: true,
            isDense: true,
            alignment: Alignment.centerLeft,
            value: value,
            validator: validator,
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
                color: AppColors.containerFillColor,
              ),
              padding: EdgeInsets.zero,
            ),
            hint: Text(
              hintText ?? '',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14,
                color: hintTextColor ?? AppColors.darkGreyTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem<DropDownModel>(
                    value: item,
                    child: AppText(item.title ?? '', textWeight: TextWeight.w500),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, color: AppColors.black, fontWeight: FontWeight.w500),
            iconStyleData: IconStyleData(
              icon: isLoading ? const CircularLoader() : const Icon(Icons.keyboard_arrow_down, color: AppColors.darkGreyTextColor),
              iconSize: 24,
            ),
            menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 10)),
            decoration: InputDecoration(
              fillColor: AppColors.white,
              filled: true,
              isDense: true,
              errorStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14,
                color: AppColors.darkGreyTextColor,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: prefixIcon == null ? null : Padding(padding: const EdgeInsets.only(right: 0, left: 16), child: SvgPicture.asset(prefixIcon!)),
              prefixIconConstraints: prefixIcon == null ? null : BoxConstraints.tight(const Size(40, 48)),
              contentPadding: const EdgeInsets.all(14).copyWith(left: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),
                borderSide: const BorderSide(color: AppColors.dividerAndBorderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),
                borderSide: const BorderSide(color: AppColors.disableColor, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
