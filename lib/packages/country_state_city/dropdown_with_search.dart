import 'package:flutter/material.dart';

import '../../data/constants/app_colors.dart';

class DropdownWithSearch<T> extends StatelessWidget {
  final String? label;
  final TextStyle? labelStyle;
  final T selected;
  final TextStyle? selectedItemStyle;

  final EdgeInsets? boxPadding;
  final BoxDecoration? boxDecoration;
  final Color? boxColor;
  final Color? boxDisabledColor;

  final List items;
  final String dropdownTitle;
  final TextStyle? dropdownTitleStyle;
  final String dropdownHintText;
  final TextStyle? dropdownItemStyle;
  final double? searchBarRadius;
  final double? dialogRadius;

  final bool? disabled;
  final Function onChanged;

  const DropdownWithSearch({super.key, this.label, this.labelStyle, required this.selected, this.selectedItemStyle, this.boxPadding, this.boxDecoration, this.boxColor, this.boxDisabledColor, required this.items, required this.dropdownTitle, this.dropdownTitleStyle, required this.dropdownHintText, this.dropdownItemStyle, this.searchBarRadius, this.dialogRadius, this.disabled = false, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? "",
          style: labelStyle ?? const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        AbsorbPointer(
          absorbing: disabled!,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SearchDialog(placeHolder: dropdownHintText, title: dropdownTitle, searchInputRadius: searchBarRadius, dialogRadius: dialogRadius, titleStyle: dropdownTitleStyle, itemStyle: dropdownItemStyle, items: items),
              ).then((value) => onChanged(value));
            },
            child: Container(
              // height: MediaQuery.of(context).size.height < 799 ? 43.h : 39.h ,
              padding: boxPadding ?? const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: boxDecoration == null
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey),
                      color: disabled! ? boxDisabledColor ?? Colors.grey.withAlpha((255.0 * .15).round()) : boxColor ?? Colors.white,
                    )
                  : boxDecoration!.copyWith(color: disabled! ? boxDisabledColor ?? Colors.grey.withAlpha((255.0 * .15).round()) : boxColor ?? Colors.white),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selected.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: selectedItemStyle!.copyWith(color: disabled! ? AppColors.darkGreyTextColor : AppColors.black, fontWeight: selected == dropdownTitle ? FontWeight.w400 : FontWeight.w500),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchDialog extends StatefulWidget {
  final String title;
  final String placeHolder;
  final List items;
  final TextStyle? titleStyle;
  final TextStyle? itemStyle;
  final double? searchInputRadius;

  final double? dialogRadius;

  const SearchDialog({super.key, required this.title, required this.placeHolder, required this.items, this.titleStyle, this.searchInputRadius, this.dialogRadius, this.itemStyle});

  @override
  SearchDialogState createState() => SearchDialogState();
}

class SearchDialogState<T> extends State<SearchDialog> {
  TextEditingController textController = TextEditingController();
  late List filteredList;

  @override
  void initState() {
    filteredList = widget.items;
    textController.addListener(() {
      setState(() {
        if (textController.text.isEmpty) {
          filteredList = widget.items;
        } else {
          filteredList = widget.items.where((element) => element.toString().toLowerCase().contains(textController.text.toLowerCase())).toList();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: widget.dialogRadius != null ? BorderRadius.circular(widget.dialogRadius!) : BorderRadius.circular(16)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 2.2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(widget.title, style: widget.titleStyle ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: false,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(Icons.my_location_rounded, size: 20),
                  hintText: widget.placeHolder,
                  hintStyle: widget.itemStyle == null ? const TextStyle(fontSize: 12, color: Colors.grey) : widget.itemStyle!.copyWith(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(widget.searchInputRadius != null ? Radius.circular(widget.searchInputRadius!) : const Radius.circular(5)),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(widget.searchInputRadius != null ? Radius.circular(widget.searchInputRadius!) : const Radius.circular(5)),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                ),
                style: widget.itemStyle ?? const TextStyle(fontSize: 12, color: Colors.black),
                controller: textController,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context, filteredList[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 20),
                      child: Text(filteredList[index].toString(), style: widget.itemStyle ?? const TextStyle(fontSize: 14)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
