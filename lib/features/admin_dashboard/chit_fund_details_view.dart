import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/models/chit_fund_model.dart';
import '../../core/service/emi_helper.dart';
import 'admin_controller.dart';

class ChitFundDetailsView extends StatefulWidget {
  final String chitFundId;

  const ChitFundDetailsView({super.key, required this.chitFundId});

  @override
  State<ChitFundDetailsView> createState() => _ChitFundDetailsViewState();
}

class _ChitFundDetailsViewState extends State<ChitFundDetailsView> with SingleTickerProviderStateMixin {
  final AdminController controller = Get.find<AdminController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fund = controller.chitFunds.firstWhereOrNull((f) => f.id == widget.chitFundId);
      if (fund == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Chit Fund Details')),
          body: const Center(child: Text('Chit Fund Scheme not found')),
        );
      }

      final relatedPayments = controller.chitPayments.where((p) => p.chitFundId == fund.id).toList();
      relatedPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

      final double totalCollected = relatedPayments.fold(0.0, (sum, p) => sum + p.amount);

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(fund.schemeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF0F766E)),
              tooltip: 'Enroll Customer',
              onPressed: () => _showEnrollCustomerDialog(context, fund),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF0F766E),
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: const Color(0xFF0F766E),
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: const Icon(Icons.groups_outlined, size: 20),
                text: 'Members (${fund.members.length}/${fund.maxMembers})',
              ),
              Tab(
                icon: const Icon(Icons.receipt_long_outlined, size: 20),
                text: 'Collections (${relatedPayments.length})',
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Top Summary Hero Header
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withAlpha(50),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          fund.category.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: fund.status == 'ACTIVE' ? Colors.green.shade400 : Colors.blue.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          fund.status,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Chit Value', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            EmiHelper.formatCurrency(fund.totalValue),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Monthly Installment', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            '${EmiHelper.formatCurrency(fund.monthlyContribution)}/mo',
                            style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderMiniMetric('Duration', '${fund.durationMonths} Months'),
                      _buildHeaderMiniMetric('Collected', EmiHelper.formatCurrency(totalCollected)),
                      _buildHeaderMiniMetric('Members', '${fund.members.length} / ${fund.maxMembers}'),
                    ],
                  ),
                  if (fund.bonusDescription.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.card_giftcard, color: Colors.amberAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bonus: ${fund.bonusDescription} (${EmiHelper.formatCurrency(fund.bonusAmount)})',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMembersTab(fund),
                  _buildCollectionsTab(relatedPayments),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeaderMiniMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildMembersTab(ChitFund fund) {
    if (fund.members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('No members enrolled yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Enroll customers to start tracking monthly contributions.', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showEnrollCustomerDialog(context, fund),
              icon: const Icon(Icons.person_add),
              label: const Text('ENROLL CUSTOMER'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: fund.members.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final member = fund.members[idx];
        final progress = (member.monthsPaid / fund.durationMonths).clamp(0.0, 1.0);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E).withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '#${member.ticketNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F766E), fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.customerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              '📱 ${member.customerMobile}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: member.status == 'MATURED' ? Colors.green.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        member.status,
                        style: TextStyle(
                          color: member.status == 'MATURED' ? Colors.green.shade700 : Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paid: ${member.monthsPaid} / ${fund.durationMonths} Months',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    Text(
                      'Total: ${EmiHelper.formatCurrency(member.totalContributed)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showRecordPaymentSheet(context, fund, member),
                      icon: const Icon(Icons.add_task, size: 16),
                      label: Text(
                        member.monthsPaid >= fund.durationMonths ? 'Add Special Contribution' : 'Collect Month #${member.monthsPaid + 1}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F766E),
                        side: const BorderSide(color: Color(0xFF0F766E)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
  }

  Widget _buildCollectionsTab(List<ChitPayment> payments) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('No collections recorded yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Recorded monthly chit contributions will appear here.', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: payments.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final payment = payments[idx];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.paid, size: 20),
            ),
            title: Text(payment.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              'Month #${payment.monthNumber} • ${EmiHelper.formatDate(payment.paymentDate)} • ${payment.paymentMethod}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              EmiHelper.formatCurrency(payment.amount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F766E)),
            ),
          ),
        );
      },
    );
  }

  void _showEnrollCustomerDialog(BuildContext context, ChitFund fund) {
    final availableCustomers = controller.customers
        .where((c) => !fund.members.any((m) => m.customerId == c.customerId))
        .toList();

    String? selectedCustId = availableCustomers.isNotEmpty ? availableCustomers.first.customerId : null;
    bool isCreatingNew = availableCustomers.isEmpty;

    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: '123456');

    mobileCtrl.addListener(() {
      if (usernameCtrl.text.isEmpty || usernameCtrl.text == mobileCtrl.text) {
        usernameCtrl.text = mobileCtrl.text.trim();
      }
    });

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setDlgState) {
          return Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enroll Chit Fund Member',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F766E)),
                          ),
                          Text(
                            'Ticket #${fund.members.length + 1} • ${fund.schemeName}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                    ],
                  ),
                  const Divider(height: 20),

                  // Mode Toggle: Existing vs New Customer
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Existing Customer'),
                          selected: !isCreatingNew,
                          selectedColor: const Color(0xFF0F766E),
                          labelStyle: TextStyle(
                            color: !isCreatingNew ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setDlgState(() => isCreatingNew = false);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('+ New Customer (User/Pass)'),
                          selected: isCreatingNew,
                          selectedColor: const Color(0xFF0F766E),
                          labelStyle: TextStyle(
                            color: isCreatingNew ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setDlgState(() => isCreatingNew = true);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (!isCreatingNew) ...[
                    if (availableCustomers.isEmpty) ...[
                      const Text(
                        'All existing customers are already enrolled in this scheme. Please switch to "New Customer" to create an account.',
                        style: TextStyle(color: Colors.amber, fontSize: 13),
                      ),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedCustId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Customer *',
                          border: OutlineInputBorder(),
                        ),
                        items: availableCustomers.map((c) {
                          return DropdownMenuItem(
                            value: c.customerId,
                            child: Text('${c.name} (${c.mobile})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDlgState(() => selectedCustId = val);
                        },
                      ),
                    ],
                  ] else ...[
                    // New Customer Registration Form
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Customer Full Name *',
                        hintText: 'e.g. Anandha Kumar',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: mobileCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number *',
                        hintText: 'e.g. 9876543210',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Login Username *',
                        hintText: 'e.g. anand9876 or mobile number',
                        prefixIcon: Icon(Icons.account_circle_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Login Password *',
                        hintText: 'e.g. 123456',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (!isCreatingNew) {
                          if (selectedCustId == null) return;
                          final cust = availableCustomers.firstWhere((c) => c.customerId == selectedCustId);
                          Get.back();
                          final success = await controller.enrollCustomerInChit(
                            fund: fund,
                            customerId: cust.customerId ?? cust.id,
                            customerName: cust.name,
                            customerMobile: cust.mobile,
                          );
                          if (success) {
                            Get.snackbar(
                              'Enrolled Successfully',
                              '${cust.name} assigned Ticket #${fund.members.length + 1} in ${fund.schemeName}',
                              backgroundColor: AppColors.paidBg,
                              colorText: AppColors.paid,
                            );
                          }
                        } else {
                          final name = nameCtrl.text.trim();
                          final mobile = mobileCtrl.text.trim();
                          final username = usernameCtrl.text.trim();
                          final password = passwordCtrl.text.trim();

                          if (name.isEmpty || mobile.isEmpty) {
                            Get.snackbar('Required Fields', 'Please enter Name and Mobile number.', backgroundColor: Colors.amber.shade100);
                            return;
                          }

                          Get.back();
                          final success = await controller.createAndEnrollChitCustomer(
                            fund: fund,
                            name: name,
                            mobile: mobile,
                            username: username,
                            password: password,
                          );
                          if (success) {
                            Get.snackbar(
                              'Customer Created & Enrolled!',
                              'Created account for $name (User: "$username", Pass: "$password") and assigned Ticket #${fund.members.length + 1}!',
                              backgroundColor: AppColors.paidBg,
                              colorText: AppColors.paid,
                              duration: const Duration(seconds: 4),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: Text(
                        isCreatingNew ? 'CREATE USER & ENROLL TICKET' : 'ENROLL AS MEMBER',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showRecordPaymentSheet(BuildContext context, ChitFund fund, ChitMember member) {
    String selectedMethod = 'Cash';
    final amountCtrl = TextEditingController(text: fund.monthlyContribution.toStringAsFixed(0));
    final txnCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Record Chit Contribution',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Member: ${member.customerName} (Ticket #${member.ticketNumber})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Scheme: ${fund.schemeName} • Month #${member.monthsPaid + 1} of ${fund.durationMonths}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Contribution Amount (₹) *',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Payment Method *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['Cash', 'UPI', 'Bank Transfer', 'Other'].map((method) {
                      final isSelected = selectedMethod == method;
                      return ChoiceChip(
                        label: Text(method),
                        selected: isSelected,
                        selectedColor: const Color(0xFF0F766E),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) setSheetState(() => selectedMethod = method);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: txnCtrl,
                    decoration: InputDecoration(
                      labelText: 'Transaction ID / Reference (Optional)',
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final amt = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0.0;
                        if (amt <= 0) return;
                        Get.back();
                        final success = await controller.recordChitPayment(
                          fund: fund,
                          member: member,
                          amount: amt,
                          paymentMethod: selectedMethod,
                          transactionId: txnCtrl.text,
                          notes: notesCtrl.text,
                        );
                        if (success) {
                          Get.snackbar(
                            'Contribution Recorded',
                            'Received ${EmiHelper.formatCurrency(amt)} from ${member.customerName}',
                            backgroundColor: AppColors.paidBg,
                            colorText: AppColors.paid,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CONFIRM CONTRIBUTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
