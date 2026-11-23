import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import 'package:casa_pointage/app/data/api/api_exception.dart';
import 'package:casa_pointage/app/services/auth_service.dart';

enum LoginError { both, id, password, invalid, server }

@injectable
class LoginController extends GetxController {
  LoginController(this.authService)
      : idController = TextEditingController(),
        passwordController = TextEditingController();

  final AuthService authService;

  final TextEditingController idController;
  final TextEditingController passwordController;

  final obscurePassword = true.obs;
  final loading = false.obs;
  final error = Rxn<LoginError>();

  /// Text sent by the server, shown for [LoginError.server].
  final serverMessage = ''.obs;

  void togglePasswordVisibility() => obscurePassword.toggle();

  Future<void> submit() async {
    if (loading.value) return;

    final login = idController.text.trim();
    final password = passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      error.value = login.isEmpty && password.isEmpty
          ? LoginError.both
          : login.isEmpty
              ? LoginError.id
              : LoginError.password;
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    error.value = null;
    loading.value = true;
    try {
      final supervisor = await authService.login(login, password);
      if (supervisor == null) {
        error.value = LoginError.invalid;
        return;
      }
      Get.offAllNamed(authService.homeRoute, arguments: supervisor);
    } on ApiException catch (e) {
      serverMessage.value = e.message;
      error.value = LoginError.server;
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    idController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
