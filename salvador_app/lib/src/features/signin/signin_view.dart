import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:salvador_task_management/src/config/navigation/navigation_service.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:salvador_task_management/src/features/main_view/main_view.dart';
import 'package:salvador_task_management/src/features/menu/user_menu_controller.dart';
import 'package:salvador_task_management/src/repository/user_api_repository.dart';

class SignInView extends ConsumerWidget {
  SignInView({super.key});

  static const routeName = '/signin';
  final secureStorage = const FlutterSecureStorage();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  Duration get loginTime => const Duration(milliseconds: 1000);

  Future<String?> _onLogin(LoginData data, WidgetRef ref) async {
    final userRepository = ref.read(userApiRepositoryProvider);

    try {
      final loginResponse = await userRepository.login(data.name, data.password);
      if (loginResponse != null) {
        // Salva la password in modo sicuro
        await secureStorage.write(key: 'password', value: data.password);
        await secureStorage.write(key: 'username', value: data.name);

        final prefs = ref.read(sharedPreferencesProvider).asData!.value;
        await prefs.setString("user", data.name);

        final userMenuController = ref.read(userMenuControllerProvider.notifier);
        userMenuController.loadUserMenu();

        ref.read(navigationServiceProvider).routeTo(MainView.routeName, arguments: data.name);
        return null;
      } else {
        return 'Invalid username or password';
      }
    } catch (e) {
      return 'An error occurred during login';
    }
  }

  Future<void> _retrievePassword() async {
    final password = await secureStorage.read(key: 'password') ?? '';
    final username = await secureStorage.read(key: 'username') ?? '';
    passwordController.text = password; // Imposta la password nel controller
    usernameController.text = username; // Imposta la password nel controller; // Imposta la password nel controller
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return FutureBuilder<void>(
      future: _retrievePassword(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FlutterLogin(
            logo: const AssetImage('assets/images/logo_icoldo.png'),
            onLogin: (loginData) async => await _onLogin(loginData, ref),
            onSignup: (data) => Future.value(null),
            onSubmitAnimationCompleted: () {
              ref.read(navigationServiceProvider).routeTo(MainView.routeName);
            },
            onRecoverPassword: (name) => Future.value('Please contact support to recover your password'),
            userValidator: (user) => null,
            savedEmail: usernameController.text,
            savedPassword: passwordController.text, // Usa la password dal controller
            userType: LoginUserType.name,
            theme: LoginTheme(
              primaryColor: const Color.fromARGB(255, 228, 186, 124),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
