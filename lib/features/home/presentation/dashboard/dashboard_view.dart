import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/i18n/i18n_keys.dart';
import 'package:app_structure/core/routing/route_names.dart';
import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/features/home/presentation/dashboard/dashboard_controller.dart';
import 'package:app_structure/shared/widgets/offline_banner.dart';
import 'package:app_structure/shared/widgets/state_switch.dart';

/// Dashboard list view. Shows the canonical full lifecycle of a
/// list-backed screen: loading → empty → error → success (with
/// pagination). Copy this as the starting point for new list screens.
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.dashboard.tr),
        actions: [
          IconButton(
            tooltip: I18n.profile.tr,
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed(RouteNames.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: Obx(
              () => StateSwitch(
                state: controller.state.value,
                onLoading: (_) => const Center(child: CircularProgressIndicator()),
                onEmpty: (_) => _EmptyView(onRetry: controller.onRefresh),
                onError: (_) => _ErrorView(
                  message: controller.errorMessage.value,
                  onRetry: controller.onRefresh,
                ),
                onSuccess: (_) => _List(controller: controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _List extends StatefulWidget {
  const _List({required this.controller});

  final DashboardController controller;

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      widget.controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.controller.onRefresh,
      child: Obx(
        () => ListView.separated(
          controller: _scroll,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16.w,
            vertical: AppDimensions.spacing12.h,
          ),
          itemCount: widget.controller.items.length + (widget.controller.hasMore ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: AppDimensions.spacing12.h),
          itemBuilder: (context, index) {
            if (index >= widget.controller.items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final item = widget.controller.items[index];
            return Card(
              child: ListTile(
                title: AppText(item.title, textWeight: TextWeight.w600),
                subtitle: item.subtitle == null ? null : AppText(item.subtitle!),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: AppColors.gray400),
          SizedBox(height: AppDimensions.spacing12.h),
          AppText(I18n.empty.tr, textSize: TextSize.medium_14),
          SizedBox(height: AppDimensions.spacing16.h),
          OutlinedButton(onPressed: onRetry, child: Text(I18n.retry.tr)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacing24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppDimensions.spacing12.h),
            AppText.multiLine(
              message.isEmpty ? I18n.error.tr : message,
              textAlign: TextAlign.center,
              textSize: TextSize.medium_14,
            ),
            SizedBox(height: AppDimensions.spacing16.h),
            OutlinedButton(onPressed: onRetry, child: Text(I18n.retry.tr)),
          ],
        ),
      ),
    );
  }
}
