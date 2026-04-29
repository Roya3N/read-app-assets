import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  // 🔗 لینک صفحه برنامه‌ات تو گوگل پلی یا بازار رو اینجا می‌ذاری
  final String storeUrl =
      "https://play.google.com/store/apps/details?id=com.yourname.smartunlock";

  Future<void> _launchStore() async {
    HapticFeedback.heavyImpact();
    final Uri url = Uri.parse(storeUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          false, // 🛑 این خط باعث میشه کاربر نتونه با دکمه بکِ گوشی صفحه رو ببنده!
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D17),
        body: Stack(
          alignment: Alignment.center,
          children: [
            // هاله‌های پس‌زمینه
            Positioned(
              top: -100,
              right: -50,
              child: _buildGlow(const Color(0xFF8B5CF6)),
            ),
            Positioned(
              bottom: -100,
              left: -50,
              child: _buildGlow(const Color(0xFF3B82F6)),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // آیکون آپدیت
                  Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFBBF24).withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          size: 60,
                          color: Color(0xFFFBBF24),
                        ),
                      )
                      .animate()
                      .scale(duration: 500.ms, curve: Curves.easeOutBack)
                      .shimmer(delay: 1000.ms),

                  const SizedBox(height: 30),

                  // متن‌های صفحه
                  const Text(
                    "Time for an Upgrade! 🚀",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 15),

                  const Text(
                    "A new and improved version of the app is available. You need to update to continue your journey.",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 400.ms),

                  const SizedBox(height: 40),

                  // دکمه آپدیت
                  GestureDetector(
                    onTap: _launchStore,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download_rounded, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "UPDATE NOW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 600.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 100)],
      ),
    );
  }
}
