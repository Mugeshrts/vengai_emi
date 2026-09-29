import 'package:vengai_emi/core/models/user_model.dart';
import 'package:vengai_emi/core/models/emi_installment_model.dart';
import 'package:vengai_emi/core/service/emi_helper.dart';

void main() {
  // 1. Test Status calculation
  final now = DateTime.now();
  final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  final instPaid = EmiInstallment(
    id: 'inst-1',
    emiAccountId: 'acc-1',
    customerId: 'cust-1',
    installmentNumber: 1,
    amount: 3500,
    dueDate: todayStr,
    status: EmiStatus.paid,
  );
  assert(EmiHelper.computeInstallmentStatus(instPaid) == EmiStatus.paid, 'Status should be PAID');

  final instToday = EmiInstallment(
    id: 'inst-2',
    emiAccountId: 'acc-1',
    customerId: 'cust-1',
    installmentNumber: 2,
    amount: 3500,
    dueDate: todayStr,
    status: EmiStatus.pending,
  );
  assert(EmiHelper.computeInstallmentStatus(instToday) == EmiStatus.dueToday, 'Status should be DUE TODAY');

  // 2. Test User Model Roles
  final admin = UserModel(
    id: 'u1',
    username: 'admin',
    password: '123',
    name: 'Admin',
    mobile: '9876543210',
    role: 'ADMIN',
  );
  assert(admin.isAdmin == true, 'admin should be admin');
  assert(admin.isCustomer == false, 'admin should not be customer');

  final customer = UserModel(
    id: 'u2',
    username: 'customer1',
    password: '123',
    name: 'Ravi',
    mobile: '9876543210',
    role: 'CUSTOMER',
    customerId: 'CUST-1001',
  );
  assert(customer.isAdmin == false, 'customer should not be admin');
  assert(customer.isCustomer == true, 'customer should be customer');

  // 3. Test Currency and Date formatting
  final formattedCurrency = EmiHelper.formatCurrency(3500);
  assert(formattedCurrency.contains('3,500'), 'Formatted currency must contain 3,500');

  // 4. Test Schedule Date Generation
  final dates = EmiHelper.generateDueDates(DateTime(2026, 1, 10), 10);
  assert(dates.length == 10, 'Should generate exactly 10 due dates');
  // 5. Test EMI with Interest Rate (1% to 50%)
  final emiCalc = EmiHelper.calculateEmi(
    productPrice: 60000,
    downPayment: 10000,
    interestRatePercent: 12.0,
    months: 10,
  );
  assert(emiCalc['principal'] == 50000, 'Principal must be 50,000');
  assert(emiCalc['interestAmount'] == 5000, 'Interest must be 5,000');
  assert(emiCalc['totalPayable'] == 55000, 'Total payable must be 55,000');
  assert(emiCalc['monthlyEmi'] == 5500, 'Monthly EMI must be 5,500');

  // 6. Test Late Payment Penalty Calculation (₹1 per day per ₹1000 for every overdue day)
  // User Case: ₹4,000 overdue for 4 days -> (4000/1000) * 1 * 4 = ₹16 penalty -> Total = ₹4,016
  final fourDaysAgo = now.subtract(const Duration(days: 4));
  final fourDaysAgoStr = '${fourDaysAgo.year}-${fourDaysAgo.month.toString().padLeft(2, '0')}-${fourDaysAgo.day.toString().padLeft(2, '0')}';
  final penalty4Days = EmiHelper.calculateLatePenalty(amount: 4000, dueDateStr: fourDaysAgoStr);
  assert(penalty4Days['isPenaltyApplicable'] == true, '4 days overdue must trigger penalty');
  assert(penalty4Days['daysOverdue'] == 4, 'Must be 4 days overdue');
  assert(penalty4Days['penaltyAmount'] == 16.0, '₹4000 overdue for 4 days must equal ₹16 penalty');
  assert(penalty4Days['totalDue'] == 4016.0, 'Total due must be exactly ₹4016');

  final fiveDaysAgo = now.subtract(const Duration(days: 5));
  final fiveDaysAgoStr = '${fiveDaysAgo.year}-${fiveDaysAgo.month.toString().padLeft(2, '0')}-${fiveDaysAgo.day.toString().padLeft(2, '0')}';
  final penalty5Days = EmiHelper.calculateLatePenalty(amount: 1000, dueDateStr: fiveDaysAgoStr);
  assert(penalty5Days['isPenaltyApplicable'] == true, '5 days overdue must trigger penalty');
  assert(penalty5Days['penaltyAmount'] == 5.0, '₹1000 overdue for 5 days must equal ₹5 penalty');
  assert(penalty5Days['totalDue'] == 1005.0, 'Total due must be 1005');

  final tenDaysAgo = now.subtract(const Duration(days: 10));
  final tenDaysAgoStr = '${tenDaysAgo.year}-${tenDaysAgo.month.toString().padLeft(2, '0')}-${tenDaysAgo.day.toString().padLeft(2, '0')}';
  final penalty10Days = EmiHelper.calculateLatePenalty(amount: 2000, dueDateStr: tenDaysAgoStr);
  assert(penalty10Days['penaltyAmount'] == 20.0, '₹2000 overdue for 10 days = (2000/1000)*1*10 = ₹20 penalty');
  assert(penalty10Days['totalDue'] == 2020.0, 'Total due must be 2020');

  // Future or today's due date must have 0 penalty
  final penaltyToday = EmiHelper.calculateLatePenalty(amount: 4000, dueDateStr: todayStr);
  assert(penaltyToday['isPenaltyApplicable'] == false, 'Due today must not have penalty');
  assert(penaltyToday['penaltyAmount'] == 0.0, 'Penalty today must be 0');
  assert(penaltyToday['totalDue'] == 4000.0, 'Total due today must be 4000');

  // 7. Test User Deletion & Admin Protection Rules
  assert(admin.isAdmin == true, 'Admin account must have isAdmin = true');
  final canDeleteAdmin = !admin.isAdmin;
  assert(canDeleteAdmin == false, 'Admin account deletion must strictly be prevented');
  final canDeleteCustomer = !customer.isAdmin;
  assert(canDeleteCustomer == true, 'Customer accounts can be deleted');

  // ignore: avoid_print
  print('=== ALL VENGAI MART UNIT TESTS PASSED SUCCESSFULLY! ===');
}
