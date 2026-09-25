import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/constants/color.dart';
import 'core/service/storage_service.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/login_view.dart';
import 'features/splash/splash_view.dart';
import 'features/admin_dashboard/admin_main_screen.dart';
import 'features/user_dashboard/customer_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // STEP 2: Initialize GetStorage & Services
  await Get.putAsync(() => StorageService().init());
  Get.put(AuthController(), permanent: true);

  runApp(const VengaiEmiApp());
}

class VengaiEmiApp extends StatelessWidget {
  const VengaiEmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VENGAI MART',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0.5,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        fontFamily: null, // Default system font with crisp clarity
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashView(),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/admin',
          page: () => const AdminMainScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/customer',
          page: () => const CustomerMainScreen(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
