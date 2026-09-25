import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/assests.dart';
import '../models/user_model.dart';
import '../models/emi_account_model.dart';
import '../models/emi_installment_model.dart';
import '../models/payment_model.dart';
import '../models/reminder_model.dart';
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

    await saveUsers(users);
    await saveEmiAccounts(accounts);
    await saveInstallments(installments);
    await savePayments(payments);
    await saveReminders(reminders);

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
}
