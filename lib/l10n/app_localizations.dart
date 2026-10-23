import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemLanguage;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'SCIENCE'**
  String get science;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'TECHNOLOGY'**
  String get technology;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'FINANCE'**
  String get finance;

  /// No description provided for @skyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why is the sky blue?'**
  String get skyTitle;

  /// No description provided for @skyDescription.
  ///
  /// In en, this message translates to:
  /// **'Sunlight contains many colors. Air molecules scatter blue light more strongly than red light.'**
  String get skyDescription;

  /// No description provided for @apiTitle.
  ///
  /// In en, this message translates to:
  /// **'What is an API?'**
  String get apiTitle;

  /// No description provided for @apiDescription.
  ///
  /// In en, this message translates to:
  /// **'An API allows different software applications to communicate and exchange information.'**
  String get apiDescription;

  /// No description provided for @interestTitle.
  ///
  /// In en, this message translates to:
  /// **'What is compound interest?'**
  String get interestTitle;

  /// No description provided for @interestDescription.
  ///
  /// In en, this message translates to:
  /// **'Compound interest lets you earn returns on both your original money and previous returns.'**
  String get interestDescription;

  /// No description provided for @testKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Test Your Knowledge'**
  String get testKnowledge;

  /// No description provided for @quizComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Quiz coming soon!'**
  String get quizComingSoon;

  /// No description provided for @swipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to learn more ↑'**
  String get swipeHint;

  /// No description provided for @quizSkyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which color is scattered most strongly by air molecules?'**
  String get quizSkyQuestion;

  /// No description provided for @quizSkyRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get quizSkyRed;

  /// No description provided for @quizSkyBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get quizSkyBlue;

  /// No description provided for @quizSkyGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get quizSkyGreen;

  /// No description provided for @quizApiQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is the main purpose of an API?'**
  String get quizApiQuestion;

  /// No description provided for @quizApiExchange.
  ///
  /// In en, this message translates to:
  /// **'Allow applications to exchange data'**
  String get quizApiExchange;

  /// No description provided for @quizApiBattery.
  ///
  /// In en, this message translates to:
  /// **'Charge a device battery'**
  String get quizApiBattery;

  /// No description provided for @quizApiBrightness.
  ///
  /// In en, this message translates to:
  /// **'Increase screen brightness'**
  String get quizApiBrightness;

  /// No description provided for @quizInterestQuestion.
  ///
  /// In en, this message translates to:
  /// **'What does compound interest include?'**
  String get quizInterestQuestion;

  /// No description provided for @quizInterestPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Only the original principal'**
  String get quizInterestPrincipal;

  /// No description provided for @quizInterestDeposits.
  ///
  /// In en, this message translates to:
  /// **'Only new deposits'**
  String get quizInterestDeposits;

  /// No description provided for @quizInterestPrevious.
  ///
  /// In en, this message translates to:
  /// **'Interest earned on previous interest'**
  String get quizInterestPrevious;

  /// No description provided for @quizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get quizCorrect;

  /// No description provided for @quizWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Correct answer:'**
  String get quizWrong;

  /// No description provided for @backToFeed.
  ///
  /// In en, this message translates to:
  /// **'Back to feed'**
  String get backToFeed;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
