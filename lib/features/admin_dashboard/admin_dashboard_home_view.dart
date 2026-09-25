import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/service/emi_helper.dart';
import '../../core/models/emi_installment_model.dart';
import '../../core/models/emi_account_model.dart';
import 'admin_controller.dart';
import 'create_emi_view.dart';
import 'emi_details_view.dart';

class AdminDashboardHomeView extends StatelessWidget {
  const AdminDashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good Day, Admin',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.paid,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'VENGAI MART',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: 'Refresh Data',
            onPressed: () {
              controller.loadAllData();
              Get.snackbar(
                'Data Refreshed',
                'Refreshed metrics & latest status',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 1),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateEmiView()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('CREATE EMI', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        final upcomingList = controller.upcomingInstallmentsWithDetails;
        final overdueList = controller.overdueInstallmentsWithDetails;

        return RefreshIndicator(
          onRefresh: () async => controller.loadAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Collection Summary Card (Requirement 18)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(60),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'COLLECTION SUMMARY',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${(controller.collectionProgress * 100).toStringAsFixed(1)}% Collected',
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
                        EmiHelper.formatCurrency(controller.collectedAmount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total EMI Value: ${EmiHelper.formatCurrency(controller.totalEmiValue)}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: controller.collectionProgress,
                          minHeight: 10,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining: ${EmiHelper.formatCurrency(controller.remainingAmount)}',
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Active: ${controller.activeEmiCount} Accounts',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 2. Metrics Grid (Requirement 17)
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.45,
                  children: [
                    _buildMetricCard(
                      title: "Today's Collection",
                      value: EmiHelper.formatCurrency(controller.todayCollection),
                      icon: Icons.today,
                      color: AppColors.paid,
                      bgColor: AppColors.paidBg,
                    ),
                    _buildMetricCard(
                      title: 'Month Collection',
                      value: EmiHelper.formatCurrency(controller.thisMonthCollection),
                      icon: Icons.calendar_month,
                      color: AppColors.primary,
                      bgColor: AppColors.surfaceVariant,
                    ),
                    _buildMetricCard(
                      title: 'Total Customers',
                      value: '${controller.totalCustomers}',
                      icon: Icons.people_outline,
                      color: Colors.indigo,
                      bgColor: Colors.indigo.shade50,
                    ),
                    _buildMetricCard(
                      title: 'Overdue EMIs',
                      value: '${controller.overdueCount}',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.overdue,
                      bgColor: AppColors.overdueBg,
                      subtitle: EmiHelper.formatCurrency(controller.totalOverdueAmount),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // 3. Prominent OVERDUE PAYMENTS Section (Requirement 30)
                if (overdueList.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.overdueBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.error_outline, color: AppColors.overdue, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'OVERDUE PAYMENTS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.overdue,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${overdueList.length} Accounts',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.overdue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...overdueList.map((item) {
                    final inst = item['installment'] as EmiInstallment;
                    final acc = item['account'] as EmiAccount;
                    final daysOverdue = item['daysOverdue'] as int;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.overdue, width: 1.2),
                      ),
                      color: AppColors.overdueBg.withAlpha(80),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.overdue,
                          child: const Icon(Icons.priority_high, color: Colors.white, size: 20),
                        ),
                        title: Text(
                          acc.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          '${acc.productName} • $daysOverdue days overdue\nDue: ${EmiHelper.formatDate(inst.dueDate)}',
                          style: const TextStyle(fontSize: 13, height: 1.3),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              EmiHelper.formatCurrency(inst.amount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.overdue,
                              ),
                            ),
                            const Text(
                              '! OVERDUE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.overdue,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Get.to(() => EmiDetailsView(emiAccountId: acc.id)),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // 4. UPCOMING EMI Section (due within 7 days) (Requirement 29)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.dueSoonBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.schedule, color: AppColors.dueSoon, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'UPCOMING EMI (Next 7 Days)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (upcomingList.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'No upcoming EMI due in the next 7 days.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                  ),
                ] else ...[
                  ...upcomingList.map((item) {
                    final inst = item['installment'] as EmiInstallment;
                    final acc = item['account'] as EmiAccount;
                    final days = item['days'] as int;
                    final status = item['status'] as String;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: AppColors.getStatusColor(status).withAlpha(100)),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.getStatusBgColor(status),
                          child: Icon(
                            status == EmiStatus.dueToday ? Icons.today : Icons.notifications_active_outlined,
                            color: AppColors.getStatusColor(status),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          acc.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          '${acc.productName} • ${days == 0 ? "Due Today" : "$days days remaining"}\nDue: ${EmiHelper.formatDate(inst.dueDate)}',
                          style: const TextStyle(fontSize: 13, height: 1.3),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              EmiHelper.formatCurrency(inst.amount),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getStatusColor(status),
                              ),
                            ),
                            Text(
                              EmiHelper.getStatusSymbol(status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getStatusColor(status),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Get.to(() => EmiDetailsView(emiAccountId: acc.id)),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color == AppColors.primary ? AppColors.textPrimary : color,
                ),
              ),
              if (subtitle != null) ...[
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
