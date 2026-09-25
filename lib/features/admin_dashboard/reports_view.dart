import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/service/emi_helper.dart';
import 'admin_controller.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('EMI Collection Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL EMI BOOK VALUE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      EmiHelper.formatCurrency(controller.totalEmiValue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Collected', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                EmiHelper.formatCurrency(controller.collectedAmount),
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pending Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                EmiHelper.formatCurrency(controller.remainingAmount),
                                style: const TextStyle(
                                  color: Colors.amberAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'ACCOUNT OVERVIEW',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildReportItem(
                      icon: Icons.people_outline,
                      title: 'Total Customers',
                      value: '${controller.totalCustomers}',
                    ),
                    const Divider(height: 1),
                    _buildReportItem(
                      icon: Icons.pending_actions,
                      title: 'Active EMI Accounts',
                      value: '${controller.activeEmiCount}',
                      valueColor: AppColors.primary,
                    ),
                    const Divider(height: 1),
                    _buildReportItem(
                      icon: Icons.check_circle_outline,
                      title: 'Completed EMI Accounts',
                      value: '${controller.completedEmiCount}',
                      valueColor: AppColors.paid,
                    ),
                    const Divider(height: 1),
                    _buildReportItem(
                      icon: Icons.warning_amber_rounded,
                      title: 'Total Overdue Installments',
                      value: '${controller.overdueCount}',
                      valueColor: AppColors.overdue,
                    ),
                    const Divider(height: 1),
                    _buildReportItem(
                      icon: Icons.money_off,
                      title: 'Total Overdue Amount',
                      value: EmiHelper.formatCurrency(controller.totalOverdueAmount),
                      valueColor: AppColors.overdue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'COLLECTION PERFORMANCE',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildReportItem(
                      icon: Icons.today,
                      title: "Today's Collection",
                      value: EmiHelper.formatCurrency(controller.todayCollection),
                      valueColor: AppColors.paid,
                    ),
                    const Divider(height: 1),
                    _buildReportItem(
                      icon: Icons.calendar_month,
                      title: 'This Month Collection',
                      value: EmiHelper.formatCurrency(controller.thisMonthCollection),
                      valueColor: AppColors.paid,
                    ),
                    const Divider(height: 1),
                    _buildReportItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Lifetime Total Collected',
                      value: EmiHelper.formatCurrency(controller.collectedAmount),
                      valueColor: AppColors.paid,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReportItem({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
