import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/service/emi_helper.dart';
import '../../core/models/chit_fund_model.dart';
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

        // Calculate late penalty (₹1/day per ₹1,000 for each day overdue)
        final penaltyCalc = nextInst != null
            ? EmiHelper.calculateLatePenalty(amount: nextInst.amount, dueDateStr: nextInst.dueDate)
            : {'isPenaltyApplicable': false, 'penaltyAmount': 0.0, 'totalDue': 0.0, 'daysOverdue': 0};
        final bool hasPenalty = penaltyCalc['isPenaltyApplicable'] == true;
        final double penaltyAmount = penaltyCalc['penaltyAmount'] as double;
        final double totalDue = penaltyCalc['totalDue'] as double;
        final int overdueDays = penaltyCalc['daysOverdue'] as int;

        final bool isPureChitFundCustomer = accounts.isEmpty && controller.customerChitFunds.isNotEmpty;

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
                          EmiHelper.formatCurrency(hasPenalty ? totalDue : nextInst.amount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (hasPenalty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withAlpha(45),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.redAccent.withAlpha(90)),
                            ),
                            child: Text(
                              'Base: ${EmiHelper.formatCurrency(nextInst.amount)} + Late Fee: ${EmiHelper.formatCurrency(penaltyAmount)} ($overdueDays days overdue)',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
                            label: Text(
                              hasPenalty ? 'PAY ${EmiHelper.formatCurrency(totalDue)}' : 'PAY EMI',
                              style: const TextStyle(
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
                ] else if (isPureChitFundCustomer) ...[
                  // Pure Chit Fund Customer Top Hero Card!
                  _buildPureChitFundHeroCard(context, controller),
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
                if (isPureChitFundCustomer) ...[
                  _buildPureChitFundSummaryCard(controller),
                ] else ...[
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
                ],

                // Customer's Enrolled Chit Funds Section (if not pure chit fund or multiple chit funds)
                if (controller.customerChitFunds.isNotEmpty && (!isPureChitFundCustomer || controller.customerChitFunds.length > 1)) ...[
                  const SizedBox(height: 24),
                  _buildCustomerChitFundsSection(context, controller),
                ],

                const SizedBox(height: 20),

                // Quick Navigation Tiles
                if (isPureChitFundCustomer) ...[
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => controller.selectedNavIndex.value = 1,
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
                                Icon(Icons.savings_rounded, color: Color(0xFF0F766E), size: 28),
                                SizedBox(height: 8),
                                Text(
                                  'My Chit Schemes',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(height: 2),
                                Text('Contributions & plans', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => controller.selectedNavIndex.value = 2,
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
                ] else ...[
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
                ],

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

  Widget _buildCustomerChitFundsSection(BuildContext context, CustomerController controller) {
    final cId = controller.customerId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.savings_rounded, color: Color(0xFF0F766E), size: 20),
                SizedBox(width: 8),
                Text(
                  'My Chit Funds',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${controller.customerChitFunds.length} Enrolled',
                style: const TextStyle(
                  color: Color(0xFF0F766E),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...controller.customerChitFunds.map((ChitFund fund) {
          final member = fund.members.firstWhereOrNull((m) => m.customerId == cId);
          if (member == null) return const SizedBox.shrink();

          final progress = (member.monthsPaid / fund.durationMonths).clamp(0.0, 1.0);
          final bool isComplete = member.monthsPaid >= fund.durationMonths;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F766E).withAlpha(20),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    fund.category,
                                    style: const TextStyle(
                                      color: Color(0xFF0F766E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Ticket #${member.ticketNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fund.schemeName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isComplete ? Colors.green.shade50 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isComplete ? 'MATURED' : 'MONTH ${member.monthsPaid + 1}/${fund.durationMonths}',
                          style: TextStyle(
                            color: isComplete ? Colors.green.shade700 : const Color(0xFF0F766E),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Value', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            EmiHelper.formatCurrency(fund.totalValue),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Paid so far', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            EmiHelper.formatCurrency(member.totalContributed),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.paid),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Monthly Due', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            EmiHelper.formatCurrency(fund.monthlyContribution),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F766E)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                    ),
                  ),
                  if (fund.bonusDescription.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.card_giftcard, color: Colors.amber, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Bonus Reward: ${fund.bonusDescription}',
                            style: TextStyle(color: Colors.brown.shade800, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!isComplete) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await controller.payCustomerChitContribution(fund: fund, member: member);
                        },
                        icon: const Icon(Icons.flash_on, size: 16),
                        label: Text(
                          'PAY MONTH #${member.monthsPaid + 1} (${EmiHelper.formatCurrency(fund.monthlyContribution)})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPureChitFundHeroCard(BuildContext context, CustomerController controller) {
    final fund = controller.customerChitFunds.first;
    final member = fund.members.firstWhereOrNull((m) => m.customerId == controller.customerId);
    final isComplete = member != null && member.monthsPaid >= fund.durationMonths;
    final int nextMonth = member != null ? member.monthsPaid + 1 : 1;
    final double progress = member != null ? (member.monthsPaid / fund.durationMonths).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF115E59), Color(0xFF134E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withAlpha(80),
            blurRadius: 16,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.savings_rounded, color: Colors.amberAccent, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'ACTIVE CHIT FUND SAVINGS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              if (member != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isComplete ? Colors.green.shade400 : Colors.amber.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isComplete ? 'MATURED' : 'Ticket #${member.ticketNumber}',
                    style: TextStyle(
                      color: isComplete ? Colors.white : Colors.brown.shade900,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            fund.schemeName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.category_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                fund.category,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.event_repeat, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                '${fund.durationMonths} Months Plan',
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                EmiHelper.formatCurrency(fund.monthlyContribution),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isComplete ? 'Fully Completed' : 'Monthly Due (Month #$nextMonth)',
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(40),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                member != null ? '${member.monthsPaid} of ${fund.durationMonths} Months Saved' : '',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '${(progress * 100).toInt()}% Completed',
                style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (fund.bonusDescription.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.amberAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bonus Gift: ${fund.bonusDescription}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!isComplete && member != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await controller.payCustomerChitContribution(fund: fund, member: member);
                },
                icon: const Icon(Icons.flash_on, size: 22),
                label: Text(
                  'PAY MONTH #$nextMonth (${EmiHelper.formatCurrency(fund.monthlyContribution)})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F766E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPureChitFundSummaryCard(CustomerController controller) {
    double totalChitValue = 0;
    double totalPaid = 0;
    int totalMonths = 0;
    int totalPaidMonths = 0;

    for (final fund in controller.customerChitFunds) {
      final m = fund.members.firstWhereOrNull((member) => member.customerId == controller.customerId);
      if (m != null) {
        totalChitValue += fund.totalValue;
        totalPaid += m.totalContributed;
        totalMonths += fund.durationMonths;
        totalPaidMonths += m.monthsPaid;
      }
    }
    final remaining = (totalChitValue - totalPaid).clamp(0.0, double.infinity);
    final progress = totalMonths > 0 ? (totalPaidMonths / totalMonths).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHIT FUND SAVINGS SUMMARY',
          style: TextStyle(
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
                      'Total Chit Value',
                      EmiHelper.formatCurrency(totalChitValue),
                      AppColors.textPrimary,
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Total Saved',
                      EmiHelper.formatCurrency(totalPaid),
                      const Color(0xFF0F766E),
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Remaining',
                      EmiHelper.formatCurrency(remaining),
                      AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall Contribution Progress',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$totalPaidMonths of $totalMonths Months Saved',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
