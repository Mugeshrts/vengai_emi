import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/emi_account_model.dart';
import '../models/emi_installment_model.dart';
import '../models/payment_model.dart';
import '../models/reminder_model.dart';
import 'emi_helper.dart';

class SeedData {
  static final DateFormat isoFormat = DateFormat('yyyy-MM-dd');

  static List<UserModel> getDefaultUsers() {
    return [
      UserModel(
        id: 'usr_admin',
        username: 'admin',
        password: 'admin123',
        name: 'Admin Manager',
        mobile: '9888877777',
        role: 'ADMIN',
        isActive: true,
      ),
      UserModel(
        id: 'usr_cust_1',
        username: 'customer1',
        password: '123456',
        name: 'Ravi Kumar',
        mobile: '9876543210',
        role: 'CUSTOMER',
        customerId: 'CUST-1001',
        isActive: true,
      ),
      UserModel(
        id: 'usr_cust_2',
        username: 'priya',
        password: '123456',
        name: 'Priya Sharma',
        mobile: '9845123789',
        role: 'CUSTOMER',
        customerId: 'CUST-1002',
        isActive: true,
      ),
      UserModel(
        id: 'usr_cust_3',
        username: 'suresh',
        password: '123456',
        name: 'Suresh',
        mobile: '9789123456',
        role: 'CUSTOMER',
        customerId: 'CUST-1003',
        isActive: true,
      ),
      UserModel(
        id: 'usr_cust_4',
        username: 'lakshmi',
        password: '123456',
        name: 'Lakshmi Narayanan',
        mobile: '9443123456',
        role: 'CUSTOMER',
        customerId: 'CUST-1004',
        isActive: true,
      ),
      UserModel(
        id: 'usr_cust_5',
        username: 'karthik',
        password: '123456',
        name: 'Karthik Raja',
        mobile: '9940123456',
        role: 'CUSTOMER',
        customerId: 'CUST-1005',
        isActive: true,
      ),
    ];
  }

  static Map<String, dynamic> generateInitialData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<UserModel> users = getDefaultUsers();
    final List<EmiAccount> accounts = [];
    final List<EmiInstallment> installments = [];
    final List<PaymentModel> payments = [];
    final List<ReminderModel> reminders = [];

    // --- 1. RAVI KUMAR (Active, Due Soon in 5 days) ---
    final raviDueSoonDate = today.add(const Duration(days: 5));
    final raviStartDate = DateTime(today.year, today.month - 3, 10);
    final raviAcc = EmiAccount(
      id: 'EMI-ACT-1001',
      customerId: 'CUST-1001',
      customerName: 'Ravi Kumar',
      customerMobile: '9876543210',
      productName: 'Samsung 55" 4K Smart TV',
      category: 'Television',
      productPrice: 45000,
      downPayment: 10000,
      remainingAmount: 24500, // 35000 - 3 * 3500
      emiMonths: 10,
      emiAmount: 3500,
      startDate: isoFormat.format(raviStartDate),
      firstDueDate: isoFormat.format(DateTime(today.year, today.month - 3, 10)),
      status: 'ACTIVE',
      createdAt: isoFormat.format(raviStartDate),
      address: 'No 14, Gandhi Road, Chennai',
      referenceName: 'Murugan (Brother)',
      notes: 'Delivered in good condition',
    );
    accounts.add(raviAcc);

    // Ravi installments
    for (int i = 1; i <= 10; i++) {
      String dueDateStr;
      String status;
      String? paidDate;
      String? payMethod;
      String? txnId;

      if (i <= 3) {
        // Paid installments in past months
        final dt = DateTime(today.year, today.month - (4 - i), 10);
        dueDateStr = isoFormat.format(dt);
        status = EmiStatus.paid;
        paidDate = isoFormat.format(dt);
        payMethod = i == 1 ? 'Cash' : 'UPI';
        txnId = 'TXN-RAVI-${1000 + i}';

        payments.add(PaymentModel(
          id: 'PAY-${payments.length + 101}',
          emiAccountId: raviAcc.id,
          installmentId: 'INST-RAVI-$i',
          customerId: raviAcc.customerId,
          customerName: raviAcc.customerName,
          installmentNumber: i,
          amount: 3500,
          paymentDate: paidDate,
          paymentMethod: payMethod,
          transactionId: txnId,
          status: 'Paid',
          notes: 'Customer paid on time',
        ));
      } else if (i == 4) {
        // Due soon in 5 days
        dueDateStr = isoFormat.format(raviDueSoonDate);
        status = EmiStatus.dueSoon;
      } else {
        // Pending future months
        final dt = DateTime(today.year, today.month + (i - 4), 10);
        dueDateStr = isoFormat.format(dt);
        status = EmiStatus.pending;
      }

      installments.add(EmiInstallment(
        id: 'INST-RAVI-$i',
        emiAccountId: raviAcc.id,
        customerId: raviAcc.customerId,
        installmentNumber: i,
        amount: 3500,
        dueDate: dueDateStr,
        status: status,
        paidDate: paidDate,
        paymentMethod: payMethod,
        transactionId: txnId,
      ));
    }

    // Ravi Product 1 Reminder
    reminders.add(ReminderModel(
      id: 'REM-1001',
      customerId: 'CUST-1001',
      installmentId: 'INST-RAVI-4',
      title: '🟠 EMI Due Soon',
      message: 'Your VENGAI MART EMI of ₹3,500 for Samsung 55" TV is due in 5 days (${EmiHelper.formatDate(isoFormat.format(raviDueSoonDate))}).',
      createdAt: isoFormat.format(today),
      isRead: false,
    ));

    // --- 1B. RAVI KUMAR - 2ND PRODUCT (Bought on different date: 1 month ago) ---
    final raviProd2StartDate = DateTime(today.year, today.month - 1, 20);
    final raviProd2Acc = EmiAccount(
      id: 'EMI-ACT-1001-B',
      customerId: 'CUST-1001',
      customerName: 'Ravi Kumar',
      customerMobile: '9876543210',
      productName: 'Sony HT-S20R Soundbar',
      category: 'Audio',
      productPrice: 12000,
      downPayment: 3000,
      interestRate: 12.0,
      interestAmount: 900,
      totalPayable: 9900,
      remainingAmount: 8250, // 9900 - 1650
      emiMonths: 6,
      emiAmount: 1650,
      startDate: isoFormat.format(raviProd2StartDate),
      firstDueDate: isoFormat.format(DateTime(today.year, today.month - 1, 20)),
      status: 'ACTIVE',
      createdAt: isoFormat.format(raviProd2StartDate),
      address: 'No 14, Gandhi Road, Chennai',
    );
    accounts.add(raviProd2Acc);

    // Installment 1: Paid 1 month ago
    final raviP2Inst1Date = isoFormat.format(DateTime(today.year, today.month - 1, 20));
    installments.add(EmiInstallment(
      id: 'INST-RAVI-P2-1',
      emiAccountId: raviProd2Acc.id,
      customerId: raviProd2Acc.customerId,
      installmentNumber: 1,
      amount: 1650,
      dueDate: raviP2Inst1Date,
      status: EmiStatus.paid,
      paidDate: raviP2Inst1Date,
      paymentMethod: 'UPI',
      transactionId: 'TXN-RAVI-P2-01',
    ));
    payments.add(PaymentModel(
      id: 'PAY-${payments.length + 101}',
      emiAccountId: raviProd2Acc.id,
      installmentId: 'INST-RAVI-P2-1',
      customerId: raviProd2Acc.customerId,
      customerName: raviProd2Acc.customerName,
      installmentNumber: 1,
      amount: 1650,
      paymentDate: raviP2Inst1Date,
      paymentMethod: 'UPI',
      transactionId: 'TXN-RAVI-P2-01',
      status: 'Paid',
      notes: 'Paid via UPI',
    ));

    // Installment 2: Pending, due in 15 days
    final raviP2Inst2Date = isoFormat.format(today.add(const Duration(days: 15)));
    installments.add(EmiInstallment(
      id: 'INST-RAVI-P2-2',
      emiAccountId: raviProd2Acc.id,
      customerId: raviProd2Acc.customerId,
      installmentNumber: 2,
      amount: 1650,
      dueDate: raviP2Inst2Date,
      status: EmiStatus.pending,
    ));

    // Remaining installments 3 to 6
    for (int i = 3; i <= 6; i++) {
      final dt = DateTime(today.year, today.month + (i - 2), 20);
      installments.add(EmiInstallment(
        id: 'INST-RAVI-P2-$i',
        emiAccountId: raviProd2Acc.id,
        customerId: raviProd2Acc.customerId,
        installmentNumber: i,
        amount: 1650,
        dueDate: isoFormat.format(dt),
        status: EmiStatus.pending,
      ));
    }

    // --- 2. PRIYA SHARMA (Due Today) ---
    final priyaAcc = EmiAccount(
      id: 'EMI-ACT-1002',
      customerId: 'CUST-1002',
      customerName: 'Priya Sharma',
      customerMobile: '9845123789',
      productName: 'LG 7kg Front Load Washing Machine',
      category: 'Home Appliances',
      productPrice: 36000,
      downPayment: 6000,
      remainingAmount: 27000,
      emiMonths: 10,
      emiAmount: 3000,
      startDate: isoFormat.format(DateTime(today.year, today.month - 1, 15)),
      firstDueDate: isoFormat.format(DateTime(today.year, today.month - 1, 15)),
      status: 'ACTIVE',
      createdAt: isoFormat.format(DateTime(today.year, today.month - 1, 15)),
      address: 'Flat 4B, Lotus Apartments, Bangalore',
    );
    accounts.add(priyaAcc);

    // Priya Installment 1: Paid, Installment 2: Due Today
    final priyaInst1Date = isoFormat.format(DateTime(today.year, today.month - 1, today.day));
    installments.add(EmiInstallment(
      id: 'INST-PRIYA-1',
      emiAccountId: priyaAcc.id,
      customerId: priyaAcc.customerId,
      installmentNumber: 1,
      amount: 3000,
      dueDate: priyaInst1Date,
      status: EmiStatus.paid,
      paidDate: priyaInst1Date,
      paymentMethod: 'UPI',
      transactionId: 'TXN-PRIYA-001',
    ));
    payments.add(PaymentModel(
      id: 'PAY-${payments.length + 101}',
      emiAccountId: priyaAcc.id,
      installmentId: 'INST-PRIYA-1',
      customerId: priyaAcc.customerId,
      customerName: priyaAcc.customerName,
      installmentNumber: 1,
      amount: 3000,
      paymentDate: priyaInst1Date,
      paymentMethod: 'UPI',
      transactionId: 'TXN-PRIYA-001',
    ));

    // Installment 2: Due Today
    installments.add(EmiInstallment(
      id: 'INST-PRIYA-2',
      emiAccountId: priyaAcc.id,
      customerId: priyaAcc.customerId,
      installmentNumber: 2,
      amount: 3000,
      dueDate: isoFormat.format(today),
      status: EmiStatus.dueToday,
    ));

    for (int i = 3; i <= 10; i++) {
      final dt = DateTime(today.year, today.month + (i - 2), today.day);
      installments.add(EmiInstallment(
        id: 'INST-PRIYA-$i',
        emiAccountId: priyaAcc.id,
        customerId: priyaAcc.customerId,
        installmentNumber: i,
        amount: 3000,
        dueDate: isoFormat.format(dt),
        status: EmiStatus.pending,
      ));
    }

    reminders.add(ReminderModel(
      id: 'REM-1002',
      customerId: 'CUST-1002',
      installmentId: 'INST-PRIYA-2',
      title: '⚠ EMI Due Today',
      message: 'Your VENGAI MART EMI of ₹3,000 is due TODAY. Please pay promptly to avoid penalty.',
      createdAt: isoFormat.format(today),
      isRead: false,
    ));

    // --- 3. Suresh (Overdue by 4 days) ---
    final sureshOverdueDate = today.subtract(const Duration(days: 4));
    final sureshAcc = EmiAccount(
      id: 'EMI-ACT-1003',
      customerId: 'CUST-1003',
      customerName: 'Suresh',
      customerMobile: '9789123456',
      productName: 'Whirlpool Double Door Refrigerator',
      category: 'Home Appliances',
      productPrice: 32000,
      downPayment: 8000,
      remainingAmount: 20000,
      emiMonths: 6,
      emiAmount: 4000,
      startDate: isoFormat.format(DateTime(today.year, today.month - 2, 5)),
      firstDueDate: isoFormat.format(DateTime(today.year, today.month - 2, 5)),
      status: 'OVERDUE',
      createdAt: isoFormat.format(DateTime(today.year, today.month - 2, 5)),
      address: '22 Cross Road, Coimbatore',
    );
    accounts.add(sureshAcc);

    // Suresh Installment 1: Paid
    final sureshInst1Date = isoFormat.format(DateTime(today.year, today.month - 2, 5));
    installments.add(EmiInstallment(
      id: 'INST-SURESH-1',
      emiAccountId: sureshAcc.id,
      customerId: sureshAcc.customerId,
      installmentNumber: 1,
      amount: 4000,
      dueDate: sureshInst1Date,
      status: EmiStatus.paid,
      paidDate: sureshInst1Date,
      paymentMethod: 'Cash',
      transactionId: 'TXN-SURESH-001',
    ));
    payments.add(PaymentModel(
      id: 'PAY-${payments.length + 101}',
      emiAccountId: sureshAcc.id,
      installmentId: 'INST-SURESH-1',
      customerId: sureshAcc.customerId,
      customerName: sureshAcc.customerName,
      installmentNumber: 1,
      amount: 4000,
      paymentDate: sureshInst1Date,
      paymentMethod: 'Cash',
      transactionId: 'TXN-SURESH-001',
    ));

    // Suresh Installment 2: Overdue
    installments.add(EmiInstallment(
      id: 'INST-SURESH-2',
      emiAccountId: sureshAcc.id,
      customerId: sureshAcc.customerId,
      installmentNumber: 2,
      amount: 4000,
      dueDate: isoFormat.format(sureshOverdueDate),
      status: EmiStatus.overdue,
    ));

    for (int i = 3; i <= 6; i++) {
      final dt = DateTime(today.year, today.month + (i - 2), 5);
      installments.add(EmiInstallment(
        id: 'INST-SURESH-$i',
        emiAccountId: sureshAcc.id,
        customerId: sureshAcc.customerId,
        installmentNumber: i,
        amount: 4000,
        dueDate: isoFormat.format(dt),
        status: EmiStatus.pending,
      ));
    }

    reminders.add(ReminderModel(
      id: 'REM-1003',
      customerId: 'CUST-1003',
      installmentId: 'INST-SURESH-2',
      title: '! EMI Overdue Alert',
      message: 'Your VENGAI MART EMI of ₹4,000 is 4 days overdue. Please clear immediately.',
      createdAt: isoFormat.format(sureshOverdueDate),
      isRead: false,
    ));

    // --- 4. LAKSHMI NARAYANAN (Completed EMI Account - All 10 Paid) ---
    final lakshmiAcc = EmiAccount(
      id: 'EMI-ACT-1004',
      customerId: 'CUST-1004',
      customerName: 'Lakshmi Narayanan',
      customerMobile: '9443123456',
      productName: 'Sony Soundbar 5.1 System',
      category: 'Audio',
      productPrice: 24000,
      downPayment: 4000,
      remainingAmount: 0,
      emiMonths: 10,
      emiAmount: 2000,
      startDate: isoFormat.format(DateTime(today.year - 1, today.month, 1)),
      firstDueDate: isoFormat.format(DateTime(today.year - 1, today.month + 1, 1)),
      status: 'COMPLETED',
      createdAt: isoFormat.format(DateTime(today.year - 1, today.month, 1)),
      address: '77 Temple View St, Madurai',
    );
    accounts.add(lakshmiAcc);

    for (int i = 1; i <= 10; i++) {
      final dt = DateTime(today.year - 1, today.month + i, 1);
      final dtStr = isoFormat.format(dt);
      installments.add(EmiInstallment(
        id: 'INST-LAKSHMI-$i',
        emiAccountId: lakshmiAcc.id,
        customerId: lakshmiAcc.customerId,
        installmentNumber: i,
        amount: 2000,
        dueDate: dtStr,
        status: EmiStatus.paid,
        paidDate: dtStr,
        paymentMethod: i % 2 == 0 ? 'UPI' : 'Cash',
        transactionId: 'TXN-LAK-${2000 + i}',
      ));
      payments.add(PaymentModel(
        id: 'PAY-${payments.length + 101}',
        emiAccountId: lakshmiAcc.id,
        installmentId: 'INST-LAKSHMI-$i',
        customerId: lakshmiAcc.customerId,
        customerName: lakshmiAcc.customerName,
        installmentNumber: i,
        amount: 2000,
        paymentDate: dtStr,
        paymentMethod: i % 2 == 0 ? 'UPI' : 'Cash',
        transactionId: 'TXN-LAK-${2000 + i}',
      ));
    }

    // --- 5. KARTHIK RAJA (All Pending - Newly started EMI) ---
    final karthikDueDate = today.add(const Duration(days: 18));
    final karthikAcc = EmiAccount(
      id: 'EMI-ACT-1005',
      customerId: 'CUST-1005',
      customerName: 'Karthik Raja',
      customerMobile: '9940123456',
      productName: 'Voltas 1.5 Ton Split AC',
      category: 'Air Conditioners',
      productPrice: 42000,
      downPayment: 6000,
      remainingAmount: 36000,
      emiMonths: 12,
      emiAmount: 3000,
      startDate: isoFormat.format(today),
      firstDueDate: isoFormat.format(karthikDueDate),
      status: 'ACTIVE',
      createdAt: isoFormat.format(today),
      address: '88 Trunk Road, Salem',
    );
    accounts.add(karthikAcc);

    for (int i = 1; i <= 12; i++) {
      final dt = DateTime(karthikDueDate.year, karthikDueDate.month + (i - 1), karthikDueDate.day);
      installments.add(EmiInstallment(
        id: 'INST-KARTHIK-$i',
        emiAccountId: karthikAcc.id,
        customerId: karthikAcc.customerId,
        installmentNumber: i,
        amount: 3000,
        dueDate: isoFormat.format(dt),
        status: EmiStatus.pending,
      ));
    }

    return {
      'users': users,
      'accounts': accounts,
      'installments': installments,
      'payments': payments,
      'reminders': reminders,
    };
  }
}
