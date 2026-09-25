import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../auth/auth_controller.dart';
import 'admin_controller.dart';
import 'emi_calculator_view.dart';

class AdminSettingsView extends StatelessWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.admin_panel_settings, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Manager',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'VENGAI MART Management • admin',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // UPI Payment Configuration Section
            const Text(
              'UPI PAYMENT CONFIGURATION',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UPI ID (VPA) for Customer Payments',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller.upiIdController,
                    decoration: InputDecoration(
                      hintText: 'e.g. vengaimart@upi',
                      prefixIcon: const Icon(Icons.qr_code, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Payee Name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller.payeeNameController,
                    decoration: InputDecoration(
                      hintText: 'VENGAI MART',
                      prefixIcon: const Icon(Icons.store, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.saveSettings,
                      icon: const Icon(Icons.save_outlined, size: 20),
                      label: const Text('Save UPI Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Demo Data Operations
            const Text(
              'DATA & SYSTEM ACTIONS',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textPrimary),
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
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.calculate, color: Colors.white),
                    ),
                    title: const Text('EMI Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Calculate interest (1%-50%), tenure & monthly EMI'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Get.to(() => const EmiCalculatorView()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.dueSoonBg,
                      child: Icon(Icons.restore, color: AppColors.dueSoon),
                    ),
                    title: const Text('Reset Demo Data', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Restore default customers, accounts & seed payments'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _confirmResetData(context, controller),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade50,
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                    title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    subtitle: const Text('Sign out of admin account'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _confirmLogout(context, authController),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // App Version & Brand
            Center(
              child: Column(
                children: [
                  const Text(
                    'VENGAI MART EMI v1.0.0 (Offline Mode)',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Independent EMI Collection & Payment Engine',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetData(BuildContext context, AdminController controller) {
    Get.defaultDialog(
      title: 'Reset Demo Data?',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'This will reset all EMI accounts, customer records, and payment history to initial realistic demo seed data.',
      textConfirm: 'Reset',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.dueSoon,
      onConfirm: () async {
        Get.back();
        await controller.resetDemoData();
      },
    );
  }

  void _confirmLogout(BuildContext context, AuthController authController) {
    Get.defaultDialog(
      title: 'Logout',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'Are you sure you want to log out? Your local data will be safely preserved.',
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
