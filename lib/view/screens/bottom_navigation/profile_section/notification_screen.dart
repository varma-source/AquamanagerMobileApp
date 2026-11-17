import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/notification_model.dart';
import 'package:superapp/services/profileService.dart';
import 'package:superapp/view_model/api_controllers/notification_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _profileController = Get.find<ProfileService>();
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);
  final Color _bg = const Color(0xFFF7F9FB);

  // ✅ Controller
  late final NotificationController _notifController;

  // ✅ Local seen overrides
  final Set<String> _locallySeen = {};

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<NotificationController>()) {
      _notifController = Get.find<NotificationController>();
    } else {
      _notifController = Get.put(NotificationController(Get.find()));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifController.fetchnotificationsdata();
    });
  }

  bool _isSeen(NotifResult n) {
    if (n.id != null && _locallySeen.contains(n.id)) return true;
    return n.seen == true;
  }

  void _markLocallySeen(NotifResult n) {
    if (n.id == null) return;
    setState(() => _locallySeen.add(n.id!));
  }

  Future<void> _confirmAndDelete(NotifResult n) async {
    if (n.id == null || n.id!.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE53935),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                CustomText(
                  textName: "delete_notification_q".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: AppColors.blackColor,
                  fontSize: 15,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                CustomText(
                  textName: "delete_notification_msg".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade600,
                  fontSize: 11,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            foregroundColor: Colors.grey.shade700,
                          ),
                          child: CustomText(
                            textName: "cancel".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: CustomText(
                            textName: "delete".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _profileController.userdeletenotification(id: n.id!);

      _notifController.fetchnotificationsdata();

      if (Get.context != null) {
        Get.snackbar(
          "deleted".tr,
          "notification_removed".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _primary,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      debugPrint("userdeletenotification error: $e");
      if (Get.context != null) {
        Get.snackbar(
          "failed".tr,
          "could_not_delete".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    }
  }

  _NotifStyle _resolveStyle(NotifResult n) {
    if (n.staffRequestAdvanceId != null &&
        n.staffRequestAdvanceId!.isNotEmpty) {
      return _NotifStyle(
        icon: Icons.request_page_outlined,
        color: const Color(0xFF6A1B9A),
        bg: const Color(0xFFEDE7F6),
      );
    }
    if (n.logFeedingId != null && n.logFeedingId!.isNotEmpty) {
      return _NotifStyle(
        icon: Icons.set_meal_outlined,
        color: const Color(0xFF2E7D32),
        bg: const Color(0xFFE8F5E9),
      );
    }
    if ((n.medicineUsageId != null && n.medicineUsageId!.isNotEmpty) ||
        (n.medicineId != null && n.medicineId!.isNotEmpty)) {
      return _NotifStyle(
        icon: Icons.medication_outlined,
        color: const Color(0xFFE53935),
        bg: const Color(0xFFFFEBEE),
      );
    }
    if (n.harvestId != null && n.harvestId!.isNotEmpty) {
      return _NotifStyle(
        icon: Icons.check_circle_outline,
        color: const Color(0xFF2E7D32),
        bg: const Color(0xFFE8F5E9),
      );
    }
    if (n.purchaseId != null && n.purchaseId!.isNotEmpty) {
      return _NotifStyle(
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFFF57C00),
        bg: const Color(0xFFFFF3E0),
      );
    }
    if (n.staffExpenseId != null && n.staffExpenseId!.isNotEmpty) {
      return _NotifStyle(
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF0277BD),
        bg: const Color(0xFFE3F2FD),
      );
    }
    if (n.staffId != null && n.staffId!.isNotEmpty) {
      return _NotifStyle(
        icon: Icons.person_add_alt,
        color: const Color(0xFF7B1FA2),
        bg: const Color(0xFFEDE7F6),
      );
    }

    final text = "${n.title ?? ""} ${n.description ?? ""}".toLowerCase();
    if (text.contains("feed")) {
      return _NotifStyle(
        icon: Icons.set_meal_outlined,
        color: const Color(0xFF2E7D32),
        bg: const Color(0xFFE8F5E9),
      );
    }
    if (text.contains("medicine") || text.contains("med ")) {
      return _NotifStyle(
        icon: Icons.medication_outlined,
        color: const Color(0xFFE53935),
        bg: const Color(0xFFFFEBEE),
      );
    }
    if (text.contains("harvest")) {
      return _NotifStyle(
        icon: Icons.check_circle_outline,
        color: const Color(0xFF2E7D32),
        bg: const Color(0xFFE8F5E9),
      );
    }
    if (text.contains("stock") || text.contains("low")) {
      return _NotifStyle(
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFF57C00),
        bg: const Color(0xFFFFF3E0),
      );
    }
    if (text.contains("advance")) {
      return _NotifStyle(
        icon: Icons.request_page_outlined,
        color: const Color(0xFF6A1B9A),
        bg: const Color(0xFFEDE7F6),
      );
    }

    return _NotifStyle(
      icon: Icons.notifications_outlined,
      color: _primary,
      bg: _primary.withOpacity(0.1),
    );
  }

  String _formatTime(NotifResult n) {
    if (n.time != null && n.time!.trim().isNotEmpty) return n.time!;

    final dt = n.date ?? n.logCreatedDate;
    if (dt == null) return "—";

    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? "PM" : "AM";
    final min = dt.minute.toString().padLeft(2, '0');
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$min $ampm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(),
                  CustomText(
                    textName: "notifications".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 16,
                  ),
                  const Spacer(),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),

            Expanded(
              child: Obx(() {
                final data = _notifController.notificationDataResponce.value;
                final items = data.notifResult ?? [];

                if (data.success == null && items.isEmpty) {
                  return _buildLoading();
                }

                if (items.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: _primary,
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 200));
                    _notifController.fetchnotificationsdata();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = items[index];
                      return _buildNotificationCard(n);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotifResult n) {
    final bool isSeen = _isSeen(n);
    final style = _resolveStyle(n);

    final title = (n.title ?? "").trim().isEmpty
        ? "notification".tr
        : n.title!;
    final desc = (n.description ?? "").trim();

    return GestureDetector(
      onTap: () => _markLocallySeen(n),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSeen ? Colors.white : _primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSeen ? Colors.grey.shade200 : _primary.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: style.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(style.icon, color: style.color, size: 20),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          textName: title,
                          fontFamily: FontFamily.poppins,
                          fontWeightType:
                              isSeen
                                  ? FontWeightType.semiBold
                                  : FontWeightType.bold,
                          textColor: AppColors.blackColor,
                          fontSize: 13,
                        ),
                      ),
                      if (!isSeen)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () => _confirmAndDelete(n),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFE53935),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    CustomText(
                      textName: desc,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade700,
                      fontSize: 11,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 11,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      CustomText(
                        textName: _formatTime(n),
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder:
          (_, __) => Container(
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: _primary,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 200));
        _notifController.fetchnotificationsdata();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primary.withOpacity(0.1),
                      border: Border.all(
                        color: _primary.withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.notifications_off_outlined,
                      color: _primary,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomText(
                    textName: "no_notifications".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 18,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    textName: "all_caught_up".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: Colors.grey.shade600,
                    fontSize: 12,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => _notifController.fetchnotificationsdata(),
                    icon: Icon(Icons.refresh, color: _primary, size: 18),
                    label: CustomText(
                      textName: "refresh".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.semiBold,
                      textColor: _primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small helper class for icon/color resolution.
class _NotifStyle {
  final IconData icon;
  final Color color;
  final Color bg;
  _NotifStyle({required this.icon, required this.color, required this.bg});
}