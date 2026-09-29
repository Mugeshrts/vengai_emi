import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../auth/auth_controller.dart';
import 'admin_controller.dart';
import 'reports_view.dart';
import 'admin_settings_view.dart';
import 'emi_calculator_view.dart';
import 'create_emi_view.dart';
import 'create_chit_fund_view.dart';
import 'user_management_view.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();
    final AuthController authController = Get.find<AuthController>();

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drawer Header with Branding
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(30),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.store_mall_directory_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VENGAI MART',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Furniture & Electronics',
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, color: Colors.amberAccent, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'ADMIN PORTAL • OFFLINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Menu List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Operations Section
                  _buildSectionHeader('OPERATIONS'),
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Home Dashboard',
                    index: 0,
                    controller: controller,
                    onTap: () {
                      controller.selectedNavIndex.value = 0;
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.savings_rounded,
                    title: 'Chit Funds',
                    index: 1,
                    controller: controller,
                    activeColor: const Color(0xFF0F766E),
                    trailingText: '${controller.totalChitSchemes} Schemes',
                    onTap: () {
                      controller.selectedNavIndex.value = 1;
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.people_alt_rounded,
                    title: 'Customers & EMI',
                    index: 2,
                    controller: controller,
                    trailingText: '${controller.totalCustomers}',
                    onTap: () {
                      controller.selectedNavIndex.value = 2;
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'Payment Collections',
                    index: 3,
                    controller: controller,
                    trailingText: '${controller.payments.length}',
                    onTap: () {
                      controller.selectedNavIndex.value = 3;
                      Navigator.pop(context);
                    },
                  ),

                  const Divider(height: 24, indent: 16, endIndent: 16),

                  // Analytics & Management Section (Moved from Bottom Navigation Bar to Drawer)
                  _buildSectionHeader('ANALYTICS & MANAGEMENT'),
                  ListTile(
                    leading: const Icon(Icons.analytics_rounded, color: AppColors.primary),
                    title: const Text(
                      'Reports & Analytics',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    subtitle: Obx(() => Text(
                      controller.overdueCount > 0
                          ? '${controller.overdueCount} Overdue accounts'
                          : 'Financial & collection summary',
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.overdueCount > 0 ? AppColors.overdue : AppColors.textMuted,
                        fontWeight: controller.overdueCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    )),
                    trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const ReportsView());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.manage_accounts_rounded, color: Colors.indigo),
                    title: const Text(
                      'User Management',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    subtitle: Obx(() => Text(
                      '${controller.users.where((u) => !u.isAdmin).length} user logins • credentials & delete',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    )),
                    trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const UserManagementView());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_rounded, color: Colors.blueGrey),
                    title: const Text(
                      'Settings & Preferences',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      'Store details, UPI ID & data backups',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const AdminSettingsView());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calculate_rounded, color: Colors.teal),
                    title: const Text(
                      'EMI Calculator',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      '1% to 50% rate of interest calculation',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const EmiCalculatorView());
                    },
                  ),

                  const Divider(height: 24, indent: 16, endIndent: 16),

                  // Quick Shortcuts Section
                  _buildSectionHeader('QUICK SHORTCUTS'),
                  ListTile(
                    leading: const Icon(Icons.add_shopping_cart, color: AppColors.primary),
                    title: const Text('Create New EMI Plan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    dense: true,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const CreateEmiView());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.savings_outlined, color: Color(0xFF0F766E)),
                    title: const Text('Create New Chit Fund', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    dense: true,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const CreateChitFundView());
                    },
                  ),
                ],
              ),
            ),

            // Footer with Logout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: const Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VENGAI MART v1.0',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Admin: ${authController.currentUser.value?.name ?? "Administrator"}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmLogout(context, authController);
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                    label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required AdminController controller,
    required VoidCallback onTap,
    Color? activeColor,
    String? trailingText,
  }) {
    return Obx(() {
      final isSelected = controller.selectedNavIndex.value == index;
      final color = activeColor ?? AppColors.primary;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? color : AppColors.textSecondary),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
              color: isSelected ? color : AppColors.textPrimary,
            ),
          ),
          trailing: trailingText != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(35) : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trailingText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : AppColors.textMuted,
                    ),
                  ),
                )
              : null,
          onTap: onTap,
        ),
      );
    });
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
