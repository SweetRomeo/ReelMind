// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get language => 'Dil';

  @override
  String get systemLanguage => 'Sistem dili';

  @override
  String get science => 'BİLİM';

  @override
  String get technology => 'TEKNOLOJİ';

  @override
  String get finance => 'FİNANS';

  @override
  String get skyTitle => 'Gökyüzü neden mavidir?';

  @override
  String get skyDescription =>
      'Güneş ışığı farklı renklerden oluşur. Havadaki moleküller mavi ışığı kırmızı ışığa göre daha güçlü saçar.';

  @override
  String get apiTitle => 'API nedir?';

  @override
  String get apiDescription =>
      'API, farklı yazılım uygulamalarının birbiriyle iletişim kurmasını ve bilgi alışverişinde bulunmasını sağlar.';

  @override
  String get interestTitle => 'Bileşik faiz nedir?';

  @override
  String get interestDescription =>
      'Bileşik faiz, hem başlangıçtaki paranız üzerinden hem de önceki dönemlerde kazanılan faizler üzerinden faiz elde edilmesini sağlar.';

  @override
  String get testKnowledge => 'Bilgini Test Et';

  @override
  String get quizComingSoon => 'Quiz özelliği yakında!';

  @override
  String get swipeHint => 'Yeni bilgiler için yukarı kaydır ↑';
}
