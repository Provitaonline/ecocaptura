// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ecocaptura';

  @override
  String get drawerHeader => 'Ajustes de ecocaptura';

  @override
  String get drawerSubtitle => 'Opciones de Configuración';

  @override
  String get menuPairDevice => 'Vincular Dispositivo al Sitio';

  @override
  String get menuPairSubtitle => 'Escanear token de autenticación QR';

  @override
  String get menuLanguage => 'Cambiar Idioma';

  @override
  String get menuLanguageSubtitle => 'English / Español';

  @override
  String get menuAbout => 'Acerca de la Aplicación';

  @override
  String get btnNewCaptura => 'Nueva Captura';

  @override
  String get recentCapturas => 'Capturas Recientes';

  @override
  String get noCapturas => 'No hay capturas aún.';

  @override
  String get unnamedCapture => 'Captura sin nombre';
}
