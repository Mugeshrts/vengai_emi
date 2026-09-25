import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/service/emi_helper.dart';
import '../auth/auth_controller.dart';
import 'customer_controller.dart';

class CustomerProfileView extends StatelessWidget {
  const CustomerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: Obx(() {
        final user = controller.currentUser;
        final account = controller.account;
        final multi = controller.customerAccounts.length > 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar & Name Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.primary.withAlpha(25),
                      child: Text(
                        user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : 'C',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Customer',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer ID: ${user?.customerId ?? "CUST-1001"}',
                      style: const TextStyle(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '📱 ${user?.mobile ?? "-"}',
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // EMI Account Summary Card (Requirement 36)
              const Text(
                'ACCOUNT STATUS',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildProfileRow(
                      multi ? 'Products Active' : 'Product Purchased',
                      multi
                          ? '${controller.activeAccounts.length} Active / ${controller.customerAccounts.length} Total'
                          : (account?.productName ?? 'None'),
                    ),
                    const Divider(height: 20),
                    _buildProfileRow(
                      'Total Monthly EMI',
                      '${EmiHelper.formatCurrency(controller.totalMonthlyCommitment)} / mo',
                      isBold: true,
                    ),
                    const Divider(height: 20),
                    _buildProfileRow(
                      'Remaining Balance',
                      EmiHelper.formatCurrency(controller.remainingAmount),
                      valueColor: controller.remainingAmount > 0 ? AppColors.overdue : AppColors.paid,
                      isBold: true,
                    ),
                    const Divider(height: 20),
                    _buildProfileRow(
                      'Account Status',
                      controller.activeAccounts.isEmpty ? 'COMPLETED' : 'ACTIVE',
                      valueColor: controller.activeAccounts.isEmpty ? AppColors.paid : AppColors.primary,
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Logout Button
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, authController),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'LOGOUT',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red, letterSpacing: 1),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Column(
                  children: [
                    const Text(
                      'VENGAI MART • Customer Self-Service',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Need help? Contact your store manager.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, AuthController authController) {
    Get.defaultDialog(
      title: 'Logout',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'Are you sure you want to sign out of VENGAI MART?',
      textConfirm: 'Logout',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await authController.logout();
      },
    );
  }
}
