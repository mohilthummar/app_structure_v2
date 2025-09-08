import 'package:flutter/material.dart';

import '../../../packages/country_code/countries.dart';
import '../../core/themes/app_text.dart';
import '../../data/constants/app_colors.dart';

class DropDownItems extends StatelessWidget {
  final Country item;
  const DropDownItems({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText(item.flag, textSize: TextSize.title_18),
        const SizedBox(width: 10),
        Expanded(child: AppText(item.localizedName('en'), textColor: AppColors.darkGreyTextColor)),
        const SizedBox(width: 10),
        AppText("+${item.dialCode}", textSize: TextSize.medium_14, textWeight: TextWeight.w500),
      ],
    );
  }
}
