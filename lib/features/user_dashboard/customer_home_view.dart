import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/service/emi_helper.dart';
import 'customer_controller.dart';
import 'customer_pay_emi_view.dart';
import 'customer_notifications_view.dart';

class CustomerHomeView extends StatelessWidget {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final user = controller.currentUser;
              final name = user?.name.split(' ').first ?? 'Customer';
              return Text(
                'Hello, $name 👋',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              );
            }),
            const Text(
              'VENGAI MART Customer Portal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          // Reminders Bell Icon with Badge
          Obx(() {
            final unread = controller.unreadRemindersCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 28, color: AppColors.textPrimary),
                  tooltip: 'Reminders',
                  onPressed: () => Get.to(() => const CustomerNotificationsView()),
                ),
                if (unread > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$unread',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final accounts = controller.customerAccounts;
        final nextInst = controller.nextInstallment;
        final nextStatus = controller.nextEmiStatus;
        final days = controller.daysRemainingForNextEmi;
        final nextAccount = nextInst != null ? controller.getAccountForInstallment(nextInst) : null;

        return RefreshIndicator(
          onRefresh: () async => controller.loadCustomerData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. MULTI-PRODUCT SWITCHER CHIPS (If customer has > 1 product)
                if (controller.hasMultipleProducts) ...[
                  Row(
                    children: [
                      const Icon(Icons.layers_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Your Purchased Products (${accounts.length}):',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 'ALL' chip
                        ChoiceChip(
                          label: Text('⭐ All Products (${accounts.length})'),
                          selected: controller.selectedAccountId.value == 'ALL',
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: controller.selectedAccountId.value == 'ALL' ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          onSelected: (val) {
                            if (val) controller.selectedAccountId.value = 'ALL';
                          },
                        ),
                        const SizedBox(width: 8),
                        ...accounts.map((acc) {
                          final isSelected = controller.selectedAccountId.value == acc.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              avatar: Icon(
                                acc.category.toLowerCase().contains('audio') ? Icons.speaker : Icons.tv,
                                size: 16,
                                color: isSelected ? Colors.white : AppColors.primary,
                              ),
                              label: Text(acc.productName.split(' ').take(3).join(' ')),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              onSelected: (val) {
                                if (val) controller.selectedAccountId.value = acc.id;
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else if (accounts.isNotEmpty) ...[
                  // Single product header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                accounts.first.productName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Price: ${EmiHelper.formatCurrency(accounts.first.productPrice)} • ${accounts.first.emiMonths} Months EMI',
                                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // 2. HERO CARD: NEXT EMI (Focused on immediate next payment)
                if (nextInst != null) ...[
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF172554)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(80),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'NEXT EMI',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                if (nextAccount != null) ...[
                                  Text(
                                    nextAccount.productName,
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.getStatusColor(nextStatus),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                EmiHelper.getStatusSymbol(nextStatus),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          EmiHelper.formatCurrency(nextInst.amount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Due on: ${EmiHelper.formatLongDate(nextInst.dueDate)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          days < 0
                              ? '${days.abs()} days overdue!'
                              : (days == 0 ? 'Due Today' : '$days days remaining'),
                          style: TextStyle(
                            color: days < 0
                                ? Colors.redAccent.shade100
                                : (days <= 7 ? Colors.amberAccent : Colors.white70),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Prominent PAY EMI Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => Get.to(() => CustomerPayEmiView(installment: nextInst)),
                            icon: const Icon(Icons.flash_on, size: 24),
                            label: const Text(
                              'PAY EMI',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // All EMIs Paid Congratulatory Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.paidBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.paid.withAlpha(100)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.celebration, color: AppColors.paid, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'All EMIs Completed! 🎉',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.paid,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'You have no pending installments. Thank you for shopping with VENGAI MART!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // 3. IF MULTI-PRODUCT: ALL ACTIVE PRODUCTS SUMMARY LIST
                if (controller.hasMultipleProducts && controller.selectedAccountId.value == 'ALL') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'MY ACTIVE PRODUCTS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${controller.activeAccounts.length} Active',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...controller.customerAccounts.map((acc) {
                    final accInsts = controller.allInstallments.where((i) => i.emiAccountId == acc.id).toList();
                    final nextUnpaid = accInsts.firstWhereOrNull((i) => !i.isPaid);
                    final status = nextUnpaid != null ? EmiHelper.computeInstallmentStatus(nextUnpaid) : 'COMPLETED';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.surfaceVariant,
                            child: Icon(
                              acc.category.toLowerCase().contains('audio') ? Icons.speaker : Icons.tv,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  acc.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Purchased: ${EmiHelper.formatDate(acc.startDate)} • Balance: ${EmiHelper.formatCurrency(acc.remainingAmount)}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                if (nextUnpaid != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Next: ${EmiHelper.formatDate(nextUnpaid.dueDate)} (${EmiHelper.formatCurrency(nextUnpaid.amount)})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.getStatusColor(status),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (nextUnpaid != null) ...[
                            ElevatedButton(
                              onPressed: () => Get.to(() => CustomerPayEmiView(installment: nextUnpaid)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('PAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.paidBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('PAID', style: TextStyle(color: AppColors.paid, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // 4. Customer Financial Summary
                Text(
                  controller.selectedAccountId.value == 'ALL' ? 'TOTAL EMI COMMITMENT' : 'PRODUCT EMI SUMMARY',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryMetric(
                              'Total Value',
                              EmiHelper.formatCurrency(controller.totalEmiValue),
                              AppColors.textPrimary,
                            ),
                          ),
                          Container(width: 1, height: 40, color: AppColors.border),
                          Expanded(
                            child: _buildSummaryMetric(
                              'Paid',
                              EmiHelper.formatCurrency(controller.paidAmount),
                              AppColors.paid,
                            ),
                          ),
                          Container(width: 1, height: 40, color: AppColors.border),
                          Expanded(
                            child: _buildSummaryMetric(
                              'Remaining',
                              EmiHelper.formatCurrency(controller.remainingAmount),
                              AppColors.overdue,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      // Progress Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.selectedAccountId.value == 'ALL' ? 'Overall Progress' : 'Installments Paid',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${controller.paidCount} of ${controller.totalCount} EMIs Paid',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: controller.progressFraction,
                          minHeight: 12,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.paid),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Navigation Tiles
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => controller.selectedNavIndex.value = 1, // switch to My EMI
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.calendar_month, color: AppColors.primary, size: 28),
                              SizedBox(height: 8),
                              Text(
                                'View Schedule',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text('All months & dates', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => controller.selectedNavIndex.value = 2, // switch to History
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.receipt_long, color: AppColors.paid, size: 28),
                              SizedBox(height: 8),
                              Text(
                                'Payment History',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text('Receipts & records', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryMetric(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
