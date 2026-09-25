import 'package:intl/intl.dart';
import '../models/emi_installment_model.dart';

class EmiStatus {
  static const String paid = 'PAID';
  static const String overdue = 'OVERDUE';
  static const String dueToday = 'DUE TODAY';
  static const String dueSoon = 'DUE SOON';
  static const String pending = 'PENDING';
}

class EmiHelper {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _longDateFormat = DateFormat('dd MMMM yyyy');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Format amount in Indian Rupee format, e.g. ₹3,500
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format date to readable string, e.g. 10 Oct 2026
  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return _dateFormat.format(date);
    } catch (_) {
      return dateStr;
    }
  }

  /// Format date to full string, e.g. 10 October 2026
  static String formatLongDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return _longDateFormat.format(date);
    } catch (_) {
      return dateStr;
    }
  }

  /// Calculate days remaining/overdue between today and due date
  static int getDaysDifference(String dueDateStr) {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final due = DateTime.parse(dueDateStr);
      final normalizedDue = DateTime(due.year, due.month, due.day);
      return normalizedDue.difference(today).inDays;
    } catch (_) {
      return 0;
    }
  }

  /// Centralized EMI Status Logic (Requirement 11)
  /// IF paid -> PAID
  /// ELSE IF today > due date -> OVERDUE
  /// ELSE IF today == due date -> DUE TODAY
  /// ELSE IF due date <= today + 7 days -> DUE SOON
  /// ELSE -> PENDING
  static String computeInstallmentStatus(EmiInstallment installment) {
    if (installment.isPaid || installment.status.toUpperCase() == EmiStatus.paid) {
      return EmiStatus.paid;
    }

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final due = DateTime.parse(installment.dueDate);
      final normalizedDue = DateTime(due.year, due.month, due.day);

      if (today.isAfter(normalizedDue)) {
        return EmiStatus.overdue;
      } else if (today.year == normalizedDue.year &&
          today.month == normalizedDue.month &&
          today.day == normalizedDue.day) {
        return EmiStatus.dueToday;
      } else if (normalizedDue.isBefore(today.add(const Duration(days: 8)))) {
        // due date is within today + 7 days
        return EmiStatus.dueSoon;
      } else {
        return EmiStatus.pending;
      }
    } catch (_) {
      return EmiStatus.pending;
    }
  }

  /// Get status badge icon representation
  static String getStatusSymbol(String status) {
    switch (status.toUpperCase()) {
      case EmiStatus.paid:
        return '✓ PAID';
      case EmiStatus.overdue:
        return '! OVERDUE';
      case EmiStatus.dueToday:
        return '⚠ DUE TODAY';
      case EmiStatus.dueSoon:
        return '🟠 DUE SOON';
      default:
        return 'PENDING';
    }
  }

  /// Generate monthly due dates starting from firstDueDate
  static List<DateTime> generateDueDates(DateTime firstDueDate, int months) {
    final List<DateTime> dates = [];
    for (int i = 0; i < months; i++) {
      // Calculate month offset
      int year = firstDueDate.year;
      int month = firstDueDate.month + i;
      while (month > 12) {
        year += 1;
        month -= 12;
      }
      
      // Handle day of month clamping (e.g. Feb 30 -> Feb 28)
      int day = firstDueDate.day;
      final daysInTargetMonth = DateTime(year, month + 1, 0).day;
      if (day > daysInTargetMonth) {
        day = daysInTargetMonth;
      }
      dates.add(DateTime(year, month, day));
    }
    return dates;
  }

  /// Calculate EMI with interest rate (1% to 50%)
  /// Formula:
  /// Principal = Product Price - Down Payment
  /// Total Interest = Principal * (annualRate / 100) * (months / 12)
  /// Total Payable = Principal + Total Interest
  /// Monthly EMI = Total Payable / months
  static Map<String, double> calculateEmi({
    required double productPrice,
    required double downPayment,
    required double interestRatePercent, // 1% to 50%, or 0%
    required int months,
  }) {
    final principal = (productPrice - downPayment).clamp(0.0, double.infinity);
    if (months <= 0 || principal <= 0) {
      return {
        'principal': principal,
        'interestAmount': 0.0,
        'totalPayable': principal,
        'monthlyEmi': 0.0,
      };
    }

    final double interestAmount = interestRatePercent > 0
        ? (principal * (interestRatePercent / 100.0) * (months / 12.0))
        : 0.0;
    final double totalPayable = principal + interestAmount;
    final double monthlyEmi = (totalPayable / months).roundToDouble();

    return {
      'principal': principal,
      'interestAmount': interestAmount,
      'totalPayable': totalPayable,
      'monthlyEmi': monthlyEmi,
    };
  }
}
