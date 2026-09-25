import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/color.dart';
import '../../core/service/emi_helper.dart';
import 'admin_controller.dart';

class CreateEmiView extends StatefulWidget {
  final double? initialPrice;
  final double? initialDownPayment;
  final double? initialInterestRate;
  final int? initialMonths;

  const CreateEmiView({
    super.key,
    this.initialPrice,
    this.initialDownPayment,
    this.initialInterestRate,
    this.initialMonths,
  });

  @override
  State<CreateEmiView> createState() => _CreateEmiViewState();
}

class _CreateEmiViewState extends State<CreateEmiView> {
  final AdminController controller = Get.find<AdminController>();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController customerIdCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController(text: '123456');
  final TextEditingController productCtrl = TextEditingController();
  final TextEditingController categoryCtrl = TextEditingController(text: 'Electronics');
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController downPaymentCtrl = TextEditingController(text: '0');
  final TextEditingController interestRateCtrl = TextEditingController(text: '12');
  final TextEditingController principalCtrl = TextEditingController();
  final TextEditingController interestAmountCtrl = TextEditingController();
  final TextEditingController totalPayableCtrl = TextEditingController();
  final TextEditingController monthsCtrl = TextEditingController(text: '10');
  final TextEditingController emiAmountCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController referenceCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();

  double interestRate = 12.0; // 1% to 50%
  bool isPasswordVisible = false;

  DateTime startDate = DateTime.now();
  DateTime firstDueDate = DateTime.now().add(const Duration(days: 30));

  final DateFormat displayDateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    customerIdCtrl.text = 'CUST-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}';

    if (widget.initialPrice != null) {
      priceCtrl.text = widget.initialPrice!.toStringAsFixed(0);
    }
    if (widget.initialDownPayment != null) {
      downPaymentCtrl.text = widget.initialDownPayment!.toStringAsFixed(0);
    }
    if (widget.initialInterestRate != null) {
      interestRate = widget.initialInterestRate!;
      interestRateCtrl.text = interestRate.toStringAsFixed(0);
    }
    if (widget.initialMonths != null) {
      monthsCtrl.text = widget.initialMonths!.toString();
    }

    _recalculateEmi();
  }

  void _onNameOrMobileChanged() {
    // Only auto-suggest username if user hasn't typed a custom one or it matches pattern
    final name = nameCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final mobile = mobileCtrl.text.trim();
    if (name.isNotEmpty) {
      final suffix = mobile.length >= 4 ? mobile.substring(mobile.length - 4) : '';
      usernameCtrl.text = '$name$suffix';
    }
  }

  void _recalculateEmi() {
    final price = double.tryParse(priceCtrl.text.replaceAll(',', '')) ?? 0.0;
    final dp = double.tryParse(downPaymentCtrl.text.replaceAll(',', '')) ?? 0.0;
    final months = int.tryParse(monthsCtrl.text) ?? 1;

    final calculation = EmiHelper.calculateEmi(
      productPrice: price,
      downPayment: dp,
      interestRatePercent: interestRate,
      months: months,
    );

    final principal = calculation['principal'] ?? 0.0;
    final interestAmount = calculation['interestAmount'] ?? 0.0;
    final totalPayable = calculation['totalPayable'] ?? 0.0;
    final monthly = calculation['monthlyEmi'] ?? 0.0;

    principalCtrl.text = principal > 0 ? principal.toStringAsFixed(0) : '0';
    interestAmountCtrl.text = interestAmount > 0 ? interestAmount.toStringAsFixed(0) : '0';
    totalPayableCtrl.text = totalPayable > 0 ? totalPayable.toStringAsFixed(0) : '0';
    emiAmountCtrl.text = monthly > 0 ? monthly.toStringAsFixed(0) : '0';
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? startDate : firstDueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          firstDueDate = DateTime(picked.year, picked.month + 1, picked.day);
        } else {
          firstDueDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(priceCtrl.text) ?? 0.0;
    final dp = double.tryParse(downPaymentCtrl.text) ?? 0.0;
    final months = int.tryParse(monthsCtrl.text) ?? 0;
    final emi = double.tryParse(emiAmountCtrl.text) ?? 0.0;
    final interestAmt = double.tryParse(interestAmountCtrl.text) ?? 0.0;
    final totalPayable = double.tryParse(totalPayableCtrl.text) ?? (price - dp + interestAmt);

    // Validations
    if (price <= 0) {
      Get.snackbar('Validation', 'Product price must be greater than 0', backgroundColor: AppColors.overdueBg);
      return;
    }

    if (dp > price) {
      Get.snackbar('Validation', 'Down payment cannot exceed product price', backgroundColor: AppColors.overdueBg);
      return;
    }

    if (months <= 0) {
      Get.snackbar('Validation', 'EMI months must be greater than 0', backgroundColor: AppColors.overdueBg);
      return;
    }

    if (emi <= 0) {
      Get.snackbar('Validation', 'EMI amount must be greater than 0', backgroundColor: AppColors.overdueBg);
      return;
    }

    final success = await controller.createEmiAccount(
      customerName: nameCtrl.text,
      customerMobile: mobileCtrl.text,
      customerId: customerIdCtrl.text,
      username: usernameCtrl.text,
      password: passwordCtrl.text,
      productName: productCtrl.text,
      category: categoryCtrl.text,
      productPrice: price,
      downPayment: dp,
      interestRate: interestRate,
      interestAmount: interestAmt,
      totalPayable: totalPayable,
      emiMonths: months,
      emiAmount: emi,
      startDate: startDate,
      firstDueDate: firstDueDate,
      address: addressCtrl.text,
      referenceName: referenceCtrl.text,
      notes: notesCtrl.text,
    );

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'EMI Account and $months installments created with ${interestRate.toStringAsFixed(0)}% interest rate!',
        backgroundColor: AppColors.paidBg,
        colorText: AppColors.paid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CREATE EMI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Customer Details & Login Credentials
              _buildSectionCard(
                title: 'Customer & Login Credentials',
                icon: Icons.person_outline,
                children: [
                  _buildTextField(
                    controller: nameCtrl,
                    label: 'Customer Name *',
                    hint: 'e.g. Ravi Kumar',
                    onChanged: (_) => _onNameOrMobileChanged(),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter customer name' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: mobileCtrl,
                    label: 'Mobile Number *',
                    hint: '10-digit mobile number',
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => _onNameOrMobileChanged(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter mobile number';
                      if (v.trim().length < 10) return 'Enter a valid 10-digit mobile number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: customerIdCtrl,
                          label: 'Customer ID',
                          hint: 'e.g. CUST-1001',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: usernameCtrl,
                          label: 'Customer Username *',
                          hint: 'e.g. ravikumar',
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter login username' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Password field with eye toggle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Login Password *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: passwordCtrl,
                        obscureText: !isPasswordVisible,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter password' : null,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Enter login password (e.g. 123456)',
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: addressCtrl,
                    label: 'Customer Address (Optional)',
                    hint: 'Street, city, landmarks',
                    maxLines: 2,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Section 2: Product & EMI Plan (With Interest Rate 1% to 50%)
              _buildSectionCard(
                title: 'Product & EMI Plan (Interest: 1% - 50%)',
                icon: Icons.calculate_outlined,
                children: [
                  _buildTextField(
                    controller: productCtrl,
                    label: 'Product Name *',
                    hint: 'e.g. Samsung 55" 4K Smart TV',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter product name' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: categoryCtrl,
                    label: 'Product Category',
                    hint: 'e.g. Electronics, Appliances',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: priceCtrl,
                          label: 'Product Price (₹) *',
                          hint: '60000',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _recalculateEmi(),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter price';
                            final val = double.tryParse(v);
                            if (val == null || val <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: downPaymentCtrl,
                          label: 'Down Payment (₹) *',
                          hint: '10000',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _recalculateEmi(),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter down payment';
                            final dp = double.tryParse(v);
                            if (dp == null || dp < 0) return 'Invalid amount';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // RATE OF INTEREST (1% to 50%)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.percent, size: 18, color: AppColors.primary),
                                SizedBox(width: 6),
                                Text(
                                  'Rate of Interest (% p.a.)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${interestRate.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: interestRate.clamp(0.0, 50.0),
                          min: 0.0,
                          max: 50.0,
                          divisions: 50,
                          activeColor: AppColors.primary,
                          inactiveColor: Colors.grey.shade300,
                          label: '${interestRate.toStringAsFixed(0)}%',
                          onChanged: (val) {
                            setState(() {
                              interestRate = val;
                              interestRateCtrl.text = val.toStringAsFixed(0);
                            });
                            _recalculateEmi();
                          },
                        ),
                        // Quick Presets
                        Wrap(
                          spacing: 6,
                          children: [0.0, 5.0, 10.0, 12.0, 15.0, 18.0, 24.0, 36.0].map((rate) {
                            final isSel = (interestRate - rate).abs() < 0.1;
                            return ChoiceChip(
                              label: Text(rate == 0.0 ? '0% No-Cost' : '${rate.toInt()}%'),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  interestRate = rate;
                                  interestRateCtrl.text = rate.toStringAsFixed(0);
                                });
                                _recalculateEmi();
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Calculated Financial Breakdown
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: principalCtrl,
                          label: 'Principal Loan (₹)',
                          hint: '50000',
                          readOnly: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: interestAmountCtrl,
                          label: 'Total Interest (₹)',
                          hint: '5000',
                          readOnly: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: totalPayableCtrl,
                          label: 'Total Payable (₹)',
                          hint: '55000',
                          readOnly: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: monthsCtrl,
                          label: 'EMI Months *',
                          hint: '10',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _recalculateEmi(),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter months';
                            final val = int.tryParse(v);
                            if (val == null || val <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: emiAmountCtrl,
                    label: 'Calculated Monthly EMI (₹) *',
                    hint: '5500',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter EMI';
                      final val = double.tryParse(v);
                      if (val == null || val <= 0) return 'Must be > 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '💡 Calculated automatically with interest. You can fine-tune or round off the EMI amount if needed.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Section 3: Schedule Dates & Reference
              _buildSectionCard(
                title: 'Schedule Dates & Reference',
                icon: Icons.calendar_month_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _selectDate(context, true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      displayDateFormat.format(startDate),
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const Icon(Icons.edit_calendar, size: 18, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('First Due Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _selectDate(context, false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      displayDateFormat.format(firstDueDate),
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const Icon(Icons.edit_calendar, size: 18, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: referenceCtrl,
                    label: 'Reference Name (Optional)',
                    hint: 'e.g. Relative or friend name',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: notesCtrl,
                    label: 'Notes (Optional)',
                    hint: 'e.g. Special instructions or terms',
                    maxLines: 2,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check_circle_outline, size: 22),
                  label: const Text(
                    'GENERATE EMI & SAVE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    Color? fillColor,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            filled: true,
            fillColor: fillColor ?? AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    customerIdCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    productCtrl.dispose();
    categoryCtrl.dispose();
    priceCtrl.dispose();
    downPaymentCtrl.dispose();
    interestRateCtrl.dispose();
    principalCtrl.dispose();
    interestAmountCtrl.dispose();
    totalPayableCtrl.dispose();
    monthsCtrl.dispose();
    emiAmountCtrl.dispose();
    addressCtrl.dispose();
    referenceCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }
}
