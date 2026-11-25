enum VoiceIntent {
  scanMedicine,
  readPackaging,
  readMedicines,
  todayDoses,
  showReminders,
  missedDoses,
  openReports,
  openSettings,
  goHome,
  help,
  unknown,
}

/// Rule-based command matcher. English only for now: speech is recognised with
/// an English locale and the words below are English.
class VoiceIntentParser {
  static VoiceIntent parse(String raw) {
    final t = raw.toLowerCase();
    bool has(String w) => t.contains(w);
    bool any(List<String> ws) => ws.any(has);

    if (any(['help', 'what can you do', 'commands'])) return VoiceIntent.help;
    if (has('read') && any(['packag', 'label', 'box', 'strip'])) return VoiceIntent.readPackaging;
    if (has('scan') || has('identify') || (has('what medicine') && any(['this', 'that']))) {
      return VoiceIntent.scanMedicine;
    }
    if (any(['missed', 'forgot', 'forgotten'])) return VoiceIntent.missedDoses;
    if (has('today') || any(['what should i take', 'what do i take', 'next dose', 'schedule'])) {
      return VoiceIntent.todayDoses;
    }
    if (has('remind')) return VoiceIntent.showReminders;
    if (any(['report', 'adherence', 'history'])) return VoiceIntent.openReports;
    if (any(['setting', 'preferences'])) return VoiceIntent.openSettings;
    if (has('read') && has('medicine') || any(['my medicines', 'list medicines', 'what medicines do i'])) {
      return VoiceIntent.readMedicines;
    }
    if (any(['home', 'main screen', 'dashboard'])) return VoiceIntent.goHome;
    return VoiceIntent.unknown;
  }

  /// Spoken yes/no for confirmations.
  static bool? yesNo(String? raw) {
    if (raw == null) return null;
    final t = raw.toLowerCase();
    if (RegExp(r'\b(yes|yeah|yep|correct|confirm|sure|ok|okay)\b').hasMatch(t)) return true;
    if (RegExp(r'\b(no|nope|cancel|stop|wrong)\b').hasMatch(t)) return false;
    return null;
  }

  /// Taken / snooze / skip for the reminder screen.
  static String? doseAction(String? raw) {
    if (raw == null) return null;
    final t = raw.toLowerCase();
    if (RegExp(r'\b(taken|took|take it|i took)\b').hasMatch(t)) return 'taken';
    if (RegExp(r'\b(snooze|later|remind me)\b').hasMatch(t)) return 'snooze';
    if (RegExp(r'\b(skip|skipped|not taking)\b').hasMatch(t)) return 'skip';
    return null;
  }
}
