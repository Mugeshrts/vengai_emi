import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/service/emi_helper.dart';
import 'admin_controller.dart';
import 'create_chit_fund_view.dart';
import 'chit_fund_details_view.dart';
import 'admin_drawer.dart';

class ChitFundDashboardView extends StatefulWidget {
  const ChitFundDashboardView({super.key});

  @override
  State<ChitFundDashboardView> createState() => _ChitFundDashboardViewState();
}

class _ChitFundDashboardViewState extends State<ChitFundDashboardView> {
  final AdminController controller = Get.find<AdminController>();
  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF0F766E)),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VENGAI MART', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Color(0xFF0F766E))),
            Text('Chit Fund Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F766E)),
            tooltip: 'Refresh',
            onPressed: () => controller.loadAllData(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateChitFundView()),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('CREATE FUND', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        final funds = controller.chitFunds;
        final payments = controller.chitPayments;

        // Metrics calculations
        final totalSchemes = funds.length;
        final activeSchemes = funds.where((f) => f.status == 'ACTIVE').length;
        final totalChitValue = funds.fold(0.0, (sum, f) => sum + f.totalValue);
        final totalCollected = payments.fold(0.0, (sum, p) => sum + p.amount);
        final totalMembersEnrolled = funds.fold(0, (sum, f) => sum + f.members.length);

        // Filter list
        final filtered = funds.where((f) {
          if (_selectedFilter == 'ACTIVE' && f.status != 'ACTIVE') return false;
          if (_selectedFilter == 'COMPLETED' && f.status != 'COMPLETED') return false;
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            return f.schemeName.toLowerCase().contains(query) ||
                f.category.toLowerCase().contains(query);
          }
          return true;
        }).toList();

        return RefreshIndicator(
          onRefresh: () async => controller.loadAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Chit Fund Overview Hero Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withAlpha(50),
                        blurRadius: 14,
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.savings_rounded, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'CHIT PORTFOLIO',
                                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$activeSchemes Active',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Total Chit Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        EmiHelper.formatCurrency(totalChitValue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 30,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPortfolioStat('Schemes', '$totalSchemes Schemes'),
                          _buildPortfolioStat('Collections', EmiHelper.formatCurrency(totalCollected)),
                          _buildPortfolioStat('Members', '$totalMembersEnrolled Enrolled'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Action Bar with "+ CREATE FUND" & Search
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search schemes...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => Get.to(() => const CreateChitFundView()),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('CREATE FUND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 3. Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All Schemes ($totalSchemes)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('ACTIVE', 'Active ($activeSchemes)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('COMPLETED', 'Completed (${totalSchemes - activeSchemes})'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Schemes List
                if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(36),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.savings_outlined, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 14),
                        const Text(
                          'No Chit Fund Schemes Found',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Click "+ CREATE FUND" above to launch your first chit scheme.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () => Get.to(() => const CreateChitFundView()),
                          icon: const Icon(Icons.add),
                          label: const Text('CREATE FUND'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 14),
                    itemBuilder: (context, idx) {
                      final fund = filtered[idx];
                      return _buildSchemeCard(fund, payments);
                    },
                  ),

                const SizedBox(height: 80), // Extra space for FAB
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPortfolioStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF0F766E),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = key);
      },
    );
  }

  Widget _buildSchemeCard(dynamic fund, List<dynamic> payments) {
    final relatedPayments = payments.where((p) => p.chitFundId == fund.id).toList();
    final double schemeCollected = relatedPayments.fold(0.0, (sum, p) => sum + p.amount);
    final double memberFillRatio = fund.maxMembers > 0 ? (fund.members.length / fund.maxMembers).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => ChitFundDetailsView(chitFundId: fund.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scheme Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E).withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                fund.category,
                                style: const TextStyle(
                                  color: Color(0xFF0F766E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${fund.durationMonths} Months',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fund.schemeName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: fund.status == 'ACTIVE' ? Colors.green.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      fund.status,
                      style: TextStyle(
                        color: fund.status == 'ACTIVE' ? Colors.green.shade700 : Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 22),

              // Scheme Financials Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Value', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        EmiHelper.formatCurrency(fund.totalValue),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly / Member', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        '${EmiHelper.formatCurrency(fund.monthlyContribution)}/mo',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Collected', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        EmiHelper.formatCurrency(schemeCollected),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.paid),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Member enrollment slot bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Members: ${fund.members.length} / ${fund.maxMembers} Slots',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  Text(
                    '${(memberFillRatio * 100).toStringAsFixed(0)}% Filled',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F766E)),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: memberFillRatio,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                ),
              ),

              if (fund.bonusDescription.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.card_giftcard, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bonus: ${fund.bonusDescription} (${EmiHelper.formatCurrency(fund.bonusAmount)})',
                          style: TextStyle(color: Colors.brown.shade800, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Get.to(() => ChitFundDetailsView(chitFundId: fund.id)),
                    icon: const Icon(Icons.groups, size: 16),
                    label: const Text('VIEW MEMBERS & DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF0F766E)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
