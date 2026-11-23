import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/data/api/api_client.dart';
import 'app/services/auth_service.dart';
import 'core/di/injection.dart';
import 'app/routes/app_pages.dart';
import 'core/localization/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/responsive_shell.dart';
import 'generated/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Month and day names for the French and Arabic headers.
  await initializeDateFormatting();

  final locale = Get.put(LocaleController(), permanent: true);

  await configureDependencies(Environment.prod);
  // Tokens refused and not renewable: back to the login screen.
  getIt<ApiClient>().sessionExpired.listen((_) async {
    await getIt<AuthService>().logout();
    Get.offAllNamed(Routes.LOGIN);
  });

  runApp(
    GetMaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      locale: locale.locale.value,
      fallbackLocale: LocaleController.fr,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => ResponsiveShell(child: child),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
