import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/constants/app_colors.dart';
import '../../packages/country_code/countries.dart';
import '../../core/themes/app_style.dart';
import '../../core/themes/app_text.dart';
import 'drop_down_items.dart';

class CountryCodePicker extends StatelessWidget {
  final TextEditingController? searchController;
  final List<Country>? filteredCountries;
  final void Function(String)? onChanged;
  final void Function(int)? onCountrySelect;

  const CountryCodePicker({
    super.key,
    this.searchController,
    this.filteredCountries,
    this.onChanged,
    this.onCountrySelect,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 3,
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.all(defaultPadding),
      child: Container(
        height: Get.height * .6,
        decoration: BoxDecoration(
          color: AppColors.containerFillColor,
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 6, left: 16, bottom: 4),
              child: Row(
                children: [
                  const AppText(
                    "Choose Country",
                    textSize: TextSize.large_16,
                    textWeight: TextWeight.w500,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.done,
                onChanged: onChanged ?? (searchValue) {},
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Search Country",
                  helperStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12, color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            Expanded(
              child: Obx(() => ListView.separated(
                    itemCount: filteredCountries!.length,
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) => InkWell(
                      onTap: () => onCountrySelect!(index),
                      child: DropDownItems(item: filteredCountries![index]),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
