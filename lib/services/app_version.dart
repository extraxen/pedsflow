// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

class AvailableAppVersion {
  final String version;
  final int buildNumber;

  const AvailableAppVersion({
    required this.version,
    required this.buildNumber,
  });

  factory AvailableAppVersion.fromJson(Map<String, dynamic> json) {
    final String version = '${json['version'] ?? ''}'.trim();
    final int? buildNumber = switch (json['build_number']) {
      int value => value,
      String value => int.tryParse(value),
      _ => null,
    };

    if (version.isEmpty || buildNumber == null || buildNumber < 1) {
      throw const FormatException('Invalid PedsFlow version response.');
    }

    return AvailableAppVersion(
      version: version,
      buildNumber: buildNumber,
    );
  }

  bool isNewerThan(int currentBuildNumber) =>
      buildNumber > currentBuildNumber;
}
