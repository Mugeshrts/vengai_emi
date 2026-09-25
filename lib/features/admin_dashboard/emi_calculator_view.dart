import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/color.dart';
import '../../core/service/emi_helper.dart';
import 'create_emi_view.dart';

class EmiCalculatorView extends StatefulWidget {
  const EmiCalculatorView({super.key});

  @override
  State<EmiCalculatorView> createState() => _EmiCalculatorViewState();
}

class _EmiCalculatorViewState extends State<EmiCalculatorView> {
  double price = 50000;
  double downPayment = 10000;
  double interestRate = 12.0; // 1% to 50%
  int tenureMonths = 10;

  final TextEditingController priceCtrl = TextEditingController(text: '50000');
  final TextEditingController dpCtrl = TextEditingController(text: '10000');

  @override
  void initState() {
    super.initState();
  }

  void _syncFromText() {
    setState(() {
      price = double.tryParse(priceCtrl.text) ?? 50000;
      downPayment = double.tryParse(dpCtrl.text) ?? 0;
      if (downPayment > price) downPayment = price;
    });
  }

  @override
  Widget build(BuildContext context) {
    final calc = EmiHelper.calculateEmi(
      productPrice: price,
      downPayment: downPayment,
      interestRatePercent: interestRate,
      months: tenureMonths,
    );

    final principal = calc['principal'] ?? 0.0;
    final interestAmount = calc['interestAmount'] ?? 0.0;
    final totalPayable = calc['totalPayable'] ?? 0.0;
    final monthlyEmi = calc['monthlyEmi'] ?? 0.0;

    final principalFraction = totalPayable > 0 ? (principal / totalPayable).clamp(0.0, 1.0) : 1.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('EMI Calculator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Result Hero Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'ESTIMATED MONTHLY EMI',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    EmiHelper.formatCurrency(monthlyEmi),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'per month for $tenureMonths months',
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                  ),
                  const Divider(color: Colors.white24, height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeroStat('Principal', EmiHelper.formatCurrency(principal)),
                      _buildHeroStat('Total Interest', EmiHelper.formatCurrency(interestAmount), highlight: true),
                      _buildHeroStat('Total Payable', EmiHelper.formatCurrency(totalPayable)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Visual comparison bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: principalFraction,
                      minHeight: 8,
                      backgroundColor: Colors.amberAccent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Principal (${(principalFraction * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Interest (${((1 - principalFraction) * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Interactive Input Controls
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Product Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(
                        width: 130,
                        height: 38,
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          onChanged: (_) => _syncFromText(),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: price.clamp(5000.0, 300000.0),
                    min: 5000,
                    max: 300000,
                    divisions: 59,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        price = val;
                        priceCtrl.text = val.toStringAsFixed(0);
                        if (downPayment > price) {
                          downPayment = price;
                          dpCtrl.text = downPayment.toStringAsFixed(0);
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // Down Payment
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Down Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(
                        width: 130,
                        height: 38,
                        child: TextField(
                          controller: dpCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          onChanged: (_) => _syncFromText(),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: downPayment.clamp(0.0, price > 0 ? price : 100.0),
                    min: 0,
                    max: price > 0 ? price : 100.0,
                    divisions: 50,
                    activeColor: AppColors.secondary,
                    onChanged: (val) {
                      setState(() {
                        downPayment = val;
                        dpCtrl.text = val.toStringAsFixed(0);
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // Rate of Interest (1% to 50%)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rate of Interest (% p.a.)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${interestRate.toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: interestRate.clamp(0.0, 50.0),
                    min: 0.0,
                    max: 50.0,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => interestRate = val),
                  ),
                  Wrap(
                    spacing: 6,
                    children: [0.0, 6.0, 10.0, 12.0, 15.0, 18.0, 24.0, 36.0].map((r) {
                      final isSel = (interestRate - r).abs() < 0.1;
                      return ChoiceChip(
                        label: Text(r == 0.0 ? '0% No Cost' : '${r.toInt()}%'),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => interestRate = r),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Tenure (Months)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tenure (Months)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$tenureMonths Months',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [3, 6, 9, 10, 12, 18, 24, 36].map((m) {
                      final isSel = tenureMonths == m;
                      return ChoiceChip(
                        label: Text('$m Months'),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => tenureMonths = m),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Pre-fill Create EMI Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => CreateEmiView(
                        initialPrice: price,
                        initialDownPayment: downPayment,
                        initialInterestRate: interestRate,
                        initialMonths: tenureMonths,
                      ));
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('CREATE EMI WITH THIS PLAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStat(String title, String value, {bool highlight = false}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: highlight ? Colors.amberAccent : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    priceCtrl.dispose();
    dpCtrl.dispose();
    super.dispose();
  }
}
