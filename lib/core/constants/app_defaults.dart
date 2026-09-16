class AppDefaults {
  static const String appName = 'IQ Navigator';
  static const String appTagline = 'Fee Submission';
  static const String gmailSuffix = '@gmail.com';
  static const String defaultPassword = '12345678';

  static const String studentLoginName = 'awabnoor';
  static const String schoolLoginName = 'school';

  static const String studentName = 'Awab Noor';
  static const String parentName = 'Sobia Saif';
  static const String parentRelation = 'Mother';
  static const String senderName = 'Zain Abid';
  static const String senderRelation = 'Father';
  static const String contact = '03205270594';
  static const String schoolName = 'IQ Navigator School';
}

class EmailHelper {
  static String fromName(String name) {
    final local = name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
    return '$local${AppDefaults.gmailSuffix}';
  }
}
