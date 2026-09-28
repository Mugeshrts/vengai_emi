import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import 'admin_controller.dart';
import 'admin_dashboard_home_view.dart';
import 'chit_fund_dashboard_view.dart';
import 'customers_view.dart';
import 'admin_payments_view.dart';
import 'admin_drawer.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.put(AdminController());

    final List<Widget> pages = [
      const AdminDashboardHomeView(),
      const ChitFundDashboardView(),
      const CustomersView(),
      const AdminPaymentsView(),
    ];

    return Obx(() {
      return Scaffold(
        drawer: const AdminDrawer(),
        body: IndexedStack(
          index: controller.selectedNavIndex.value.clamp(0, pages.length - 1),
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedNavIndex.value.clamp(0, pages.length - 1),
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
              icon: Icon(Icons.savings_outlined),
              selectedIcon: Icon(Icons.savings, color: Color(0xFF0F766E)),
              label: 'Chit Funds',
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
          ],
        ),
      );
    });
  }
}
