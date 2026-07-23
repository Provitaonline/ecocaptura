import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ecocaptura'**
  String get appTitle;

  /// No description provided for @drawerHeader.
  ///
  /// In en, this message translates to:
  /// **'ecocaptura Settings'**
  String get drawerHeader;

  /// No description provided for @drawerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Device Configuration Options'**
  String get drawerSubtitle;

  /// No description provided for @menuPairDevice.
  ///
  /// In en, this message translates to:
  /// **'Pair Device to Site'**
  String get menuPairDevice;

  /// No description provided for @menuPairSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code (coming soon)'**
  String get menuPairSubtitle;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get menuLanguage;

  /// No description provided for @menuLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English / Español'**
  String get menuLanguageSubtitle;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get menuAbout;

  /// No description provided for @btnNewCapture.
  ///
  /// In en, this message translates to:
  /// **'New Capture'**
  String get btnNewCapture;

  /// No description provided for @recentCaptures.
  ///
  /// In en, this message translates to:
  /// **'Recent Captures'**
  String get recentCaptures;

  /// No description provided for @noCaptures.
  ///
  /// In en, this message translates to:
  /// **'No captures yet.'**
  String get noCaptures;

  /// No description provided for @unnamedCapture.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Capture'**
  String get unnamedCapture;

  /// No description provided for @newCapture.
  ///
  /// In en, this message translates to:
  /// **'New Capture'**
  String get newCapture;

  /// No description provided for @editCapture.
  ///
  /// In en, this message translates to:
  /// **'Edit Capture'**
  String get editCapture;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @captureDetails.
  ///
  /// In en, this message translates to:
  /// **'Capture Details'**
  String get captureDetails;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter capture description'**
  String get descriptionHint;

  /// No description provided for @saveCapture.
  ///
  /// In en, this message translates to:
  /// **'Save capture'**
  String get saveCapture;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @abortCapture.
  ///
  /// In en, this message translates to:
  /// **'Abort capture'**
  String get abortCapture;

  /// No description provided for @dataQuality.
  ///
  /// In en, this message translates to:
  /// **'Rate data quality'**
  String get dataQuality;

  /// No description provided for @qualityReason.
  ///
  /// In en, this message translates to:
  /// **'Select a reason'**
  String get qualityReason;

  /// No description provided for @cardinalDirections.
  ///
  /// In en, this message translates to:
  /// **'N,NNE,NE,ENE,E,ESE,SE,SSE,S,SSW,SW,WSW,W,WNW,NW,NNW'**
  String get cardinalDirections;

  /// No description provided for @tilt.
  ///
  /// In en, this message translates to:
  /// **'Tilt'**
  String get tilt;

  /// No description provided for @deletePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhotoTitle;

  /// No description provided for @deletePhotoMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get deletePhotoMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @reasonPoorGps.
  ///
  /// In en, this message translates to:
  /// **'Poor GPS'**
  String get reasonPoorGps;

  /// No description provided for @reasonBlurry.
  ///
  /// In en, this message translates to:
  /// **'Blurry'**
  String get reasonBlurry;

  /// No description provided for @reasonObstructed.
  ///
  /// In en, this message translates to:
  /// **'Obstructed'**
  String get reasonObstructed;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to leave?'**
  String get discardChangesMessage;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @captureInfo.
  ///
  /// In en, this message translates to:
  /// **'Capture info'**
  String get captureInfo;

  /// No description provided for @captureDeleted.
  ///
  /// In en, this message translates to:
  /// **'Capture deleted'**
  String get captureDeleted;

  /// No description provided for @exportCaptureMessage.
  ///
  /// In en, this message translates to:
  /// **'Export of Capture {captureId} containing {count, plural, =1 {1 photo} other {{count} photos}}.'**
  String exportCaptureMessage(String captureId, int count);

  /// No description provided for @aboutAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutAppVersion(String version);

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'EcoCaptura is a field data collection tool to capture photographic evidence for ecosystem analysis.'**
  String get aboutDescription;

  /// No description provided for @aboutContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact our support team:'**
  String get aboutContactLabel;

  /// No description provided for @photosCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No photos} =1{1 photo} other{{count} photos}}'**
  String photosCount(int count);

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync Captures'**
  String get sync;

  /// No description provided for @connectToSync.
  ///
  /// In en, this message translates to:
  /// **'Connect to Wi-Fi to Sync'**
  String get connectToSync;

  /// No description provided for @retain.
  ///
  /// In en, this message translates to:
  /// **'Retain'**
  String get retain;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register...'**
  String get register;

  /// No description provided for @chooseUsername.
  ///
  /// In en, this message translates to:
  /// **'Choose a unique username to continue'**
  String get chooseUsername;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'3-20 letters, numbers, and -, +, \$, @'**
  String get usernameFormatLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
