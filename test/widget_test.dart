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

  // ignore: avoid_print
  print('=== ALL VENGAI MART UNIT TESTS PASSED SUCCESSFULLY! ===');
}
