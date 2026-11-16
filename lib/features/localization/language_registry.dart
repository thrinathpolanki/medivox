enum Capability { available, unverified, unavailable }

class LanguageInfo {
  const LanguageInfo(
    this.code,
    this.englishName,
    this.nativeName, {
    this.rtl = false,
    this.ui = Capability.unavailable,
  });
  final String code;
  final String englishName;
  final String nativeName;
  final bool rtl;

  /// Only UI translation status is tracked in M1. Font/OCR/TTS/speech/offline
  /// capabilities start as "unverified" and are filled in only after device
  /// testing (Milestone 4). Do NOT mark anything available without testing.
  final Capability ui;
  Capability get font => Capability.unverified;
  Capability get ocr => Capability.unverified;
  Capability get tts => Capability.unverified;
  Capability get speechRecognition => Capability.unverified;
  Capability get offline => Capability.unverified;
}

const supportedLanguages = <LanguageInfo>[
  LanguageInfo('en', 'English', 'English', ui: Capability.available),
  LanguageInfo('as', 'Assamese', 'অসমীয়া'),
  LanguageInfo('bn', 'Bengali', 'বাংলা'),
  LanguageInfo('brx', 'Bodo', 'बड़ो'),
  LanguageInfo('doi', 'Dogri', 'डोगरी'),
  LanguageInfo('gu', 'Gujarati', 'ગુજરાતી'),
  LanguageInfo('hi', 'Hindi', 'हिन्दी'),
  LanguageInfo('kn', 'Kannada', 'ಕನ್ನಡ'),
  LanguageInfo('ks', 'Kashmiri', 'کٲشُر', rtl: true),
  LanguageInfo('kok', 'Konkani', 'कोंकणी'),
  LanguageInfo('mai', 'Maithili', 'मैथिली'),
  LanguageInfo('ml', 'Malayalam', 'മലയാളം'),
  LanguageInfo('mni', 'Manipuri (Meitei)', 'ꯃꯤꯇꯩꯂꯣꯟ'),
  LanguageInfo('mr', 'Marathi', 'मराठी'),
  LanguageInfo('ne', 'Nepali', 'नेपाली'),
  LanguageInfo('or', 'Odia', 'ଓଡ଼ିଆ'),
  LanguageInfo('pa', 'Punjabi', 'ਪੰਜਾਬੀ'),
  LanguageInfo('sa', 'Sanskrit', 'संस्कृतम्'),
  LanguageInfo('sat', 'Santali', 'ᱥᱟᱱᱛᱟᱲᱤ'),
  LanguageInfo('sd', 'Sindhi', 'سنڌي', rtl: true),
  LanguageInfo('ta', 'Tamil', 'தமிழ்'),
  LanguageInfo('te', 'Telugu', 'తెలుగు'),
  LanguageInfo('ur', 'Urdu', 'اردو', rtl: true),
];

LanguageInfo? languageByCode(String? code) {
  for (final l in supportedLanguages) {
    if (l.code == code) return l;
  }
  return null;
}
