import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:read_unlock_app/core/utils/app_state.dart';
import 'alphabet_menu_screen.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  late int childAge;
  String selectedCategory = 'Kids (5-9 years)';

  final List<Map<String, String>> sidebarCategories = [
    {'id': 'Toddlers (3-4 years)', 'short': '3-4 Yrs', 'icon': '🐣'},
    {'id': 'Kids (5-9 years)', 'short': '5-9 Yrs', 'icon': '🚀'},
    {'id': 'Pre-teens (10-12 years)', 'short': '10-12 Yrs', 'icon': '⚡'},
    {'id': 'Teens (13-17 years)', 'short': '13-17 Yrs', 'icon': '🔥'},
  ];

  @override
  void initState() {
    super.initState();
    // پیدا کردن رده سنی پیش‌فرض کودک
    childAge = AppState.activeChildAge > 0 ? AppState.activeChildAge : 7;

    if (childAge >= 3 && childAge <= 4) {
      selectedCategory = 'Toddlers (3-4 years)';
    } else if (childAge >= 5 && childAge <= 9) {
      selectedCategory = 'Kids (5-9 years)';
    } else if (childAge >= 10 && childAge <= 12) {
      selectedCategory = 'Pre-teens (10-12 years)';
    } else {
      selectedCategory = 'Teens (13-17 years)';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isYoungerKids =
        selectedCategory == 'Toddlers (3-4 years)' ||
        selectedCategory == 'Kids (5-9 years)';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // پس‌زمینه کهکشانی
      body: Stack(
        children: [
          // 🌌 هاله‌های نوری پس‌زمینه
          Positioned(
            top: -100,
            left: -50,
            child: _buildGlowOrb(const Color(0xFF8B5CF6), 300)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(end: 1.2, duration: 4.seconds),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildGlowOrb(const Color(0xFF10B981), 250)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(end: 1.1, duration: 5.seconds),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎩 هدر صفحه
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        '🎓 Magic Academy',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ).animate().fade().slideX(begin: -0.2),
                ),

                // 📚 بدنه اصلی
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ⬅️ بخش چپ: لیست کلاس‌ها و ماموریت‌ها
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: ListView(
                            key: ValueKey(selectedCategory),
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 10,
                              bottom: 40,
                            ),
                            physics: const BouncingScrollPhysics(),
                            children: isYoungerKids
                                ? _buildYoungerKidsCurriculum()
                                : _buildOlderKidsCurriculum(),
                          ),
                        ),
                      ),

                      // ➡️ بخش راست: سایدبار رده سنی
                      _buildRightSidebar()
                          .animate()
                          .fade(delay: 300.ms)
                          .slideX(begin: 0.2),
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

  // ==========================================
  // محتوای آموزشی بچه‌های کوچک (۳ تا ۹ سال)
  // ==========================================
  List<Widget> _buildYoungerKidsCurriculum() {
    return [
      _buildActivityCard(
        title: "Magic Tracing",
        subtitle: "Learn to write the alphabet! ✍️",
        icon: "✏️",
        lessons: "26 Letters",
        time: "10 Min",
        xp: 20,
        color: const Color(0xFFF59E0B),
        isLocked: false,
        onTap: () {
          // حالا به جای رفتن به J، میره تو منوی انتخاب حروف!
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AlphabetMenuScreen()),
          );
        },
      ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
      const SizedBox(height: 15),
      _buildActivityCard(
        title: "Letter Hunter",
        subtitle: "Pop the right letter balloons! 🎈",
        icon: "🎯",
        lessons: "5 Levels",
        time: "15 Min",
        xp: 35,
        color: const Color(0xFF3B82F6),
        isLocked: true, // قفل برای ایجاد انگیزه
        onTap: () {},
      ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
      const SizedBox(height: 15),
      _buildActivityCard(
        title: "Sticker Album",
        subtitle: "Collect all magical flashcards! 🖼️",
        icon: "🌟",
        lessons: "26 Cards",
        time: "5 Min",
        xp: 10,
        color: const Color(0xFF8B5CF6),
        isLocked: true,
        onTap: () {},
      ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
    ];
  }

  // ==========================================
  // محتوای آموزشی بچه‌های بزرگتر (۱۰ تا ۱۷ سال)
  // ==========================================
  List<Widget> _buildOlderKidsCurriculum() {
    return [
      _buildActivityCard(
        title: "Grammar Quests",
        subtitle: "Master the rules of magic! 🧙‍♂️",
        icon: "📜",
        lessons: "12 Quests",
        time: "20 Min",
        xp: 50,
        color: const Color(0xFF10B981),
        isLocked: true, // فعلا قفله تا ساخته بشه
        onTap: () {},
      ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
      const SizedBox(height: 15),
      _buildActivityCard(
        title: "Speed Reading",
        subtitle: "Read like the wind! 🌪️",
        icon: "📖",
        lessons: "8 Levels",
        time: "15 Min",
        xp: 40,
        color: const Color(0xFFEC4899),
        isLocked: true,
        onTap: () {},
      ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
    ];
  }

  // ==========================================
  // کارتِ حرفه‌ای کلاس‌ها (هم‌شکل با عکس ارسالی)
  // ==========================================
  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required String icon,
    required String lessons,
    required String time,
    required int xp,
    required Color color,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          HapticFeedback.selectionClick();
          onTap();
        } else {
          HapticFeedback.vibrate();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isLocked ? 0.03 : 0.08),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isLocked
                ? Colors.white.withOpacity(0.05)
                : color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            if (!isLocked)
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          children: [
            // آیکون سمت چپ
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.white.withOpacity(0.05)
                    : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLocked ? Colors.transparent : color.withOpacity(0.5),
                ),
              ),
              child: Center(
                child: isLocked
                    ? const Icon(
                        Icons.lock_rounded,
                        color: Colors.white38,
                        size: 28,
                      )
                    : Text(icon, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 15),

            // متون و تگ‌ها
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isLocked ? Colors.white54 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.white24 : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // تگ‌های پایین (Lessons, Min, XP)
                  Row(
                    children: [
                      _buildTag(
                        Icons.grid_view_rounded,
                        lessons,
                        isLocked ? Colors.white24 : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                      _buildTag(
                        Icons.timer_rounded,
                        time,
                        isLocked ? Colors.white24 : const Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 8),
                      _buildTag(
                        Icons.stars_rounded,
                        "$xp XP",
                        isLocked ? Colors.white24 : const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // سایدبار راست (انتخاب سن)
  // ==========================================
  Widget _buildRightSidebar() {
    return Container(
      width: 95,
      margin: const EdgeInsets.only(right: 15, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sidebarCategories
                .map((cat) => _buildVerticalFilterChip(cat))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalFilterChip(Map<String, String> cat) {
    String id = cat['id']!;
    String range = cat['short']!.split(' ').first;
    String icon = cat['icon']!;
    bool isSelected = selectedCategory == id;

    // پیدا کردن رنگ متناسب با سن (مثل عکس ارسالی)
    Color activeColor = const Color(0xFF8B5CF6);
    if (id == 'Toddlers (3-4 years)') activeColor = const Color(0xFFF59E0B);
    if (id == 'Pre-teens (10-12 years)') activeColor = const Color(0xFF10B981);
    if (id == 'Teens (13-17 years)') activeColor = const Color(0xFFEF4444);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => selectedCategory = id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? activeColor.withOpacity(0.5)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: activeColor.withOpacity(0.4),
                blurRadius: 15.0,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              range,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Yrs",
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 100)],
      ),
    );
  }
}
