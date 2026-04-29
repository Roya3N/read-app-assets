import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
// حتماً آدرس آپلودر خودت را اینجا ایمپورت کن
// import 'package:your_app/screens/admin_book_uploader.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  final Color darkGalaxy = const Color(0xFF1A1A2E);
  final Color primaryNeon = const Color(0xFF8B5CF6);
  final Color matrixGreen = const Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGalaxy,
      body: Stack(
        children: [
          // پس‌زمینه نئونی
          Positioned(
            top: -100,
            left: -50,
            child: _buildGlowOrb(primaryNeon, 300),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: _buildGlowOrb(matrixGreen, 250),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),

                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(20),
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      // دکمه آپلودر کتاب (همان که قبلاً ساختیم)
                      _buildAdminTile(
                        title: "Book Injector",
                        subtitle: "Upload JSON to Firebase",
                        icon: Icons.auto_stories_rounded,
                        color: matrixGreen,
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          // رفتن به صفحه آپلودر
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminBookUploader()));
                        },
                      ),

                      // دکمه زاپاس ۱ (برای آینده - مثلاً مدیریت کاربران)
                      _buildAdminTile(
                        title: "User Control",
                        subtitle: "Manage Permissions",
                        icon: Icons.supervisor_account_rounded,
                        color: primaryNeon,
                        onTap: () => _showComingSoon(context),
                      ),

                      // دکمه زاپاس ۲ (مثلاً پاک کردن دیتای تستی)
                      _buildAdminTile(
                        title: "System Logs",
                        subtitle: "Check App Health",
                        icon: Icons.terminal_rounded,
                        color: Colors.orangeAccent,
                        onTap: () => _showComingSoon(context),
                      ),

                      // دکمه تنظیمات سرور
                      _buildAdminTile(
                        title: "Server Config",
                        subtitle: "API & Endpoints",
                        icon: Icons.settings_remote_rounded,
                        color: Colors.blueAccent,
                        onTap: () => _showComingSoon(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
          ),
          const SizedBox(height: 20),
          const Text(
            "Central Intelligence 🛰️",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Secret Admin Command Center",
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
        ],
      ),
    ).animate().fade().slideX();
  }

  Widget _buildAdminTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 40),
                const SizedBox(height: 15),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(delay: 100.ms, curve: Curves.easeOutBack);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Future module. Stay tuned! 🚀")),
    );
  }

  Widget _buildGlowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 100)],
      ),
    );
  }
}
