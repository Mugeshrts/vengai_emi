import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/models/user_model.dart';
import 'admin_controller.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final AdminController controller = Get.find<AdminController>();
  final TextEditingController searchCtrl = TextEditingController();
  final RxString query = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxSet<String> visiblePasswords = <String>{}.obs;

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  void togglePasswordVisibility(String userId) {
    if (visiblePasswords.contains(userId)) {
      visiblePasswords.remove(userId);
    } else {
      visiblePasswords.add(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'EMI Users', 'Chit Fund Only', 'Admins'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'User & Account Management',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: TextField(
              controller: searchCtrl,
              onChanged: (val) => query.value = val,
              decoration: InputDecoration(
                hintText: 'Search by Name, Username, Mobile, ID...',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Obx(() {
                  if (query.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        searchCtrl.clear();
                        query.value = '';
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

          // 2. Filter Chips
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
                  final isSelected = selectedFilter.value == filter;
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
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => selectedFilter.value = filter,
                    ),
                  );
                });
              },
            ),
          ),

          // 3. User List
          Expanded(
            child: Obx(() {
              final q = query.value.trim().toLowerCase();
              final filter = selectedFilter.value;

              final userList = controller.users.where((user) {
                // Search match
                final name = user.name.toLowerCase();
                final username = user.username.toLowerCase();
                final mobile = user.mobile.toLowerCase();
                final custId = (user.customerId ?? '').toLowerCase();

                final matchesSearch = q.isEmpty ||
                    name.contains(q) ||
                    username.contains(q) ||
                    mobile.contains(q) ||
                    custId.contains(q);

                if (!matchesSearch) return false;

                // Has EMI?
                final hasEmi = controller.accounts.any(
                  (a) => a.customerId == user.customerId || a.customerMobile == user.mobile,
                );

                // Has Chit Fund?
                final hasChit = controller.chitFunds.any(
                  (cf) => cf.members.any(
                    (m) => m.customerId == user.customerId || m.customerMobile == user.mobile,
                  ),
                );

                if (filter == 'Admins') {
                  return user.isAdmin;
                } else if (filter == 'EMI Users') {
                  return !user.isAdmin && hasEmi;
                } else if (filter == 'Chit Fund Only') {
                  return !user.isAdmin && !hasEmi && hasChit;
                }
                return true;
              }).toList();

              if (userList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No user accounts match your search',
                        style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  final user = userList[index];
                  final isPassVisible = visiblePasswords.contains(user.id);

                  // Count active EMI and Chit schemes
                  final emiCount = controller.accounts
                      .where((a) => a.customerId == user.customerId || a.customerMobile == user.mobile)
                      .length;
                  final chitCount = controller.chitFunds
                      .where((cf) => cf.members.any((m) => m.customerId == user.customerId || m.customerMobile == user.mobile))
                      .length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: user.isAdmin ? AppColors.primary.withAlpha(80) : AppColors.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Name, Role Badge, Delete/Protected
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: user.isAdmin
                                    ? AppColors.primary
                                    : (emiCount > 0 ? Colors.indigo.shade50 : Colors.teal.shade50),
                                child: Icon(
                                  user.isAdmin
                                      ? Icons.admin_panel_settings
                                      : (emiCount > 0 ? Icons.person : Icons.savings_outlined),
                                  color: user.isAdmin
                                      ? Colors.white
                                      : (emiCount > 0 ? Colors.indigo : Colors.teal),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: user.isAdmin
                                                ? AppColors.primary.withAlpha(20)
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            user.role.toUpperCase(),
                                            style: TextStyle(
                                              color: user.isAdmin ? AppColors.primary : AppColors.textSecondary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'ID: ${user.customerId ?? user.id} • 📱 ${user.mobile}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              if (user.isAdmin)
                                Tooltip(
                                  message: 'Administrator account cannot be deleted',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.amber.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.shield, size: 14, color: Colors.amber.shade800),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Protected',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: 'Delete User Account',
                                  onPressed: () => _confirmDeleteUser(context, user, emiCount, chitCount),
                                ),
                            ],
                          ),
                          const Divider(height: 20),

                          // Credentials Row
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.key, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Username: ${user.username}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        isPassVisible ? 'Password: ${user.password}' : 'Password: ••••••••',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isPassVisible ? Icons.visibility_off : Icons.visibility,
                                    size: 18,
                                    color: AppColors.textMuted,
                                  ),
                                  onPressed: () => togglePasswordVisibility(user.id),
                                  tooltip: isPassVisible ? 'Hide Password' : 'Show Password',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Linked Subscriptions / Plans
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: emiCount > 0 ? Colors.indigo.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$emiCount EMI ${emiCount == 1 ? 'Account' : 'Accounts'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: emiCount > 0 ? Colors.indigo.shade800 : AppColors.textMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: chitCount > 0 ? Colors.teal.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$chitCount Chit ${chitCount == 1 ? 'Fund' : 'Funds'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: chitCount > 0 ? Colors.teal.shade800 : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

  void _confirmDeleteUser(
    BuildContext context,
    UserModel user,
    int emiCount,
    int chitCount,
  ) {
    Get.defaultDialog(
      title: 'Delete User Account?',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete user "${user.username}" (${user.name})?',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ This action cannot be undone and will delete:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 6),
                  Text('• User login credentials (@${user.username})', style: const TextStyle(fontSize: 12)),
                  if (emiCount > 0)
                    Text('• All $emiCount connected EMI accounts, schedules & payments', style: const TextStyle(fontSize: 12)),
                  if (chitCount > 0)
                    Text('• Chit Fund memberships and contribution records', style: const TextStyle(fontSize: 12)),
                  Text('• Reminders and customer profile data', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'Delete Permanently',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await controller.deleteUser(user: user);
      },
    );
  }
}
