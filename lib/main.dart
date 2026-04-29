import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'firebase_options.dart';

// THEME
import 'package:read_unlock_app/core/theme/theme_manager.dart';

// CORE
import 'package:read_unlock_app/core/utils/app_state.dart';

// FEATURES
import 'package:read_unlock_app/features/admin/screens/admin_uploader_screen.dart';
import 'package:read_unlock_app/features/auth/screens/login_switcher_screen.dart';
import 'package:read_unlock_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:read_unlock_app/features/system/screens/force_update_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initApp();

  runApp(const MyApp());
}

// ================================
// 🔧 INIT LAYER (clean separation)
// ================================
Future<void> _initApp() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase Connected ✅");
  } catch (e) {
    debugPrint("Firebase Error ❌ $e");
  }

  await AppState.load();
}

// ================================
// 🎯 APP ROOT
// ================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ThemeManager _themeManager = ThemeManager();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeManager,
      builder: (_, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Unlock',

          // ✅ ENTERPRISE THEME
          theme: _themeManager.theme,

          home: const AppRootGate(),
        );
      },
    );
  }
}

// ==========================================
// 🛡️ ROOT GATE (Version + Auth)
// ==========================================
class AppRootGate extends StatefulWidget {
  const AppRootGate({super.key});

  @override
  State<AppRootGate> createState() => _AppRootGateState();
}

class _AppRootGateState extends State<AppRootGate> {
  static const bool _forceAdminMode = false;

  // ================================
  // 🔍 VERSION CHECK
  // ================================
  Future<bool> _requiresForceUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 1;

      final configSnap = await FirebaseFirestore.instance
          .collection('config')
          .doc('app_settings')
          .get();

      if (configSnap.exists && configSnap.data() != null) {
        final minVersion = configSnap.get('min_version_code') ?? 1;

        return currentBuild < minVersion;
      }
    } catch (e) {
      debugPrint("Version Check Error: $e");
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // 👑 ADMIN OVERRIDE
    if (_forceAdminMode) {
      return const AdminBookUploader();
    }

    return FutureBuilder<bool>(
      future: _requiresForceUpdate(),
      builder: (context, versionSnap) {
        // ⏳ LOADING VERSION
        if (versionSnap.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // 🚨 FORCE UPDATE
        if (versionSnap.data == true) {
          return const ForceUpdateScreen();
        }

        // 🔐 AUTH CHECK
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnap) {
            if (authSnap.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (authSnap.hasData) {
              return const DashboardScreen();
            }

            return const LoginSwitcherScreen();
          },
        );
      },
    );
  }
}

// ================================
// 🔄 REUSABLE LOADING SCREEN
// ================================
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
