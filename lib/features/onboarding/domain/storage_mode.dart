enum StorageMode {
  none,
  local,
  google;

  static StorageMode fromName(String? name) => StorageMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => StorageMode.none,
      );

  String get label => switch (this) {
        StorageMode.none => 'Not selected',
        StorageMode.local => 'Local Storage',
        StorageMode.google => 'Google account',
      };
}
