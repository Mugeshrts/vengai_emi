import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/color.dart';
import '../../core/models/user_model.dart';
import '../../core/models/emi_account_model.dart';
import '../../core/models/emi_installment_model.dart';
import '../../core/models/payment_model.dart';
import '../../core/models/reminder_model.dart';
import '../../core/models/chit_fund_model.dart';
import '../../core/service/storage_service.dart';
import '../../core/service/emi_helper.dart';
import '../auth/auth_controller.dart';

class CustomerController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AuthController _auth = Get.find<AuthController>();

  final RxInt selectedNavIndex = 0.obs;

  // Multi-Product Support:
  // A customer can have 1, 2, or many products purchased on different dates!
  final RxList<EmiAccount> customerAccounts = <EmiAccount>[].obs;
  final RxString selectedAccountId = 'ALL'.obs; // 'ALL' or specific account.id

  final RxList<EmiInstallment> allInstallments = <EmiInstallment>[].obs;
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxList<ReminderModel> reminders = <ReminderModel>[].obs;
  final RxList<ChitFund> customerChitFunds = <ChitFund>[].obs;
  final RxList<ChitPayment> customerChitPayments = <ChitPayment>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomerData();
  }

  UserModel? get currentUser => _auth.currentUser.value ?? _storage.getSessionUser();

  String get customerId {
    final user = currentUser;
    if (user != null && user.customerId != null && user.customerId!.isNotEmpty) {
      return user.customerId!;
    }
    return '';
  }

  void loadCustomerData() {
    _storage.refreshInstallmentStatuses();

    final cId = customerId;
    if (cId.isEmpty) return;

    // Load ALL accounts for this customer (Supports multiple purchases)
    final allAccounts = _storage.getEmiAccounts();
    final userAccounts = allAccounts.where((a) => a.customerId == cId).toList();
    // Sort so most recent purchases or active ones are on top
    userAccounts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    customerAccounts.assignAll(userAccounts);

    // If previously selected account no longer exists, reset to 'ALL' or first
    if (selectedAccountId.value != 'ALL' &&
        !userAccounts.any((a) => a.id == selectedAccountId.value)) {
      selectedAccountId.value = userAccounts.isNotEmpty ? userAccounts.first.id : 'ALL';
    }

    // Load all installments for this customer's accounts
    final allStorageInsts = _storage.getInstallments();
    final userInsts = allStorageInsts.where((i) => i.customerId == cId).toList();
    userInsts.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    allInstallments.assignAll(userInsts);

    // Load only this customer's payments
    final allPayments = _storage.getPayments();
    final userPayments = allPayments.where((p) => p.customerId == cId).toList();
    userPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    payments.assignAll(userPayments);

    // Load only this customer's reminders
    final allReminders = _storage.getReminders();
    final userReminders = allReminders.where((r) => r.customerId == cId).toList();
    userReminders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    reminders.assignAll(userReminders);

    // Load enrolled Chit Funds for this customer
    final allChits = _storage.getChitFunds();
    final enrolledChits = allChits.where((f) => f.members.any((m) => m.customerId == cId)).toList();
    customerChitFunds.assignAll(enrolledChits);

    // Load customer's Chit Payments
    final allChitPayments = _storage.getChitPayments();
    final userChitPayments = allChitPayments.where((p) => p.customerId == cId).toList();
    userChitPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    customerChitPayments.assignAll(userChitPayments);
  }

  // --- Active vs Completed Products ---
  List<EmiAccount> get activeAccounts =>
      customerAccounts.where((a) => a.remainingAmount > 0 && !a.isCompleted).toList();

  List<EmiAccount> get completedAccounts =>
      customerAccounts.where((a) => a.isCompleted || a.remainingAmount <= 0).toList();

  bool get hasMultipleProducts => customerAccounts.length > 1;

  EmiAccount? get currentSelectedAccount {
    if (selectedAccountId.value == 'ALL' || selectedAccountId.value.isEmpty) {
      return customerAccounts.isNotEmpty ? customerAccounts.first : null;
    }
    return customerAccounts.firstWhereOrNull((a) => a.id == selectedAccountId.value) ??
        (customerAccounts.isNotEmpty ? customerAccounts.first : null);
  }

  EmiAccount? get account => currentSelectedAccount;
  List<EmiInstallment> get installments => allInstallments;

  // --- Installments currently displayed ---
  List<EmiInstallment> get displayedInstallments {
    if (selectedAccountId.value == 'ALL' || selectedAccountId.value.isEmpty) {
      final list = List<EmiInstallment>.from(allInstallments);
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return list;
    } else {
      final list = allInstallments.where((i) => i.emiAccountId == selectedAccountId.value).toList();
      list.sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));
      return list;
    }
  }

  // Find associated EmiAccount for any installment
  EmiAccount? getAccountForInstallment(EmiInstallment installment) {
    return customerAccounts.firstWhereOrNull((a) => a.id == installment.emiAccountId);
  }

  // --- Immediate Next EMI across ALL products (or selected product) ---
  EmiInstallment? get nextInstallment {
    if (selectedAccountId.value != 'ALL' && selectedAccountId.value.isNotEmpty) {
      final accInsts = allInstallments.where((i) => i.emiAccountId == selectedAccountId.value && !i.isPaid).toList();
      accInsts.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return accInsts.isNotEmpty ? accInsts.first : null;
    }

    // If 'ALL', find the earliest unpaid installment across ALL active products!
    final unpaid = allInstallments.where((i) => !i.isPaid).toList();
    unpaid.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return unpaid.isNotEmpty ? unpaid.first : null;
  }

  String get nextEmiStatus {
    final next = nextInstallment;
    if (next == null) return 'COMPLETED';
    return EmiHelper.computeInstallmentStatus(next);
  }

  int get daysRemainingForNextEmi {
    final next = nextInstallment;
    if (next == null) return 0;
    return EmiHelper.getDaysDifference(next.dueDate);
  }

  // --- Combined Financial Metrics across all products (or selected product) ---
  double get totalEmiValue {
    if (selectedAccountId.value != 'ALL' && selectedAccountId.value.isNotEmpty) {
      final acc = currentSelectedAccount;
      if (acc == null) return 0.0;
      return acc.totalPayable;
    }
    return customerAccounts.fold(0.0, (sum, a) => sum + a.totalPayable);
  }

  double get totalMonthlyCommitment {
    // Sum of monthly EMIs for all active products
    if (selectedAccountId.value != 'ALL' && selectedAccountId.value.isNotEmpty) {
      final acc = currentSelectedAccount;
      return acc != null ? acc.emiAmount : 0.0;
    }
    return activeAccounts.fold(0.0, (sum, a) => sum + a.emiAmount);
  }

  double get paidAmount {
    if (selectedAccountId.value != 'ALL' && selectedAccountId.value.isNotEmpty) {
      final accId = selectedAccountId.value;
      return payments.where((p) => p.emiAccountId == accId).fold(0.0, (sum, p) => sum + p.amount);
    }
    return payments.fold(0.0, (sum, p) => sum + p.amount);
  }

  double get remainingAmount {
    if (selectedAccountId.value != 'ALL' && selectedAccountId.value.isNotEmpty) {
      final acc = currentSelectedAccount;
      if (acc == null) return 0.0;
      return acc.remainingAmount;
    }
    return customerAccounts.fold(0.0, (sum, a) => sum + a.remainingAmount);
  }

  int get paidCount {
    if (selectedAccountId.value != 'ALL' && selectedAccountId.value.isNotEmpty) {
      return allInstallments.where((i) => i.emiAccountId == selectedAccountId.value && i.isPaid).length;
    }
    return allInstallments.where((i) => i.isPaid).length;
  }

  int get totalCount {
    if (selectedAccountId.value != 'ALL' && selectedAccountId.value.isNotEmpty) {
      return allInstallments.where((i) => i.emiAccountId == selectedAccountId.value).length;
    }
    return allInstallments.length;
  }

  double get progressFraction {
    if (totalCount == 0) return 0.0;
    return (paidCount / totalCount).clamp(0.0, 1.0);
  }

  int get unreadRemindersCount {
    return reminders.where((r) => !r.isRead).length;
  }

  void markReminderAsRead(String reminderId) async {
    final index = reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      reminders[index].isRead = true;
      reminders.refresh();
      final allStorageRems = _storage.getReminders();
      final storeIdx = allStorageRems.indexWhere((r) => r.id == reminderId);
      if (storeIdx != -1) {
        allStorageRems[storeIdx].isRead = true;
        await _storage.saveReminders(allStorageRems);
      }
    }
  }

  void markAllRemindersAsRead() async {
    for (var r in reminders) {
      r.isRead = true;
    }
    reminders.refresh();
    final allStorageRems = _storage.getReminders();
    for (var r in allStorageRems) {
      if (r.customerId == customerId) {
        r.isRead = true;
      }
    }
    await _storage.saveReminders(allStorageRems);
  }

  // --- UPI Intent Launch (Supports Late Penalty) ---
  Future<bool> launchUpiIntent(EmiInstallment installment, {double? overrideAmount}) async {
    final settings = _storage.getSettings();
    final upiId = Uri.encodeComponent(settings['upiId'] ?? 'vengaimart@upi');
    final payeeName = Uri.encodeComponent(settings['payeeName'] ?? 'VENGAI MART');

    final penaltyCalc = EmiHelper.calculateLatePenalty(amount: installment.amount, dueDateStr: installment.dueDate);
    final totalPayable = overrideAmount ?? (penaltyCalc['isPenaltyApplicable'] == true ? penaltyCalc['totalDue'] as double : installment.amount);
    final amount = totalPayable.toStringAsFixed(2);

    final relatedAcc = getAccountForInstallment(installment);
    final prodName = relatedAcc?.productName ?? 'Product';
    final note = Uri.encodeComponent('VENGAI MART - $prodName EMI #${installment.installmentNumber}');
    final txnRef = 'VMEMI${DateTime.now().millisecondsSinceEpoch % 1000000}';

    final upiUriString =
        'upi://pay?pa=$upiId&pn=$payeeName&am=$amount&cu=INR&tn=$note&tr=$txnRef';
    final Uri upiUri = Uri.parse(upiUriString);

    try {
      final launched = await launchUrl(
        upiUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(upiUri);
      }
      return true;
    } catch (_) {
      Get.snackbar(
        'UPI Application',
        'Could not automatically open UPI app. You can record manual offline payment or verify your installed UPI apps.',
        backgroundColor: Colors.amber.shade100,
        colorText: Colors.brown.shade900,
        duration: const Duration(seconds: 4),
      );
      return false;
    }
  }

  // --- Offline Payment Confirmation (Supports Late Penalty Record) ---
  Future<void> confirmOfflinePayment(EmiInstallment installment, {double penaltyAmount = 0.0}) async {
    final relatedAcc = getAccountForInstallment(installment);
    if (relatedAcc == null) return;

    final iso = DateFormat('yyyy-MM-dd');
    final todayStr = iso.format(DateTime.now());
    final txnId = 'UPI-${DateTime.now().millisecondsSinceEpoch % 10000000}';

    // 1. Update installment locally
    final allStorageInsts = _storage.getInstallments();
    final idx = allStorageInsts.indexWhere((i) => i.id == installment.id);
    if (idx != -1) {
      allStorageInsts[idx].status = EmiStatus.paid;
      allStorageInsts[idx].paidDate = todayStr;
      allStorageInsts[idx].paymentMethod = 'UPI';
      allStorageInsts[idx].transactionId = txnId;
      allStorageInsts[idx].penaltyAmount = penaltyAmount;
      await _storage.saveInstallments(allStorageInsts);
    }

    // 2. Insert into payments
    final allPayments = _storage.getPayments();
    final totalPaidAmount = installment.amount + penaltyAmount;
    final newPayment = PaymentModel(
      id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      emiAccountId: relatedAcc.id,
      installmentId: installment.id,
      customerId: relatedAcc.customerId,
      customerName: relatedAcc.customerName,
      installmentNumber: installment.installmentNumber,
      amount: totalPaidAmount,
      penaltyAmount: penaltyAmount,
      paymentDate: todayStr,
      paymentMethod: 'UPI',
      transactionId: txnId,
      status: 'Paid',
      notes: penaltyAmount > 0
          ? 'Customer UPI Payment (Includes ₹${penaltyAmount.toStringAsFixed(0)} late penalty fee)'
          : 'Customer self-service UPI payment for ${relatedAcc.productName}',
    );
    allPayments.insert(0, newPayment);
    await _storage.savePayments(allPayments);

    // 3. Update account remaining balance (base principal deduction)
    final allStorageAccounts = _storage.getEmiAccounts();
    final accIdx = allStorageAccounts.indexWhere((a) => a.id == relatedAcc.id);
    if (accIdx != -1) {
      final updatedRemaining = (allStorageAccounts[accIdx].remainingAmount - installment.amount).clamp(0.0, double.infinity);
      final customerAllInsts = allStorageInsts.where((i) => i.emiAccountId == relatedAcc.id).toList();
      final allPaid = customerAllInsts.every((i) => i.isPaid);

      allStorageAccounts[accIdx].remainingAmount = updatedRemaining;
      allStorageAccounts[accIdx].status = allPaid ? 'COMPLETED' : 'ACTIVE';
      await _storage.saveEmiAccounts(allStorageAccounts);
    }

    // 4. Add local reminder confirmation
    final allStorageReminders = _storage.getReminders();
    allStorageReminders.insert(
      0,
      ReminderModel(
        id: 'REM-${DateTime.now().millisecondsSinceEpoch}',
        customerId: relatedAcc.customerId,
        installmentId: installment.id,
        title: '✓ Payment Recorded',
        message: 'Your payment of ${EmiHelper.formatCurrency(totalPaidAmount)} for ${relatedAcc.productName} (EMI #${installment.installmentNumber}) has been recorded.',
        createdAt: todayStr,
        isRead: false,
      ),
    );
    await _storage.saveReminders(allStorageReminders);

    loadCustomerData();

    Get.snackbar(
      'Payment Recorded',
      'EMI #${installment.installmentNumber} for ${relatedAcc.productName} marked as Paid!',
      backgroundColor: AppColors.paidBg,
      colorText: AppColors.paid,
      duration: const Duration(seconds: 3),
    );
  }

  // --- Pay Chit Fund Contribution via UPI or Confirmation ---
  Future<bool> payCustomerChitContribution({
    required ChitFund fund,
    required ChitMember member,
  }) async {
    final iso = DateFormat('yyyy-MM-dd');
    final todayStr = iso.format(DateTime.now());
    final txnId = 'CHIT-UPI-${DateTime.now().millisecondsSinceEpoch % 10000000}';

    // 1. Record chit payment
    final allChitPayments = _storage.getChitPayments();
    final payment = ChitPayment(
      id: 'CHIT-PAY-${DateTime.now().millisecondsSinceEpoch}',
      chitFundId: fund.id,
      schemeName: fund.schemeName,
      customerId: member.customerId,
      customerName: member.customerName,
      monthNumber: member.monthsPaid + 1,
      amount: fund.monthlyContribution,
      paymentDate: todayStr,
      paymentMethod: 'UPI',
      transactionId: txnId,
      notes: 'Customer contribution for Month #${member.monthsPaid + 1}',
    );
    allChitPayments.insert(0, payment);
    await _storage.saveChitPayments(allChitPayments);

    // 2. Update member contribution in ChitFund
    final allFunds = _storage.getChitFunds();
    final fIdx = allFunds.indexWhere((f) => f.id == fund.id);
    if (fIdx != -1) {
      final f = allFunds[fIdx];
      final mIdx = f.members.indexWhere((m) => m.customerId == member.customerId);
      if (mIdx != -1) {
        f.members[mIdx].monthsPaid += 1;
        f.members[mIdx].totalContributed += fund.monthlyContribution;
        if (f.members[mIdx].monthsPaid >= f.durationMonths) {
          f.members[mIdx].status = 'MATURED';
        }
      }
      allFunds[fIdx] = f;
      await _storage.saveChitFunds(allFunds);
    }

    loadCustomerData();
    Get.snackbar(
      'Contribution Received!',
      'Paid ${EmiHelper.formatCurrency(fund.monthlyContribution)} for Month #${member.monthsPaid} of ${fund.schemeName}',
      backgroundColor: AppColors.paidBg,
      colorText: AppColors.paid,
      duration: const Duration(seconds: 3),
    );
    return true;
  }
}
