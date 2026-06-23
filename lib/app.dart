import 'package:flutter/material.dart';
import 'core/l10n/app_localizations.dart'; 
import 'core/l10n/locale_controller.dart'; // 1. Import the controller
import 'features/dashboard/presentation/dashboard_screen.dart';

class EcocapturaApp extends StatelessWidget {
  const EcocapturaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Listen to the language state changes dynamically
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.instance.localeNotifier,
      builder: (context, currentLocale, child) {
        return MaterialApp(
          title: 'ecocaptura',
          debugShowCheckedModeBanner: false,
          locale: currentLocale, // 3. Pass the active override locale down
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DashboardScreen(),
        );
      },
    );
  }
}