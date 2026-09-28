import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/color.dart';
import '../../core/models/chit_fund_model.dart';
import 'admin_controller.dart';

class CreateChitFundView extends StatefulWidget {
  const CreateChitFundView({super.key});

  @override
  State<CreateChitFundView> createState() => _CreateChitFundViewState();
}

class _CreateChitFundViewState extends State<CreateChitFundView> {
  final AdminController controller = Get.find<AdminController>();

  final _formKey = GlobalKey<FormState>();
  final _schemeNameCtrl = TextEditingController();
  final _totalValueCtrl = TextEditingController();
  final _monthlyAmountCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '12');
  final _maxMembersCtrl = TextEditingController(text: '12');
  final _bonusAmountCtrl = TextEditingController(text: '0');
  final _bonusDescCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedCategory = 'Living & Bedroom Furniture';
  DateTime _startDate = DateTime.now();

  final List<String> _categories = [
    'Living & Bedroom Furniture',
    'Electronics & Home Appliances',
    'Smart TV & Entertainment',
    'Kitchen Appliances & Dining',
    'Solid Wood & Modular Furniture',
    'Festive Mega Appliances Chit',
    'General Store Savings',
  ];

  final Set<String> _selectedCustomerIds = {};

  @override
  void initState() {
    super.initState();
    _totalValueCtrl.addListener(_autoComputeMonthly);
    _durationCtrl.addListener(_autoComputeMonthly);
  }

  void _autoComputeMonthly() {
    final total = double.tryParse(_totalValueCtrl.text.replaceAll(',', '')) ?? 0.0;
    final dur = int.tryParse(_durationCtrl.text) ?? 0;
    if (total > 0 && dur > 0) {
      final monthly = total / dur;
      if (_monthlyAmountCtrl.text != monthly.toStringAsFixed(0)) {
        _monthlyAmountCtrl.text = monthly.toStringAsFixed(0);
      }
      if (_maxMembersCtrl.text.isEmpty || _maxMembersCtrl.text == '0') {
        _maxMembersCtrl.text = dur.toString();
      }
    }
  }

  @override
  void dispose() {
    _totalValueCtrl.removeListener(_autoComputeMonthly);
    _durationCtrl.removeListener(_autoComputeMonthly);
    _schemeNameCtrl.dispose();
    _totalValueCtrl.dispose();
    _monthlyAmountCtrl.dispose();
    _durationCtrl.dispose();
    _maxMembersCtrl.dispose();
    _bonusAmountCtrl.dispose();
    _bonusDescCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final schemeName = _schemeNameCtrl.text.trim();
    final totalValue = double.tryParse(_totalValueCtrl.text.replaceAll(',', '')) ?? 0.0;
    final monthlyAmount = double.tryParse(_monthlyAmountCtrl.text.replaceAll(',', '')) ?? 0.0;
    final durationMonths = int.tryParse(_durationCtrl.text) ?? 12;
    final maxMembers = int.tryParse(_maxMembersCtrl.text) ?? durationMonths;
    final bonusAmount = double.tryParse(_bonusAmountCtrl.text.replaceAll(',', '')) ?? 0.0;
    final bonusDesc = _bonusDescCtrl.text.trim();
    final notes = _notesCtrl.text.trim();

    if (totalValue <= 0 || monthlyAmount <= 0) {
      Get.snackbar('Invalid Amount', 'Please enter valid total and monthly amounts', backgroundColor: Colors.red.shade100);
      return;
    }

    // Build initial enrolled members if selected
    final List<ChitMember> initialMembers = [];
    final iso = DateFormat('yyyy-MM-dd');
    int ticket = 1;
    for (var custId in _selectedCustomerIds) {
      final cust = controller.customers.firstWhereOrNull((c) => c.customerId == custId);
      if (cust != null) {
        final cId = cust.customerId ?? cust.id;
        initialMembers.add(ChitMember(
          customerId: cId,
          customerName: cust.name,
          customerMobile: cust.mobile,
          ticketNumber: ticket++,
          enrolledDate: iso.format(DateTime.now()),
          monthsPaid: 0,
          totalContributed: 0.0,
          status: 'ACTIVE',
        ));
      }
    }

    final success = await controller.createChitFund(
      schemeName: schemeName,
      category: _selectedCategory,
      totalValue: totalValue,
      monthlyContribution: monthlyAmount,
      durationMonths: durationMonths,
      maxMembers: maxMembers,
      bonusAmount: bonusAmount,
      bonusDescription: bonusDesc,
      startDate: _startDate,
      notes: notes,
      initialMembers: initialMembers,
    );

    if (success) {
      Get.back();
      Get.snackbar(
        'Chit Fund Scheme Created!',
        '$schemeName created successfully with ${initialMembers.length} enrolled members.',
        backgroundColor: AppColors.paidBg,
        colorText: AppColors.paid,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Chit Fund Scheme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.savings_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VENGAI MART CHIT FUND',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Organize offline monthly savings schemes for furniture & electronics appliances.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Scheme Basic Info Card
                _buildSectionHeader('1. SCHEME DETAILS'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _schemeNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Scheme Name *',
                            hintText: 'e.g. Diwali Mega Electronics Chit 2026',
                            prefixIcon: Icon(Icons.bookmark_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter scheme name' : null,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Scheme Category *',
                            prefixIcon: Icon(Icons.category_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                        const SizedBox(height: 14),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          tileColor: AppColors.surfaceVariant,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          leading: const Icon(Icons.calendar_month, color: AppColors.primary),
                          title: const Text('Start Date', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                          subtitle: Text(df.format(_startDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          trailing: const Icon(Icons.edit_calendar, size: 20, color: AppColors.primary),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => _startDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Financial Structure
                _buildSectionHeader('2. FINANCIAL STRUCTURE & DURATION'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _totalValueCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Total Value (₹) *',
                                  hintText: 'e.g. 60,000',
                                  prefixText: '₹ ',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _durationCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Duration (Months) *',
                                  hintText: 'e.g. 12',
                                  suffixText: 'Mo',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _monthlyAmountCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Monthly Amount (₹) *',
                                  hintText: 'e.g. 5,000',
                                  prefixText: '₹ ',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _maxMembersCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Max Members *',
                                  hintText: 'e.g. 12',
                                  prefixIcon: Icon(Icons.group_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _bonusAmountCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Bonus/Gift Value (₹)',
                                  hintText: 'e.g. 3,000',
                                  prefixText: '₹ ',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _bonusDescCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Bonus Description',
                                  hintText: 'e.g. Free Mixer Grinder or Center Table',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Enroll Customers Section
                _buildSectionHeader('3. ENROLL INITIAL CUSTOMERS (OPTIONAL)'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selected: ${_selectedCustomerIds.length} members',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                            ElevatedButton.icon(
                              onPressed: _showCreateNewCustomerModal,
                              icon: const Icon(Icons.person_add, size: 16),
                              label: const Text('+ New Customer (User & Pass)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Obx(() {
                          final customers = controller.customers;
                          if (customers.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('No customers registered yet. Click "+ New Customer" above to create one with login access.'),
                            );
                          }
                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: customers.length,
                              separatorBuilder: (_, index) => const Divider(height: 1),
                              itemBuilder: (context, idx) {
                                final cust = customers[idx];
                                final id = cust.customerId ?? cust.id;
                                final isSelected = _selectedCustomerIds.contains(id);
                                return CheckboxListTile(
                                  dense: true,
                                  value: isSelected,
                                  title: Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text('$id • ${cust.mobile}', style: const TextStyle(fontSize: 12)),
                                  activeColor: const Color(0xFF0F766E),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedCustomerIds.add(id);
                                      } else {
                                        _selectedCustomerIds.remove(id);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Notes / Terms
                _buildSectionHeader('4. SCHEME NOTES & TERMS'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes / Rules',
                        hintText: 'e.g. Draw will take place on 10th of every month at VENGAI MART store.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Create Scheme Submit Button
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_circle_outline, size: 22),
                    label: const Text(
                      'SAVE & LAUNCH CHIT SCHEME',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  void _showCreateNewCustomerModal() {
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: '123456');

    // Auto-fill username when typing mobile or name
    mobileCtrl.addListener(() {
      if (usernameCtrl.text.isEmpty || usernameCtrl.text == mobileCtrl.text) {
        usernameCtrl.text = mobileCtrl.text.trim();
      }
    });

    Get.bottomSheet(
      Container(
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Customer Login',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                      ),
                      Text(
                        'For Chit Fund savings member access',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Customer Full Name *',
                  hintText: 'e.g. Ramesh Kumar',
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
                  hintText: 'e.g. ramesh9876 or mobile number',
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
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final mobile = mobileCtrl.text.trim();
                    final username = usernameCtrl.text.trim();
                    final password = passwordCtrl.text.trim();

                    if (name.isEmpty || mobile.isEmpty) {
                      Get.snackbar('Required Fields', 'Please enter at least Name and Mobile number.', backgroundColor: Colors.amber.shade100);
                      return;
                    }

                    final newUser = await controller.registerCustomer(
                      name: name,
                      mobile: mobile,
                      username: username,
                      password: password,
                    );

                    final id = newUser.customerId ?? newUser.id;
                    setState(() {
                      _selectedCustomerIds.add(id);
                    });

                    Get.back();
                    Get.snackbar(
                      'Customer Account Created!',
                      'User: "${newUser.username}" • Pass: "${newUser.password}" enrolled in scheme.',
                      backgroundColor: AppColors.paidBg,
                      colorText: AppColors.paid,
                      duration: const Duration(seconds: 4),
                    );
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('SAVE & ENROLL IN CHIT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
      ),
      isScrollControlled: true,
    );
  }
}
