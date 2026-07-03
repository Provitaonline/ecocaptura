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
  String get btnNewCapture => 'Nueva Captura';

  @override
  String get recentCaptures => 'Capturas Recientes';

  @override
  String get noCaptures => 'No hay capturas aún.';

  @override
  String get unnamedCapture => 'Captura sin nombre';

  @override
  String get newCapture => 'Nueva Captura';

  @override
  String get editCapture => 'Editar Captura';

  @override
  String get photos => 'Fotos';

  @override
  String get captureDetails => 'Detalles de captura';

  @override
  String get description => 'Descripción';

  @override
  String get descriptionHint => 'Describe esta captura';

  @override
  String get saveCapture => 'Guardar captura';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get abortCapture => 'Abandonar captura';

  @override
  String get cardinalDirections =>
      'N,NNE,NE,ENE,E,ESE,SE,SSE,S,SSO,SO,OSO,O,ONO,NO,NNO';

  @override
  String get tilt => 'Inclinación';
}
