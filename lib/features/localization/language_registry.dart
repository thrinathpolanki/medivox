class LanguageCapability {
  final String code;
  final String nativeName;
  final String englishName;
  final bool uiTranslated;
  final bool ttsAvailable;
  final bool ocrAvailable;
  final bool speechRecognitionAvailable;
  final bool isRTL;

  const LanguageCapability({
    required this.code,
    required this.nativeName,
    required this.englishName,
    this.uiTranslated = false,
    this.ttsAvailable = false,
    this.ocrAvailable = false,
    this.speechRecognitionAvailable = false,
    this.isRTL = false,
  });
}

class LanguageRegistry {
  static const List<LanguageCapability> all = [
    LanguageCapability(
      code: 'en',
      nativeName: 'English',
      englishName: 'English',
      uiTranslated: true,
      ttsAvailable: true,
      ocrAvailable: true,
      speechRecognitionAvailable: true,
    ),
    LanguageCapability(
      code: 'hi',
      nativeName: 'हिन्दी',
      englishName: 'Hindi',
      uiTranslated: true,
      ttsAvailable: true,
      ocrAvailable: true,
      speechRecognitionAvailable: true,
    ),
    LanguageCapability(
      code: 'te',
      nativeName: 'తెలుగు',
      englishName: 'Telugu',
      uiTranslated: true,
      ttsAvailable: true,
      ocrAvailable: true,
    ),
    LanguageCapability(
      code: 'ta',
      nativeName: 'தமிழ்',
      englishName: 'Tamil',
      uiTranslated: true,
      ttsAvailable: true,
      ocrAvailable: true,
    ),
    LanguageCapability(
      code: 'kn',
      nativeName: 'ಕನ್ನಡ',
      englishName: 'Kannada',
      uiTranslated: true,
      ttsAvailable: true,
    ),
    LanguageCapability(
      code: 'ml',
      nativeName: 'മലയാളം',
      englishName: 'Malayalam',
      uiTranslated: true,
      ttsAvailable: true,
    ),
    LanguageCapability(
      code: 'gu',
      nativeName: 'ગુજરાતી',
      englishName: 'Gujarati',
      uiTranslated: true,
      ttsAvailable: true,
    ),
    LanguageCapability(
      code: 'pa',
      nativeName: 'ਪੰਜਾਬੀ',
      englishName: 'Punjabi',
      uiTranslated: true,
      ttsAvailable: true,
    ),
    LanguageCapability(
      code: 'bn',
      nativeName: 'বাংলা',
      englishName: 'Bengali',
      uiTranslated: true,
      ttsAvailable: true,
      ocrAvailable: true,
    ),
    LanguageCapability(
      code: 'mr',
      nativeName: 'मराठी',
      englishName: 'Marathi',
      uiTranslated: true,
      ttsAvailable: true,
    ),
    LanguageCapability(
      code: 'ur',
      nativeName: 'اردو',
      englishName: 'Urdu',
      uiTranslated: true,
      ttsAvailable: true,
      isRTL: true,
    ),
    LanguageCapability(
      code: 'or',
      nativeName: 'ଓଡ଼ିଆ',
      englishName: 'Odia',
      uiTranslated: true,
    ),
    LanguageCapability(
      code: 'as',
      nativeName: 'অসমীয়া',
      englishName: 'Assamese',
      uiTranslated: true,
    ),
    LanguageCapability(
      code: 'sa',
      nativeName: 'संस्कृतम्',
      englishName: 'Sanskrit',
    ),
    LanguageCapability(
      code: 'kok',
      nativeName: 'कोंकणी',
      englishName: 'Konkani',
    ),
    LanguageCapability(
      code: 'mai',
      nativeName: 'मैथिली',
      englishName: 'Maithili',
    ),
    LanguageCapability(code: 'ne', nativeName: 'नेपाली', englishName: 'Nepali'),
    LanguageCapability(
      code: 'sd',
      nativeName: 'سنڌي',
      englishName: 'Sindhi',
      isRTL: true,
    ),
    LanguageCapability(code: 'doi', nativeName: 'डोगरी', englishName: 'Dogri'),
    LanguageCapability(code: 'brx', nativeName: 'बड़ो', englishName: 'Bodo'),
    LanguageCapability(
      code: 'mni',
      nativeName: 'মৈতৈলোন্',
      englishName: 'Manipuri',
    ),
    LanguageCapability(
      code: 'sat',
      nativeName: 'ᱥᱟᱱᱛᱟᱲᱤ',
      englishName: 'Santali',
    ),
    LanguageCapability(
      code: 'ks',
      nativeName: 'کٲشُر',
      englishName: 'Kashmiri',
      isRTL: true,
    ),
  ];

  static LanguageCapability getByCode(String code) {
    return all.firstWhere((l) => l.code == code, orElse: () => all.first);
  }
}
