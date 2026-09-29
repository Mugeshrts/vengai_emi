import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/service/emi_helper.dart';
import 'admin_controller.dart';
import 'emi_details_view.dart';
import 'create_emi_view.dart';
import 'admin_drawer.dart';
import 'user_management_view.dart';
import '../../core/models/emi_account_model.dart';

class CustomersView extends StatelessWidget {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    final filters = ['All', 'Active', 'Due Soon', 'Due Today', 'Overdue', 'Completed'];

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Customer EMI Accounts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined, color: AppColors.primary),
            tooltip: 'Manage All Users',
            onPressed: () => Get.to(() => const UserManagementView()),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: AppColors.primary),
            tooltip: 'Create New EMI',
            onPressed: () => Get.to(() => const CreateEmiView()),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar (Requirement 20)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: TextField(
              controller: controller.searchController,
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search by Name, Mobile, ID, Product...',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchQuery.value = '';
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. Filter Chips (Requirement 21)
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                return Obx(() {
                  final isSelected = controller.selectedFilter.value == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceVariant,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        controller.selectedFilter.value = filter;
                      },
                    ),
                  );
                });
              },
            ),
          ),

          const Divider(height: 1),

          // 3. Customer EMI List (Requirement 19)
          Expanded(
            child: Obx(() {
              final accounts = controller.filteredAccounts;

              if (accounts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No customers found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try searching with a different term or filter',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final acc = accounts[index];
                  final summary = controller.getCustomerNextEmiSummary(acc.id);
                  final status = summary['status'] as String;
                  final statusColor = AppColors.getStatusColor(status);
                  final statusBg = AppColors.getStatusBgColor(status);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Get.to(() => EmiDetailsView(emiAccountId: acc.id)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer Name & Status Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    acc.customerName,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    EmiHelper.getStatusSymbol(status),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                  tooltip: 'Delete Options',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _confirmDeleteCustomer(context, controller, acc),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📱 ${acc.customerMobile} • ${acc.customerId}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                            const Divider(height: 20),
                            // Product Name & EMI details
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        acc.productName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Next Due: ${EmiHelper.formatDate(summary['nextDueDate'])}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                      ),
                                      if (status == EmiStatus.overdue && summary['isPenaltyApplicable'] == true) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          '+ Late Fee: ${EmiHelper.formatCurrency(summary['penaltyAmount'])} (Total: ${EmiHelper.formatCurrency(summary['totalDue'])})',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${EmiHelper.formatCurrency(acc.emiAmount)} / mo',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Bal: ${EmiHelper.formatCurrency(acc.remainingAmount)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: acc.remainingAmount > 0 ? AppColors.textSecondary : AppColors.paid,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCustomer(
    BuildContext context,
    AdminController controller,
    EmiAccount acc,
  ) {
    Get.defaultDialog(
      title: 'Delete Customer / Account',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose deletion option for ${acc.customerName} (${acc.customerId}):',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.orange.shade200),
              ),
              tileColor: Colors.orange.shade50,
              leading: const Icon(Icons.inventory_2_outlined, color: Colors.orange),
              title: const Text('Delete This EMI Account Only', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text('Removes ${acc.productName} plan & related payments', style: const TextStyle(fontSize: 11)),
              onTap: () async {
                Get.back();
                await controller.deleteEmiAccount(accountId: acc.id, productName: acc.productName);
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.red.shade200),
              ),
              tileColor: Colors.red.shade50,
              leading: const Icon(Icons.person_remove_outlined, color: Colors.red),
              title: const Text('Delete Entire Customer Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
              subtitle: const Text('Deletes user login, all EMI plans, chits & history', style: TextStyle(fontSize: 11)),
              onTap: () async {
                Get.back();
                await controller.deleteCustomer(customerId: acc.customerId, customerName: acc.customerName);
              },
            ),
          ],
        ),
      ),
      textCancel: 'Cancel',
    );
  }
}
