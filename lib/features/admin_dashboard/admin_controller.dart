import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/models/user_model.dart';
import '../../core/models/emi_account_model.dart';
import '../../core/models/emi_installment_model.dart';
import '../../core/models/payment_model.dart';
import '../../core/models/reminder_model.dart';
import '../../core/models/chit_fund_model.dart';
import '../../core/service/storage_service.dart';
import '../../core/service/emi_helper.dart';

class AdminController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxInt selectedNavIndex = 0.obs;

  // Storage data
  final RxList<EmiAccount> accounts = <EmiAccount>[].obs;
  final RxList<EmiInstallment> installments = <EmiInstallment>[].obs;
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<ChitFund> chitFunds = <ChitFund>[].obs;
  final RxList<ChitPayment> chitPayments = <ChitPayment>[].obs;

  List<UserModel> get customers => users.where((u) => u.isCustomer).toList();

  // Search & Filter
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  // Settings
  final TextEditingController upiIdController = TextEditingController();
  final TextEditingController payeeNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAllData();
    final settings = _storage.getSettings();
    upiIdController.text = settings['upiId'] ?? '';
    payeeNameController.text = settings['payeeName'] ?? '';
  }

  void loadAllData() {
    _storage.refreshInstallmentStatuses();
    accounts.assignAll(_storage.getEmiAccounts());
    installments.assignAll(_storage.getInstallments());
    payments.assignAll(_storage.getPayments());
    users.assignAll(_storage.getUsers());
    chitFunds.assignAll(_storage.getChitFunds());
    chitPayments.assignAll(_storage.getChitPayments());
  }

  // --- Dynamic Dashboard & Report Metrics (Requirement 18 & 32) ---
  int get totalCustomers {
    // Unique customer IDs among accounts or customer role users
    final set = <String>{};
    for (var a in accounts) {
      set.add(a.customerId);
    }
    for (var u in users) {
      if (u.isCustomer && u.customerId != null) {
        set.add(u.customerId!);
      }
    }
    return set.length;
  }

  int get activeEmiCount =>
      accounts.where((a) => a.status.toUpperCase() != 'COMPLETED').length;

  int get completedEmiCount =>
      accounts.where((a) => a.status.toUpperCase() == 'COMPLETED').length;

  double get totalEmiValue =>
      accounts.fold(0.0, (sum, a) => sum + (a.productPrice - a.downPayment));

  double get collectedAmount =>
      payments.fold(0.0, (sum, p) => sum + p.amount);

  double get remainingAmount =>
      accounts.fold(0.0, (sum, a) => sum + a.remainingAmount);

  double get collectionProgress {
    if (totalEmiValue <= 0) return 0.0;
    final progress = collectedAmount / totalEmiValue;
    return progress.clamp(0.0, 1.0);
  }

  double get todayCollection {
    final nowStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return payments.where((p) => p.paymentDate.startsWith(nowStr)).fold(
      0.0,
      (sum, p) => sum + p.amount,
    );
  }

  double get thisMonthCollection {
    final nowMonthStr = DateFormat('yyyy-MM').format(DateTime.now());
    return payments.where((p) => p.paymentDate.startsWith(nowMonthStr)).fold(
      0.0,
      (sum, p) => sum + p.amount,
    );
  }

  int get overdueCount {
    return installments
        .where((i) => !i.isPaid && EmiHelper.computeInstallmentStatus(i) == EmiStatus.overdue)
        .length;
  }

  double get totalOverdueAmount {
    return installments
        .where((i) => !i.isPaid && EmiHelper.computeInstallmentStatus(i) == EmiStatus.overdue)
        .fold(0.0, (sum, i) => sum + i.amount);
  }

  // Total Late Penalty accrued across all overdue installments (₹1 per day per ₹1000)
  double get totalOverduePenaltyAmount {
    return installments
        .where((i) => !i.isPaid && EmiHelper.computeInstallmentStatus(i) == EmiStatus.overdue)
        .fold(0.0, (sum, i) {
      final penaltyCalc = EmiHelper.calculateLatePenalty(amount: i.amount, dueDateStr: i.dueDate);
      return sum + ((penaltyCalc['penaltyAmount'] as num?)?.toDouble() ?? 0.0);
    });
  }

  // Total Overdue Collectible including base and penalties
  double get totalOverdueWithPenalty => totalOverdueAmount + totalOverduePenaltyAmount;

  // Upcoming EMIs (due within next 7 days)
  List<Map<String, dynamic>> get upcomingInstallmentsWithDetails {
    final list = <Map<String, dynamic>>[];
    for (var inst in installments) {
      if (inst.isPaid) continue;
      final status = EmiHelper.computeInstallmentStatus(inst);
      if (status == EmiStatus.dueSoon || status == EmiStatus.dueToday) {
        final account = accounts.firstWhereOrNull((a) => a.id == inst.emiAccountId);
        if (account != null) {
          final days = EmiHelper.getDaysDifference(inst.dueDate);
          list.add({
            'installment': inst,
            'account': account,
            'status': status,
            'days': days,
          });
        }
      }
    }
    list.sort((a, b) => (a['days'] as int).compareTo(b['days'] as int));
    return list;
  }

  // Overdue EMIs with Late Penalty breakdown
  List<Map<String, dynamic>> get overdueInstallmentsWithDetails {
    final list = <Map<String, dynamic>>[];
    for (var inst in installments) {
      if (inst.isPaid) continue;
      final status = EmiHelper.computeInstallmentStatus(inst);
      if (status == EmiStatus.overdue) {
        final account = accounts.firstWhereOrNull((a) => a.id == inst.emiAccountId);
        if (account != null) {
          final penaltyCalc = EmiHelper.calculateLatePenalty(amount: inst.amount, dueDateStr: inst.dueDate);
          final days = (EmiHelper.getDaysDifference(inst.dueDate)).abs();
          list.add({
            'installment': inst,
            'account': account,
            'status': status,
            'daysOverdue': penaltyCalc['daysOverdue'] ?? (days == 0 ? 1 : days),
            'penaltyAmount': penaltyCalc['penaltyAmount'] ?? 0.0,
            'totalDue': penaltyCalc['totalDue'] ?? inst.amount,
          });
        }
      }
    }
    list.sort((a, b) => (b['daysOverdue'] as int).compareTo(a['daysOverdue'] as int));
    return list;
  }

  // --- Filtered Accounts for Customer List ---
  List<EmiAccount> get filteredAccounts {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = selectedFilter.value;

    return accounts.where((acc) {
      // Search matching
      final matchesSearch = query.isEmpty ||
          acc.customerName.toLowerCase().contains(query) ||
          acc.customerMobile.contains(query) ||
          acc.customerId.toLowerCase().contains(query) ||
          acc.productName.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      // Filter matching
      if (filter == 'All') return true;

      final accInstallments = installments.where((i) => i.emiAccountId == acc.id).toList();
      final hasOverdue = accInstallments.any(
          (i) => !i.isPaid && EmiHelper.computeInstallmentStatus(i) == EmiStatus.overdue);
      final hasDueToday = accInstallments.any(
          (i) => !i.isPaid && EmiHelper.computeInstallmentStatus(i) == EmiStatus.dueToday);
      final hasDueSoon = accInstallments.any(
          (i) => !i.isPaid && EmiHelper.computeInstallmentStatus(i) == EmiStatus.dueSoon);

      if (filter == 'Completed') {
        return acc.isCompleted || acc.remainingAmount <= 0;
      }
      if (filter == 'Overdue') {
        return hasOverdue;
      }
      if (filter == 'Due Today') {
        return hasDueToday;
      }
      if (filter == 'Due Soon') {
        return hasDueSoon;
      }
      if (filter == 'Active') {
        return !acc.isCompleted && acc.remainingAmount > 0;
      }

      return true;
    }).toList();
  }

  // Customer Account Next Due Date & Status Helper
  Map<String, dynamic> getCustomerNextEmiSummary(String emiAccountId) {
    final accInsts = installments.where((i) => i.emiAccountId == emiAccountId).toList();
    accInsts.sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));

    final nextUnpaid = accInsts.firstWhereOrNull((i) => !i.isPaid);
    if (nextUnpaid == null) {
      return {
        'nextDueDate': '-',
        'status': 'COMPLETED',
        'nextInstallment': null,
      };
    }

    final status = EmiHelper.computeInstallmentStatus(nextUnpaid);
    final penaltyCalc = EmiHelper.calculateLatePenalty(amount: nextUnpaid.amount, dueDateStr: nextUnpaid.dueDate);
    return {
      'nextDueDate': nextUnpaid.dueDate,
      'status': status,
      'nextInstallment': nextUnpaid,
      'isPenaltyApplicable': penaltyCalc['isPenaltyApplicable'] ?? false,
      'daysOverdue': penaltyCalc['daysOverdue'] ?? 0,
      'penaltyAmount': penaltyCalc['penaltyAmount'] ?? 0.0,
      'totalDue': penaltyCalc['totalDue'] ?? nextUnpaid.amount,
    };
  }

  // --- Create EMI Account & Auto-Generate Schedule (Requirements 22, 23, 24, 25) ---
  Future<bool> createEmiAccount({
    required String customerName,
    required String customerMobile,
    required String customerId,
    required String username,
    required String password,
    required String productName,
    required String category,
    required double productPrice,
    required double downPayment,
    required double interestRate,
    required double interestAmount,
    required double totalPayable,
    required int emiMonths,
    required double emiAmount,
    required DateTime startDate,
    required DateTime firstDueDate,
    String? address,
    String? referenceName,
    String? notes,
  }) async {
    final iso = DateFormat('yyyy-MM-dd');
    final accountId = 'EMI-ACT-${DateTime.now().millisecondsSinceEpoch % 1000000}';

    // Check if customer already exists by customerId or mobile or username
    UserModel? existingUser = users.firstWhereOrNull((u) =>
        (customerId.isNotEmpty && u.customerId == customerId) ||
        (customerMobile.isNotEmpty && u.mobile == customerMobile.trim()) ||
        (username.isNotEmpty && u.username.toLowerCase() == username.trim().toLowerCase()));

    final resolvedCustomerId = existingUser?.customerId ??
        (customerId.trim().isNotEmpty ? customerId.trim() : 'CUST-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}');

    final newAccount = EmiAccount(
      id: accountId,
      customerId: resolvedCustomerId,
      customerName: customerName.trim(),
      customerMobile: customerMobile.trim(),
      productName: productName.trim(),
      category: category.isEmpty ? 'General' : category,
      productPrice: productPrice,
      downPayment: downPayment,
      interestRate: interestRate,
      interestAmount: interestAmount,
      totalPayable: totalPayable,
      remainingAmount: totalPayable,
      emiMonths: emiMonths,
      emiAmount: emiAmount,
      startDate: iso.format(startDate),
      firstDueDate: iso.format(firstDueDate),
      status: 'ACTIVE',
      createdAt: iso.format(DateTime.now()),
      address: address?.trim(),
      referenceName: referenceName?.trim(),
      notes: notes?.trim(),
    );

    // Auto-generate installments (Requirement 25)
    final dueDates = EmiHelper.generateDueDates(firstDueDate, emiMonths);
    final List<EmiInstallment> newInstallments = [];

    for (int i = 0; i < emiMonths; i++) {
      final dueDateStr = iso.format(dueDates[i]);
      final inst = EmiInstallment(
        id: 'INST-${newAccount.id}-${i + 1}',
        emiAccountId: newAccount.id,
        customerId: newAccount.customerId,
        installmentNumber: i + 1,
        amount: emiAmount,
        dueDate: dueDateStr,
        status: EmiStatus.pending,
      );
      // Compute status based on date
      inst.status = EmiHelper.computeInstallmentStatus(inst);
      newInstallments.add(inst);
    }

    // Create user login if new customer, or update password if provided
    if (existingUser == null) {
      final cleanUsername = username.trim().isNotEmpty
          ? username.trim()
          : customerName.toLowerCase().replaceAll(RegExp(r'\s+'), '');
      final cleanPassword = password.trim().isNotEmpty ? password.trim() : '123456';

      final newUser = UserModel(
        id: 'usr_${newAccount.customerId}',
        username: cleanUsername,
        password: cleanPassword,
        name: customerName.trim(),
        mobile: customerMobile.trim(),
        role: 'CUSTOMER',
        customerId: newAccount.customerId,
      );
      users.add(newUser);
      await _storage.saveUsers(users);
    } else if (password.trim().isNotEmpty && password.trim() != existingUser.password) {
      final updatedUser = existingUser.copyWith(password: password.trim());
      final uIdx = users.indexWhere((u) => u.id == existingUser.id);
      if (uIdx != -1) {
        users[uIdx] = updatedUser;
        await _storage.saveUsers(users);
      }
    }

    accounts.add(newAccount);
    installments.addAll(newInstallments);

    await _storage.saveEmiAccounts(accounts);
    await _storage.saveInstallments(installments);

    // Create initial reminder if due soon/today
    final firstInst = newInstallments.first;
    final firstStatus = EmiHelper.computeInstallmentStatus(firstInst);
    if (firstStatus == EmiStatus.dueSoon || firstStatus == EmiStatus.dueToday) {
      final rems = _storage.getReminders();
      rems.add(ReminderModel(
        id: 'REM-${DateTime.now().millisecondsSinceEpoch}',
        customerId: newAccount.customerId,
        installmentId: firstInst.id,
        title: firstStatus == EmiStatus.dueToday ? '⚠ EMI Due Today' : '🟠 EMI Due Soon',
        message: 'Your VENGAI MART EMI of ${EmiHelper.formatCurrency(firstInst.amount)} is due on ${EmiHelper.formatDate(firstInst.dueDate)}.',
        createdAt: iso.format(DateTime.now()),
        isRead: false,
      ));
      await _storage.saveReminders(rems);
    }

    loadAllData();
    return true;
  }

  // --- Chit Fund Dashboard Metrics ---
  int get totalChitSchemes => chitFunds.length;
  int get activeChitSchemes => chitFunds.where((c) => c.status.toUpperCase() == 'ACTIVE').length;
  double get totalChitValue => chitFunds.fold(0.0, (sum, c) => sum + (c.totalValue * (c.members.isEmpty ? c.maxMembers : c.members.length)));
  double get totalChitCollected => chitPayments.fold(0.0, (sum, p) => sum + p.amount);
  int get totalChitMembers => chitFunds.fold(0, (sum, c) => sum + c.members.length);

  // --- Record Payment (Requirements 27 & 28 + Late Penalty Rule) ---
  Future<bool> recordPayment({
    required EmiInstallment installment,
    required EmiAccount account,
    required String paymentMethod,
    double penaltyAmount = 0.0,
    String? transactionId,
    String? notes,
  }) async {
    // Prevent duplicate payment (Requirement 28)
    if (installment.isPaid) {
      Get.snackbar(
        'Payment Notice',
        'This EMI has already been paid.',
        backgroundColor: Colors.amber.shade100,
        colorText: Colors.brown.shade900,
      );
      return false;
    }

    final iso = DateFormat('yyyy-MM-dd');
    final todayStr = iso.format(DateTime.now());
    final effectiveTxnId = (transactionId != null && transactionId.trim().isNotEmpty)
        ? transactionId.trim()
        : 'TXN-${DateTime.now().millisecondsSinceEpoch % 1000000}';

    final totalPaid = installment.amount + penaltyAmount;

    // 1. Mark installment as Paid
    final instIndex = installments.indexWhere((i) => i.id == installment.id);
    if (instIndex != -1) {
      final updatedInst = installments[instIndex].copyWith(
        status: EmiStatus.paid,
        paidDate: todayStr,
        paymentMethod: paymentMethod,
        transactionId: effectiveTxnId,
        penaltyAmount: penaltyAmount,
        notes: notes,
      );
      installments[instIndex] = updatedInst;
    }

    // 2. Create Payment history record
    final newPayment = PaymentModel(
      id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      emiAccountId: account.id,
      installmentId: installment.id,
      customerId: account.customerId,
      customerName: account.customerName,
      installmentNumber: installment.installmentNumber,
      amount: totalPaid,
      penaltyAmount: penaltyAmount,
      paymentDate: todayStr,
      paymentMethod: paymentMethod,
      transactionId: effectiveTxnId,
      status: 'Paid',
      notes: penaltyAmount > 0
          ? '${notes != null && notes.isNotEmpty ? "$notes • " : ""}Includes Late Fee ₹${penaltyAmount.toStringAsFixed(0)}'
          : notes,
    );
    payments.insert(0, newPayment);

    // 3. Update account remaining amount and status (deduct principal installment amount)
    final accIndex = accounts.indexWhere((a) => a.id == account.id);
    if (accIndex != -1) {
      final updatedRemaining = (accounts[accIndex].remainingAmount - installment.amount).clamp(0.0, double.infinity);
      final allAccountInsts = installments.where((i) => i.emiAccountId == account.id).toList();
      final allPaid = allAccountInsts.every((i) => i.isPaid || i.id == installment.id);

      final updatedAcc = accounts[accIndex].copyWith(
        remainingAmount: updatedRemaining,
        status: allPaid ? 'COMPLETED' : 'ACTIVE',
      );
      accounts[accIndex] = updatedAcc;
    }

    // 4. Save to GetStorage
    await _storage.saveInstallments(installments);
    await _storage.savePayments(payments);
    await _storage.saveEmiAccounts(accounts);

    // 5. Add payment confirmation reminder for customer
    final rems = _storage.getReminders();
    rems.insert(
      0,
      ReminderModel(
        id: 'REM-${DateTime.now().millisecondsSinceEpoch}',
        customerId: account.customerId,
        installmentId: installment.id,
        title: '✓ Payment Recorded',
        message: 'Payment of ${EmiHelper.formatCurrency(totalPaid)}${penaltyAmount > 0 ? " (includes ₹${penaltyAmount.toStringAsFixed(0)} late fee)" : ""} for EMI #${installment.installmentNumber} was successfully recorded via $paymentMethod.',
        createdAt: todayStr,
        isRead: false,
      ),
    );
    await _storage.saveReminders(rems);

    loadAllData();
    return true;
  }

  // --- Create Chit Fund (Admin Action: + CREATE FUND) ---
  Future<bool> createChitFund({
    required String schemeName,
    required String category,
    required double totalValue,
    required double monthlyContribution,
    required int durationMonths,
    required int maxMembers,
    double bonusAmount = 0.0,
    String bonusDescription = '',
    required DateTime startDate,
    String? notes,
    List<ChitMember>? initialMembers,
  }) async {
    final iso = DateFormat('yyyy-MM-dd');
    final newFund = ChitFund(
      id: 'CHIT-FND-${DateTime.now().millisecondsSinceEpoch % 100000}',
      schemeName: schemeName.trim(),
      category: category.isEmpty ? 'General' : category,
      totalValue: totalValue,
      monthlyContribution: monthlyContribution,
      durationMonths: durationMonths,
      maxMembers: maxMembers,
      bonusAmount: bonusAmount,
      bonusDescription: bonusDescription.trim(),
      startDate: iso.format(startDate),
      status: 'ACTIVE',
      createdAt: iso.format(DateTime.now()),
      members: initialMembers ?? [],
      notes: notes?.trim(),
    );

    chitFunds.add(newFund);
    await _storage.saveChitFunds(chitFunds);
    loadAllData();
    return true;
  }

  // --- Enroll Member into Chit Fund ---
  Future<bool> enrollCustomerInChit({
    required ChitFund fund,
    required String customerId,
    required String customerName,
    required String customerMobile,
  }) async {
    final fundIdx = chitFunds.indexWhere((f) => f.id == fund.id);
    if (fundIdx == -1) return false;

    final targetFund = chitFunds[fundIdx];
    if (targetFund.members.length >= targetFund.maxMembers) {
      Get.snackbar('Scheme Full', 'Maximum member limit (${targetFund.maxMembers}) reached for this scheme.', backgroundColor: Colors.amber.shade100);
      return false;
    }

    final iso = DateFormat('yyyy-MM-dd');
    final newMember = ChitMember(
      customerId: customerId,
      customerName: customerName,
      customerMobile: customerMobile,
      ticketNumber: targetFund.members.length + 1,
      enrolledDate: iso.format(DateTime.now()),
      monthsPaid: 0,
      totalContributed: 0.0,
      status: 'ACTIVE',
    );

    final updatedMembers = List<ChitMember>.from(targetFund.members)..add(newMember);
    chitFunds[fundIdx] = targetFund.copyWith(members: updatedMembers);

    await _storage.saveChitFunds(chitFunds);
    loadAllData();
    return true;
  }

  // --- Register Customer (for Chit Fund or Standalone) with Username & Password ---
  Future<UserModel> registerCustomer({
    required String name,
    required String mobile,
    required String username,
    required String password,
    String? address,
  }) async {
    final cleanUsername = username.trim().isNotEmpty
        ? username.trim()
        : name.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final cleanPassword = password.trim().isNotEmpty ? password.trim() : '123456';
    final customerId = 'CUST-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}';

    // Check if user already exists
    final existing = users.firstWhereOrNull((u) =>
        u.mobile == mobile.trim() ||
        u.username.toLowerCase() == cleanUsername.toLowerCase());

    if (existing != null) {
      return existing;
    }

    final newUser = UserModel(
      id: 'usr_$customerId',
      username: cleanUsername,
      password: cleanPassword,
      name: name.trim(),
      mobile: mobile.trim(),
      role: 'CUSTOMER',
      customerId: customerId,
    );

    users.add(newUser);
    await _storage.saveUsers(users);
    loadAllData();
    return newUser;
  }

  // --- Create & Enroll New Customer with Username/Password in Chit Fund ---
  Future<bool> createAndEnrollChitCustomer({
    required ChitFund fund,
    required String name,
    required String mobile,
    required String username,
    required String password,
  }) async {
    final newUser = await registerCustomer(
      name: name,
      mobile: mobile,
      username: username,
      password: password,
    );
    return enrollCustomerInChit(
      fund: fund,
      customerId: newUser.customerId ?? newUser.id,
      customerName: newUser.name,
      customerMobile: newUser.mobile,
    );
  }

  // --- Record Chit Payment ---
  Future<bool> recordChitPayment({
    required ChitFund fund,
    required ChitMember member,
    required double amount,
    required String paymentMethod,
    String? transactionId,
    String? notes,
  }) async {
    final iso = DateFormat('yyyy-MM-dd');
    final todayStr = iso.format(DateTime.now());
    final effectiveTxnId = (transactionId != null && transactionId.trim().isNotEmpty)
        ? transactionId.trim()
        : 'TXN-CHIT-${DateTime.now().millisecondsSinceEpoch % 1000000}';

    final payment = ChitPayment(
      id: 'CHIT-PAY-${DateTime.now().millisecondsSinceEpoch}',
      chitFundId: fund.id,
      schemeName: fund.schemeName,
      customerId: member.customerId,
      customerName: member.customerName,
      monthNumber: member.monthsPaid + 1,
      amount: amount,
      paymentDate: todayStr,
      paymentMethod: paymentMethod,
      transactionId: effectiveTxnId,
      notes: notes,
    );
    chitPayments.insert(0, payment);

    // Update member monthsPaid and totalContributed
    final fundIdx = chitFunds.indexWhere((f) => f.id == fund.id);
    if (fundIdx != -1) {
      final f = chitFunds[fundIdx];
      final mIdx = f.members.indexWhere((m) => m.customerId == member.customerId);
      if (mIdx != -1) {
        f.members[mIdx].monthsPaid += 1;
        f.members[mIdx].totalContributed += amount;
        if (f.members[mIdx].monthsPaid >= f.durationMonths) {
          f.members[mIdx].status = 'MATURED';
        }
      }
      chitFunds[fundIdx] = f;
    }

    await _storage.saveChitPayments(chitPayments);
    await _storage.saveChitFunds(chitFunds);
    loadAllData();
    return true;
  }

  // --- Save Admin Settings (UPI ID, Payee Name) ---
  Future<void> saveSettings() async {
    final upiId = upiIdController.text.trim();
    final payee = payeeNameController.text.trim();

    if (upiId.isEmpty) {
      Get.snackbar('Error', 'Please enter a valid UPI ID', backgroundColor: Colors.red.shade100);
      return;
    }

    await _storage.saveSettings(upiId: upiId, payeeName: payee.isEmpty ? 'VENGAI MART' : payee);
    Get.snackbar(
      'Success',
      'Settings saved successfully',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );
  }

  // --- Customer & User Deletion Operations ---
  Future<bool> deleteCustomer({required String customerId, required String customerName}) async {
    final success = await _storage.deleteCustomer(customerId);
    if (success) {
      loadAllData();
      Get.snackbar(
        'Customer Deleted',
        'Successfully removed $customerName and all related accounts/records.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } else {
      Get.snackbar('Error', 'Failed to delete customer', backgroundColor: Colors.red.shade100);
    }
    return success;
  }

  Future<bool> deleteUser({required UserModel user}) async {
    if (user.isAdmin) {
      Get.snackbar('Action Denied', 'Administrator accounts cannot be deleted.', backgroundColor: Colors.orange.shade100);
      return false;
    }
    final success = await _storage.deleteUser(user.id);
    if (success) {
      loadAllData();
      Get.snackbar(
        'User Deleted',
        'User account "${user.username}" (${user.name}) deleted successfully.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } else {
      Get.snackbar('Error', 'Failed to delete user account', backgroundColor: Colors.red.shade100);
    }
    return success;
  }

  Future<bool> deleteEmiAccount({required String accountId, required String productName}) async {
    final success = await _storage.deleteEmiAccount(accountId);
    if (success) {
      loadAllData();
      Get.snackbar(
        'EMI Account Deleted',
        'Successfully removed EMI for $productName ($accountId).',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } else {
      Get.snackbar('Error', 'Failed to delete EMI account', backgroundColor: Colors.red.shade100);
    }
    return success;
  }

  Future<bool> removeChitMember({required String chitFundId, required String customerId, required String memberName}) async {
    final success = await _storage.removeChitMember(chitFundId, customerId);
    if (success) {
      loadAllData();
      Get.snackbar(
        'Member Removed',
        'Successfully removed $memberName from Chit Fund.',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
    } else {
      Get.snackbar('Error', 'Failed to remove member from Chit Fund', backgroundColor: Colors.red.shade100);
    }
    return success;
  }

  // --- Reset Demo Data (Requirement 52) ---
  Future<void> resetDemoData() async {
    await _storage.resetToDemoData();
    loadAllData();
    final settings = _storage.getSettings();
    upiIdController.text = settings['upiId'] ?? '';
    payeeNameController.text = settings['payeeName'] ?? '';
    Get.snackbar(
      'Demo Data Reset',
      'Restored sample customers, accounts, installments, and payment history.',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    upiIdController.dispose();
    payeeNameController.dispose();
    super.onClose();
  }
}
