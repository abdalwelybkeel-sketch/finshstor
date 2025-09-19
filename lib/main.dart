import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/providers/app_providers.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'features/splash/presentation/pages/splash_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Stripe with a default test key (or skip if not needed)
  Stripe.publishableKey = 'pk_test_51xxxxxxxxxxxxxxxxxxxxxxxxxxxx'; // استخدم مفتاح اختبار Stripe أو اتركه فارغًا إذا لم تكن بحاجة إلى Stripe الآن

  // Initialize services
  await FirebaseService.initialize();
  await NotificationService.initialize();

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const RosesStoreApp());
}

class RosesStoreApp extends StatelessWidget {
  const RosesStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Roses Store',
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Localization
            locale: localeProvider.locale,
            supportedLocales: AppConfig.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Routes
            home: const SplashPage(),
            onGenerateRoute: AppConfig.generateRoute,
          );
        },
      ),
    );
  }
}