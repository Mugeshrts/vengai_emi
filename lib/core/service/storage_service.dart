import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/assests.dart';
import '../models/user_model.dart';
import '../models/emi_account_model.dart';
import '../models/emi_installment_model.dart';
import '../models/payment_model.dart';
import '../models/reminder_model.dart';
import '../models/chit_fund_model.dart';
import 'emi_helper.dart';
import 'seed_data.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();

    // Check if initial seed data is loaded
    final isInitialized = _box.read<bool>(AppConstants.keyDataInitialized) ?? false;
    if (!isInitialized) {
      await seedInitialData();
    } else {
      // Re-evaluate statuses dynamically on app launch
      refreshInstallmentStatuses();
      await _migrateChitFundsAndUsers();
    }

    return this;
  }

  // --- Seed / Reset ---
  Future<void> seedInitialData() async {
    final data = SeedData.generateInitialData();

    final List<UserModel> users = data['users'];
    final List<EmiAccount> accounts = data['accounts'];
    final List<EmiInstallment> installments = data['installments'];
    final List<PaymentModel> payments = data['payments'];
    final List<ReminderModel> reminders = data['reminders'];
    final List<ChitFund> chitFunds = data['chitFunds'] ?? [];
    final List<ChitPayment> chitPayments = data['chitPayments'] ?? [];

    await saveUsers(users);
    await saveEmiAccounts(accounts);
    await saveInstallments(installments);
    await savePayments(payments);
    await saveReminders(reminders);
    await saveChitFunds(chitFunds);
    await saveChitPayments(chitPayments);

    // Save default settings
    await _box.write(AppConstants.keySettings, {
      'upiId': AppConstants.defaultUpiId,
      'payeeName': AppConstants.defaultPayeeName,
    });

    await _box.write(AppConstants.keyDataInitialized, true);
  }

  Future<void> resetToDemoData() async {
    // Preserve current session if needed, but per specs restore all demo data
    final currentSession = getSessionUser();
    await _box.erase();
    await seedInitialData();

    // If current session was admin, keep them logged in, or if customer, restore
    if (currentSession != null) {
      final freshUsers = getUsers();
      final user = freshUsers.firstWhereOrNull((u) => u.username == currentSession.username);
      if (user != null) {
        await saveSessionUser(user);
      }
    }
  }

  // --- Session Management ---
  UserModel? getSessionUser() {
    final raw = _box.read(AppConstants.keyCurrentSession);
    if (raw == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> saveSessionUser(UserModel user) async {
    await _box.write(AppConstants.keyCurrentSession, user.toJson());
  }

  Future<void> clearSession() async {
    await _box.remove(AppConstants.keyCurrentSession);
  }

  // --- Users ---
  List<UserModel> getUsers() {
    final raw = _box.read<List>(AppConstants.keyUsers);
    if (raw == null) return [];
    return raw
        .map((item) => UserModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveUsers(List<UserModel> users) async {
    await _box.write(
      AppConstants.keyUsers,
      users.map((e) => e.toJson()).toList(),
    );
  }

  // --- EMI Accounts ---
  List<EmiAccount> getEmiAccounts() {
    final raw = _box.read<List>(AppConstants.keyEmiAccounts);
    if (raw == null) return [];
    return raw
        .map((item) => EmiAccount.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveEmiAccounts(List<EmiAccount> accounts) async {
    await _box.write(
      AppConstants.keyEmiAccounts,
      accounts.map((e) => e.toJson()).toList(),
    );
  }

  // --- Installments ---
  List<EmiInstallment> getInstallments() {
    final raw = _box.read<List>(AppConstants.keyInstallments);
    if (raw == null) return [];
    return raw
        .map((item) => EmiInstallment.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveInstallments(List<EmiInstallment> installments) async {
    await _box.write(
      AppConstants.keyInstallments,
      installments.map((e) => e.toJson()).toList(),
    );
  }

  // --- Payments ---
  List<PaymentModel> getPayments() {
    final raw = _box.read<List>(AppConstants.keyPayments);
    if (raw == null) return [];
    return raw
        .map((item) => PaymentModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> savePayments(List<PaymentModel> payments) async {
    await _box.write(
      AppConstants.keyPayments,
      payments.map((e) => e.toJson()).toList(),
    );
  }

  // --- Reminders ---
  List<ReminderModel> getReminders() {
    final raw = _box.read<List>(AppConstants.keyReminders);
    if (raw == null) return [];
    return raw
        .map((item) => ReminderModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveReminders(List<ReminderModel> reminders) async {
    await _box.write(
      AppConstants.keyReminders,
      reminders.map((e) => e.toJson()).toList(),
    );
  }

  // --- Chit Funds ---
  List<ChitFund> getChitFunds() {
    final raw = _box.read<List>(AppConstants.keyChitFunds);
    if (raw == null) return [];
    return raw
        .map((item) => ChitFund.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveChitFunds(List<ChitFund> funds) async {
    await _box.write(
      AppConstants.keyChitFunds,
      funds.map((e) => e.toJson()).toList(),
    );
  }

  // --- Chit Payments ---
  List<ChitPayment> getChitPayments() {
    final raw = _box.read<List>(AppConstants.keyChitPayments);
    if (raw == null) return [];
    return raw
        .map((item) => ChitPayment.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveChitPayments(List<ChitPayment> payments) async {
    await _box.write(
      AppConstants.keyChitPayments,
      payments.map((e) => e.toJson()).toList(),
    );
  }

  // --- Settings ---
  Map<String, String> getSettings() {
    final raw = _box.read(AppConstants.keySettings);
    if (raw == null) {
      return {
        'upiId': AppConstants.defaultUpiId,
        'payeeName': AppConstants.defaultPayeeName,
      };
    }
    return {
      'upiId': raw['upiId'] ?? AppConstants.defaultUpiId,
      'payeeName': raw['payeeName'] ?? AppConstants.defaultPayeeName,
    };
  }

  Future<void> saveSettings({required String upiId, required String payeeName}) async {
    await _box.write(AppConstants.keySettings, {
      'upiId': upiId,
      'payeeName': payeeName,
    });
  }

  // Dynamically recompute status for non-paid installments
  void refreshInstallmentStatuses() {
    final installments = getInstallments();
    bool modified = false;

    for (var inst in installments) {
      if (!inst.isPaid) {
        final currentComputed = EmiHelper.computeInstallmentStatus(inst);
        if (inst.status != currentComputed) {
          inst.status = currentComputed;
          modified = true;
        }
      }
    }

    if (modified) {
      saveInstallments(installments);
    }
  }

  // Migrate any previous gold/jewelry schemes to furniture & electronics schemes
  Future<void> _migrateChitFundsAndUsers() async {
    final funds = getChitFunds();
    bool fundsUpdated = false;

    for (int i = 0; i < funds.length; i++) {
      final f = funds[i];
      if (f.category.toLowerCase().contains('gold') || f.schemeName.toLowerCase().contains('gold')) {
        funds[i] = ChitFund(
          id: f.id,
          schemeName: 'Diwali Mega Electronics Chit 2026',
          category: 'Electronics & Appliances',
          totalValue: f.totalValue,
          monthlyContribution: f.monthlyContribution,
          durationMonths: f.durationMonths,
          maxMembers: f.maxMembers,
          bonusAmount: f.bonusAmount,
          bonusDescription: 'Free 3-Burner Glass Top Gas Stove & Mixer Grinder Combo on Completion',
          startDate: f.startDate,
          status: f.status,
          createdAt: f.createdAt,
          members: f.members,
          notes: f.notes,
        );
        fundsUpdated = true;
      }
      if (f.category.toLowerCase().contains('cash') && f.schemeName.contains('Mega Savings')) {
        funds[i] = ChitFund(
          id: f.id,
          schemeName: 'Vengai Premium Home Furniture Chit',
          category: 'Home Furniture',
          totalValue: f.totalValue,
          monthlyContribution: f.monthlyContribution,
          durationMonths: f.durationMonths,
          maxMembers: f.maxMembers,
          bonusAmount: f.bonusAmount,
          bonusDescription: 'Free Solid Teakwood Center Table on Scheme Completion',
          startDate: f.startDate,
          status: f.status,
          createdAt: f.createdAt,
          members: f.members,
          notes: f.notes,
        );
        fundsUpdated = true;
      }
    }

    if (fundsUpdated) {
      await saveChitFunds(funds);
    }

    // Ensure Anitha (pure chit fund user) exists in users
    final users = getUsers();
    if (!users.any((u) => u.username.toLowerCase() == 'anitha')) {
      users.add(UserModel(
        id: 'usr_cust_6',
        username: 'anitha',
        password: '123',
        name: 'Anitha Selvam',
        mobile: '9840123999',
        role: 'CUSTOMER',
        customerId: 'CUST-1006',
        isActive: true,
      ));
      await saveUsers(users);
    }
  }
}
