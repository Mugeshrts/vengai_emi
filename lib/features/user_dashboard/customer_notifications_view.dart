import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/service/emi_helper.dart';
import 'customer_controller.dart';
import 'customer_pay_emi_view.dart';

class CustomerNotificationsView extends StatelessWidget {
  const CustomerNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('EMI Reminders & Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: controller.markAllRemindersAsRead,
            child: const Text('Mark all read', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Obx(() {
        final reminders = controller.reminders;

        if (reminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text(
                  'No reminders at this time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You will receive reminders when an EMI due date approaches.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final r = reminders[index];
            final relatedInst = controller.installments.firstWhereOrNull((i) => i.id == r.installmentId);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: r.isRead ? Colors.white : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: r.isRead ? AppColors.border : AppColors.primary.withAlpha(80),
                  width: r.isRead ? 1 : 1.5,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                onTap: () => controller.markReminderAsRead(r.id),
                leading: CircleAvatar(
                  backgroundColor: r.isRead ? AppColors.surfaceVariant : AppColors.primary.withAlpha(20),
                  child: Icon(
                    r.title.contains('✓')
                        ? Icons.check_circle_outline
                        : (r.title.contains('!') ? Icons.error_outline : Icons.notifications_active),
                    color: r.title.contains('✓')
                        ? AppColors.paid
                        : (r.title.contains('!') ? AppColors.overdue : AppColors.primary),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        r.title,
                        style: TextStyle(
                          fontWeight: r.isRead ? FontWeight.w600 : FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!r.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      r.message,
                      style: const TextStyle(fontSize: 13, height: 1.3, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          EmiHelper.formatDate(r.createdAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        if (relatedInst != null && !relatedInst.isPaid) ...[
                          ElevatedButton(
                            onPressed: () {
                              controller.markReminderAsRead(r.id);
                              Get.to(() => CustomerPayEmiView(installment: relatedInst));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('PAY EMI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
