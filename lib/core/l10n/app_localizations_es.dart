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
  String get menuPairSubtitle => 'Escanear código QR (viene pronto)';

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
  String get dataQuality => 'Calificar calidad del dato';

  @override
  String get qualityReason => 'Seleccionar razón';

  @override
  String get cardinalDirections =>
      'N,NNE,NE,ENE,E,ESE,SE,SSE,S,SSO,SO,OSO,O,ONO,NO,NNO';

  @override
  String get tilt => 'Inclinación';

  @override
  String get deletePhotoTitle => 'Borrar Photo';

  @override
  String get deletePhotoMessage => '¿Seguro?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Borrar';

  @override
  String get reasonPoorGps => 'Mala señal de GPS';

  @override
  String get reasonBlurry => 'Borroso';

  @override
  String get reasonObstructed => 'Obstrucción';

  @override
  String get reasonOther => 'Otra';

  @override
  String get discardChangesTitle => '¿Descartar cambios?';

  @override
  String get discardChangesMessage => 'Se han hecho cambios. ¿Descartar?';

  @override
  String get keepEditing => 'Continuar';

  @override
  String get discard => 'Descartar';

  @override
  String get captureInfo => 'Información sobre la captura';

  @override
  String get captureDeleted => 'Captura borrada';

  @override
  String exportCaptureMessage(int captureId, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
    );
    return 'Exportación de la captura $captureId que contiene $_temp0.';
  }

  @override
  String aboutAppVersion(Object version) {
    return 'Versión $version';
  }

  @override
  String get aboutDescription =>
      'EcoCaptura es una herramienta de recolección de evidencia fotográfica para el análisis de ecosistemas.';

  @override
  String get aboutContactLabel => 'Contacta a nuestro equipo de soporte:';

  @override
  String photosCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
      zero: 'No hay fotos',
    );
    return '$_temp0';
  }
}
