class VersionHelper {
  /// Compares two version strings (e.g. "3.5.0", "3.10.1", "4.0").
  /// Returns:
  /// - Negative value (-1) if v1 < v2
  /// - Zero (0) if v1 == v2
  /// - Positive value (1) if v1 > v2
  static int compare(dynamic v1, dynamic v2) {
    if (v1 == null && v2 == null) return 0;
    if (v1 == null) return -1;
    if (v2 == null) return 1;

    String clean1 = _cleanVersion(v1.toString());
    String clean2 = _cleanVersion(v2.toString());

    List<int> parts1 = clean1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> parts2 = clean2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    int maxLength = parts1.length > parts2.length ? parts1.length : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      int p1 = i < parts1.length ? parts1[i] : 0;
      int p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }

    return 0;
  }

  /// Returns true if [currentVersion] is strictly less than [targetVersion] (meaning an update is needed).
  static bool isVersionLower(dynamic currentVersion, dynamic targetVersion) {
    if (targetVersion == null) return false;
    return compare(currentVersion, targetVersion) < 0;
  }

  /// Returns true if [currentVersion] is greater than or equal to [targetVersion].
  static bool isVersionGreaterOrEqual(dynamic currentVersion, dynamic targetVersion) {
    if (targetVersion == null) return true;
    return compare(currentVersion, targetVersion) >= 0;
  }

  static String _cleanVersion(String version) {
    // Remove build number (+...) and metadata (-...)
    String clean = version.trim();
    if (clean.contains('+')) {
      clean = clean.split('+').first;
    }
    if (clean.contains('-')) {
      clean = clean.split('-').first;
    }
    return clean;
  }
}
