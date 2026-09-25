import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import 'customer_controller.dart';
import 'customer_home_view.dart';
import 'customer_my_emi_view.dart';
import 'customer_payment_history_view.dart';
import 'customer_profile_view.dart';

class CustomerMainScreen extends StatelessWidget {
  const CustomerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.put(CustomerController());

    final List<Widget> pages = [
      const CustomerHomeView(),
      const CustomerMyEmiView(),
      const CustomerPaymentHistoryView(),
      const CustomerProfileView(),
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
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary),
              label: 'My EMI',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      );
    });
  }
}
