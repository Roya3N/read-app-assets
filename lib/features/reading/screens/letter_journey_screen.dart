import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:read_unlock_app/features/engagement/screens/tracing_screen.dart';

class LetterJourneyScreen extends StatefulWidget {
  final String letter;

  const LetterJourneyScreen({super.key, required this.letter});

  @override
  State<LetterJourneyScreen> createState() => _LetterJourneyScreenState();
}

class _LetterJourneyScreenState extends State<LetterJourneyScreen> {
  // سطح پیشرفت کاربر برای این حرف (در نسخه نهایی این عدد از دیتابیس خوانده می‌شود)
  // 0 = فقط نقاشی باز است
  // 1 = نقاشی تمام شده، فعالیت باز است
  // 2 = فعالیت تمام شده، پوستر جایزه باز است
  int currentLevel = 0;

  // 🔗 لینک‌های گیت‌هاب شما (اینجا لینک‌های واقعی خودت رو جایگزین کن)
  final String githubPosterUrl =
      "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/assets/images/posters/a_astronaut.jpg";

  // شبیه‌سازی پایان یک مرحله و باز شدن قفل بعدی
  void _completeStage(int stageCompleted) {
    if (currentLevel == stageCompleted) {
      setState(() {
        currentLevel++;
      });
      // نمایش پیام تشویقی
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✨ Level Up! New Magic Unlocked!"),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Journey of '${widget.letter}'",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            // ⭐️ مرحله ۱: نقاشی (همیشه باز است)
            _buildJourneyCard(
              title: "1. Magic Tracing",
              subtitle: "Learn how to write!",
              icon: "✏️",
              color: const Color(0xFF3B82F6),
              isLocked: false,
              isCompleted: currentLevel > 0,
              onTap: () async {
                HapticFeedback.lightImpact();
                // رفتن به صفحه نقاشی و انتظار برای برگشت
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TracingScreen(
                      letter: widget.letter,
                      // فعلاً لینک تستی (اینجا هم میتونی لینک نتورک گیت‌هاب بذاری)
                      imagePath:
                          'assets/images/Magic_Tracing/${widget.letter.toLowerCase()}.png',
                    ),
                  ),
                );
                // وقتی از نقاشی برگشت، فرض می‌کنیم موفق شده و قفل بعدی رو باز می‌کنیم
                _completeStage(0);
              },
            ).animate().fade(delay: 100.ms).slideX(begin: -0.2),

            // 🎯 خط اتصال
            _buildConnectorText(currentLevel >= 1),

            // ⭐️ مرحله ۲: کاربرگ فعالیت
            _buildJourneyCard(
              title: "2. Brain Activity",
              subtitle: "Find the hidden letters!",
              icon: "🧩",
              color: const Color(0xFFF59E0B),
              isLocked: currentLevel < 1,
              isCompleted: currentLevel > 1,
              onTap: () {
                // TODO: ساخت صفحه اکتیویتی دوم
                // فعلاً با یک کلیک ساده مرحله رو پاس می‌کنیم تا باز شدن پوستر رو ببینی
                _completeStage(1);
              },
            ).animate().fade(delay: 300.ms).slideX(begin: 0.2),

            // 🎯 خط اتصال
            _buildConnectorText(currentLevel >= 2),

            // ⭐️ مرحله ۳: پوستر جادویی نهایی (با قابلیت دانلود از اینترنت)
            _buildRewardCard()
                .animate()
                .fade(delay: 500.ms)
                .scale(curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ویجت‌های کمکی برای طراحی صفحه
  // ==========================================

  Widget _buildConnectorText(bool isUnlocked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Icon(
          Icons.keyboard_double_arrow_down_rounded,
          color: isUnlocked ? const Color(0xFF10B981) : Colors.white24,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildJourneyCard({
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required bool isLocked,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          onTap();
        } else {
          HapticFeedback.vibrate();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.white.withOpacity(0.05)
              : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF10B981)
                : (isLocked ? Colors.white12 : color.withOpacity(0.5)),
            width: 2,
          ),
          boxShadow: [
            if (!isLocked && !isCompleted)
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF10B981).withOpacity(0.2)
                    : (isLocked ? Colors.white12 : color.withOpacity(0.2)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF10B981),
                        size: 30,
                      )
                    : (isLocked
                          ? const Icon(
                              Icons.lock_rounded,
                              color: Colors.white38,
                            )
                          : Text(icon, style: const TextStyle(fontSize: 28))),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isLocked ? Colors.white38 : Colors.white,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isLocked ? Colors.white24 : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🖼️ کارت ویژه برای پوستر نهایی (استفاده از گیت‌هاب و کش)
  Widget _buildRewardCard() {
    bool isLocked = currentLevel < 2;

    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          HapticFeedback.heavyImpact();
          _showFullPosterDialog();
        } else {
          HapticFeedback.vibrate();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: 200,
        decoration: BoxDecoration(
          color: isLocked ? Colors.white.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isLocked ? Colors.white12 : const Color(0xFFFBBF24),
            width: isLocked ? 2 : 4,
          ),
          boxShadow: [
            if (!isLocked)
              BoxShadow(
                color: const Color(0xFFFBBF24).withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: isLocked
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, color: Colors.white24, size: 50),
                    SizedBox(height: 10),
                    Text(
                      "Complete previous steps to unlock",
                      style: TextStyle(
                        color: Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    // 🚀 لود عکس از گیت‌هاب با کش
                    CachedNetworkImage(
                      imageUrl: githubPosterUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white12,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_rounded,
                              color: Colors.white54,
                              size: 40,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Oops! Can't load magic.",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // یک افکت تاریک برای خوانایی متن روی عکس
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            "🎉 UNLOCKED! 🎉",
                            style: TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Tap to view full Magic Poster",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // 🌟 دیالوگ نمایش پوستر به صورت تمام صفحه
  void _showFullPosterDialog() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      barrierDismissible: true,
      barrierLabel: "Poster",
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: InteractiveViewer(
            // قابلیت زوم کردن روی عکس
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: githubPosterUrl,
                width: MediaQuery.of(context).size.width * 0.9,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(color: Colors.orangeAccent),
              ),
            ),
          ),
        );
      },
    );
  }
}
