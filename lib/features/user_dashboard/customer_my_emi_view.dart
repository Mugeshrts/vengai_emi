import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/service/emi_helper.dart';
import 'customer_controller.dart';
import 'customer_pay_emi_view.dart';

class CustomerMyEmiView extends StatelessWidget {
  const CustomerMyEmiView({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My EMI & Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: Obx(() {
        final accounts = controller.customerAccounts;

        if (accounts.isEmpty) {
          return const Center(
            child: Text('No active EMI account found.', style: TextStyle(color: AppColors.textMuted)),
          );
        }

        // Selected account or fallback to first
        final selectedAcc = controller.currentSelectedAccount ?? accounts.first;
        final installments = controller.allInstallments
            .where((i) => i.emiAccountId == selectedAcc.id)
            .toList();
        installments.sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));

        final nextUnpaid = installments.firstWhereOrNull((i) => !i.isPaid);
        final currentStatus = nextUnpaid != null ? EmiHelper.computeInstallmentStatus(nextUnpaid) : 'COMPLETED';
        final paidCount = installments.where((i) => i.isPaid).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // MULTI-PRODUCT SELECTOR CHIPS (If > 1 product)
              if (accounts.length > 1) ...[
                const Text(
                  'SELECT PRODUCT PLAN:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: accounts.map((acc) {
                      final isSelected = selectedAcc.id == acc.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          avatar: Icon(
                            acc.category.toLowerCase().contains('audio') ? Icons.speaker : Icons.tv,
                            size: 16,
                            color: isSelected ? Colors.white : AppColors.primary,
                          ),
                          label: Text(acc.productName),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          onSelected: (val) {
                            if (val) controller.selectedAccountId.value = acc.id;
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Product & Customer Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            selectedAcc.category.toLowerCase().contains('audio') ? Icons.speaker : Icons.tv,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedAcc.productName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${selectedAcc.customerName} (${selectedAcc.customerId})',
                                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildRow('Product Price', EmiHelper.formatCurrency(selectedAcc.productPrice)),
                    const SizedBox(height: 8),
                    _buildRow('Down Payment', EmiHelper.formatCurrency(selectedAcc.downPayment)),
                    if (selectedAcc.interestRate > 0) ...[
                      const SizedBox(height: 8),
                      _buildRow('Rate of Interest', '${selectedAcc.interestRate.toStringAsFixed(1)}% p.a.'),
                      const SizedBox(height: 8),
                      _buildRow('Interest Amount', EmiHelper.formatCurrency(selectedAcc.interestAmount)),
                    ],
                    const SizedBox(height: 8),
                    _buildRow('Total Payable', EmiHelper.formatCurrency(selectedAcc.totalPayable)),
                    const SizedBox(height: 8),
                    _buildRow(
                      'Remaining Balance',
                      EmiHelper.formatCurrency(selectedAcc.remainingAmount),
                      valueColor: selectedAcc.remainingAmount > 0 ? AppColors.overdue : AppColors.paid,
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _buildRow(
                      'Monthly EMI',
                      '${EmiHelper.formatCurrency(selectedAcc.emiAmount)} / month',
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _buildRow('Total Months', '${selectedAcc.emiMonths} Months'),
                    const SizedBox(height: 8),
                    _buildRow('Purchase / Start Date', EmiHelper.formatDate(selectedAcc.startDate)),
                    const SizedBox(height: 8),
                    _buildRow(
                      'Next Due Date',
                      nextUnpaid != null ? EmiHelper.formatDate(nextUnpaid.dueDate) : 'Completed',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.getStatusBgColor(currentStatus),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            EmiHelper.getStatusSymbol(currentStatus),
                            style: TextStyle(
                              color: AppColors.getStatusColor(currentStatus),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Complete EMI Schedule
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'COMPLETE EMI SCHEDULE',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$paidCount / ${selectedAcc.emiMonths} Paid',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.paid,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...installments.map((inst) {
                final status = EmiHelper.computeInstallmentStatus(inst);
                final statusColor = AppColors.getStatusColor(status);
                final statusBg = AppColors.getStatusBgColor(status);
                final isNext = nextUnpaid != null && nextUnpaid.id == inst.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isNext ? AppColors.primary : (inst.isPaid ? AppColors.border : statusColor.withAlpha(80)),
                      width: isNext ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              EmiHelper.formatCurrency(inst.amount),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Due: ${EmiHelper.formatDate(inst.dueDate)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                            if (inst.isPaid && inst.paidDate != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Paid on ${EmiHelper.formatDate(inst.paidDate)} (${inst.paymentMethod ?? 'UPI'})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.paid,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
                          onPressed: () => Get.to(() => CustomerPayEmiView(installment: inst)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('PAY EMI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
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
}
