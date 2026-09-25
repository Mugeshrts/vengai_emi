import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import 'admin_controller.dart';
import 'admin_dashboard_home_view.dart';
import 'customers_view.dart';
import 'admin_payments_view.dart';
import 'reports_view.dart';
import 'admin_settings_view.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.put(AdminController());

    final List<Widget> pages = [
      const AdminDashboardHomeView(),
      const CustomersView(),
      const AdminPaymentsView(),
      const ReportsView(),
      const AdminSettingsView(),
    ];

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: controller.selectedNavIndex.value,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedNavIndex.value,
          onDestinationSelected: (index) {
            controller.selectedNavIndex.value = index;
          },
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withAlpha(35),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people, color: AppColors.primary),
              label: 'Customers',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary),
              label: 'Payments',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics, color: AppColors.primary),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: AppColors.primary),
              label: 'Settings',
            ),
          ],
        ),
      );
    });
  }
}
