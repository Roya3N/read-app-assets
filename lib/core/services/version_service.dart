import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static Future<bool> requiresForceUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 1;

      final snap = await FirebaseFirestore.instance
          .collection('config')
          .doc('app_settings')
          .get();

      if (snap.exists && snap.data() != null) {
        final minVersion = snap.get('min_version_code') ?? 1;
        return currentBuild < minVersion;
      }
    } catch (e) {
      // عمداً silent fail (برای UX بهتر)
    }

    return false;
  }
}
