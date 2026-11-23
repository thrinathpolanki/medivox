enum Capability { available, unverified, unavailable }

/// Scripts the on-device OCR engine (Google ML Kit) can read.
enum OcrScript { latin, devanagari }

class LanguageInfo {
  const LanguageInfo(
    this.code,
    this.englishName,
    this.nativeName,
    this.bcp47, {
    this.rtl = false,
    this.ui = Capability.unavailable,
    this.ocrScript,
  });
  final String code;
  final String englishName;
  final String nativeName;

  /// Locale requested from the phone's text-to-speech engine. Whether a voice
  /// exists is checked on the device at run time, never assumed.
  final String bcp47;
  final bool rtl;
  final Capability ui;

  /// Non-Latin script ML Kit can read for this language (Latin is always read).
  final OcrScript? ocrScript;

  Capability get font => Capability.unverified;
  Capability get ocr => ocrScript != null || code == 'en' ? Capability.unverified : Capability.unavailable;
  Capability get tts => Capability.unverified;
  Capability get speechRecognition => Capability.unverified;
  Capability get offline => Capability.unverified;

  /// Scripts to run OCR with for this language. Latin is always included
  /// because medicine packaging is usually printed in English.
  Set<OcrScript> get ocrScripts => {OcrScript.latin, if (ocrScript != null) ocrScript!};
}

const supportedLanguages = <LanguageInfo>[
  LanguageInfo('en', 'English', 'English', 'en-IN', ui: Capability.available),
  LanguageInfo('as', 'Assamese', 'অসমীয়া', 'as-IN'),
  LanguageInfo('bn', 'Bengali', 'বাংলা', 'bn-IN'),
  LanguageInfo('brx', 'Bodo', 'बड़ो', 'brx-IN', ocrScript: OcrScript.devanagari),
  LanguageInfo('doi', 'Dogri', 'डोगरी', 'doi-IN', ocrScript: OcrScript.devanagari),
  LanguageInfo('gu', 'Gujarati', 'ગુજરાતી', 'gu-IN'),
  LanguageInfo('hi', 'Hindi', 'हिन्दी', 'hi-IN', ocrScript: OcrScript.devanagari),
  LanguageInfo('kn', 'Kannada', 'ಕನ್ನಡ', 'kn-IN'),
  LanguageInfo('ks', 'Kashmiri', 'کٲشُر', 'ks-IN', rtl: true),
  LanguageInfo('kok', 'Konkani', 'कोंकणी', 'kok-IN', ocrScript: OcrScript.devanagari),
  LanguageInfo('mai', 'Maithili', 'मैथिली', 'mai-IN', ocrScript: OcrScript.devanagari),
  LanguageInfo('ml', 'Malayalam', 'മലയാളം', 'ml-IN'),
  LanguageInfo('mni', 'Manipuri (Meitei)', 'ꯃꯤꯇꯩꯂꯣꯟ', 'mni-IN'),
  LanguageInfo('mr', 'Marathi', 'मराठी', 'mr-IN', ocrScript: OcrScript.devanagari),
  LanguageInfo('ne', 'Nepali', 'नेपाली', 'ne-IN', ocrScript: OcrScript.devanagari),
  LanguageInfo('or', 'Odia', 'ଓଡ଼ିଆ', 'or-IN'),
  LanguageInfo('pa', 'Punjabi', 'ਪੰਜਾਬੀ', 'pa-IN'),
  LanguageInfo('sa', 'Sanskrit', 'संस्कृतम्', 'sa-IN', ocrScript: OcrScript.devanagari),
  LanguageInfo('sat', 'Santali', 'ᱥᱟᱱᱛᱟᱲᱤ', 'sat-IN'),
  LanguageInfo('sd', 'Sindhi', 'سنڌي', 'sd-IN', rtl: true),
  LanguageInfo('ta', 'Tamil', 'தமிழ்', 'ta-IN'),
  LanguageInfo('te', 'Telugu', 'తెలుగు', 'te-IN'),
  LanguageInfo('ur', 'Urdu', 'اردو', 'ur-IN', rtl: true),
];

LanguageInfo? languageByCode(String? code) {
  for (final l in supportedLanguages) {
    if (l.code == code) return l;
  }
  return null;
}
