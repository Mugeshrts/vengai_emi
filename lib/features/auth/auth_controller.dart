import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/user_model.dart';
import '../../core/service/storage_service.dart';

class AuthController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSession();
  }

  void loadSession() {
    currentUser.value = _storageService.getSessionUser();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void fillDemoAdmin() {
    usernameController.text = 'admin';
    passwordController.text = 'admin123';
    errorMessage.value = '';
  }

  void fillDemoCustomer(String username) {
    usernameController.text = username;
    passwordController.text = '123456';
    errorMessage.value = '';
  }

  Future<bool> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      errorMessage.value = 'Please enter your username.';
      return false;
    }

    if (password.isEmpty) {
      errorMessage.value = 'Please enter your password.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    // Artificial tiny pause for smooth UX feedback
    await Future.delayed(const Duration(milliseconds: 250));

    final users = _storageService.getUsers();
    final user = users.firstWhereOrNull(
      (u) =>
          u.username.toLowerCase() == username.toLowerCase() &&
          u.password == password,
    );

    isLoading.value = false;

    if (user != null) {
      if (!user.isActive) {
        errorMessage.value = 'This account is deactivated. Please contact admin.';
        return false;
      }

      currentUser.value = user;
      await _storageService.saveSessionUser(user);

      usernameController.clear();
      passwordController.clear();

      if (user.isAdmin) {
        Get.offAllNamed('/admin');
      } else {
        Get.offAllNamed('/customer');
      }
      return true;
    } else {
      errorMessage.value = 'Invalid username or password.';
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearSession();
    currentUser.value = null;
    usernameController.clear();
    passwordController.clear();
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
