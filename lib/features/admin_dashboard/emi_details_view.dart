import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/models/emi_account_model.dart';
import '../../core/models/emi_installment_model.dart';
import '../../core/service/emi_helper.dart';
import 'admin_controller.dart';

class EmiDetailsView extends StatelessWidget {
  final String emiAccountId;

  const EmiDetailsView({super.key, required this.emiAccountId});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('EMI Account Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: Obx(() {
        final account = controller.accounts.firstWhereOrNull((a) => a.id == emiAccountId);
        if (account == null) {
          return const Center(child: Text('EMI Account not found.'));
        }

        final installments = controller.installments
            .where((i) => i.emiAccountId == emiAccountId)
            .toList();
        installments.sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));

        final paidCount = installments.where((i) => i.isPaid).length;
        final pendingCount = installments.length - paidCount;
        final totalPaidAmount = installments
            .where((i) => i.isPaid)
            .fold(0.0, (sum, i) => sum + i.amount);

        final nextSummary = controller.getCustomerNextEmiSummary(account.id);
        final nextStatus = nextSummary['status'] as String;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Customer & Product Hero Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.customerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${account.customerId} • 📱 ${account.customerMobile}',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.getStatusColor(nextStatus),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            EmiHelper.getStatusSymbol(nextStatus),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            account.productName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (account.address != null && account.address!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              account.address!,
                              style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Financial Metrics Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Product Price', EmiHelper.formatCurrency(account.productPrice)),
                    const Divider(height: 16),
                    _buildSummaryRow('Down Payment', EmiHelper.formatCurrency(account.downPayment)),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      'Remaining Amount',
                      EmiHelper.formatCurrency(account.remainingAmount),
                      valueColor: account.remainingAmount > 0 ? AppColors.overdue : AppColors.paid,
                      isBold: true,
                    ),
                    const Divider(height: 16),
                    _buildSummaryRow('Monthly EMI', '${EmiHelper.formatCurrency(account.emiAmount)} / month', isBold: true),
                    const Divider(height: 16),
                    _buildSummaryRow('Total Collected', EmiHelper.formatCurrency(totalPaidAmount), valueColor: AppColors.paid),
                    const Divider(height: 16),
                    _buildSummaryRow('Installments', '$paidCount paid / $pendingCount pending (Total ${account.emiMonths})'),
                    const Divider(height: 16),
                    _buildSummaryRow('Next Due Date', EmiHelper.formatDate(nextSummary['nextDueDate'])),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. EMI Installments Schedule Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EMI SCHEDULE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$paidCount / ${account.emiMonths} Completed',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Installment List
              ...installments.map((inst) {
                final status = EmiHelper.computeInstallmentStatus(inst);
                final statusColor = AppColors.getStatusColor(status);
                final statusBg = AppColors.getStatusBgColor(status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: inst.isPaid ? AppColors.border : statusColor.withAlpha(100),
                      width: inst.isPaid ? 1 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Badge index
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#${inst.installmentNumber}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              EmiHelper.formatCurrency(inst.amount),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Due: ${EmiHelper.formatDate(inst.dueDate)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (inst.isPaid && inst.paidDate != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Paid on ${EmiHelper.formatDate(inst.paidDate)} (${inst.paymentMethod ?? 'UPI'})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.paid,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Action / Status
                      if (inst.isPaid) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.paidBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 16, color: AppColors.paid),
                              SizedBox(width: 4),
                              Text(
                                'PAID',
                                style: TextStyle(
                                  color: AppColors.paid,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ElevatedButton(
                          onPressed: () => _showRecordPaymentBottomSheet(context, controller, account, inst),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'MARK PAID',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showRecordPaymentBottomSheet(
    BuildContext context,
    AdminController controller,
    EmiAccount account,
    EmiInstallment installment,
  ) {
    String selectedMethod = 'Cash';
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
                        'Record EMI Payment',
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${account.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('Installment: EMI #${installment.installmentNumber} • Due Date: ${EmiHelper.formatDate(installment.dueDate)}'),
                        const SizedBox(height: 4),
                        Text(
                          'Amount: ${EmiHelper.formatCurrency(installment.amount)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Payment Method *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Cash', 'UPI', 'Bank Transfer', 'Other'].map((method) {
                      final isSelected = selectedMethod == method;
                      return ChoiceChip(
                        label: Text(method),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setSheetState(() => selectedMethod = method);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: txnCtrl,
                    decoration: InputDecoration(
                      labelText: 'Transaction ID / Reference (Optional)',
                      hintText: 'e.g. UPI Ref / Receipt #',
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'e.g. Paid in office',
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final success = await controller.recordPayment(
                          installment: installment,
                          account: account,
                          paymentMethod: selectedMethod,
                          transactionId: txnCtrl.text,
                          notes: notesCtrl.text,
                        );
                        if (success) {
                          Get.snackbar(
                            'Payment Successful',
                            'EMI #${installment.installmentNumber} payment recorded!',
                            backgroundColor: AppColors.paidBg,
                            colorText: AppColors.paid,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.paid,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CONFIRM PAYMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
}
