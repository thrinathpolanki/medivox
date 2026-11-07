class TtsLanguageMapper {
  /// Maps the 23 app language codes to BCP-47 codes required by Android TTS.
  static String getTtsCode(String appLanguageCode) {
    switch (appLanguageCode) {
      case 'en':
        return 'en-IN';
      case 'hi':
        return 'hi-IN';
      case 'bn':
        return 'bn-IN';
      case 'te':
        return 'te-IN';
      case 'mr':
        return 'mr-IN';
      case 'ta':
        return 'ta-IN';
      case 'ur':
        return 'ur-IN';
      case 'gu':
        return 'gu-IN';
      case 'kn':
        return 'kn-IN';
      case 'or':
        return 'or-IN';
      case 'ml':
        return 'ml-IN';
      case 'pa':
        return 'pa-IN';
      case 'as':
        return 'as-IN';
      case 'sa':
        return 'sa-IN';
      case 'kok':
        return 'kok-IN';
      case 'mai':
        return 'mai-IN';
      case 'ne':
        return 'ne-IN';
      case 'sd':
        return 'sd-IN';
      case 'doi':
        return 'doi-IN';
      case 'brx':
        return 'brx-IN';
      case 'mni':
        return 'mni-IN';
      case 'sat':
        return 'sat-IN';
      case 'ks':
        return 'ks-IN';
      default:
        return 'en-IN';
    }
  }

  static String getLanguageName(String appLanguageCode) {
    switch (appLanguageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      case 'te':
        return 'Telugu';
      // Add the rest as needed
      default:
        return 'English';
    }
  }
}
