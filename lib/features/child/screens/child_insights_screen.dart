import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // برای افکت‌های Glassmorphism

class ChildInsightsScreen extends StatefulWidget {
  final String childId;
  final Map<String, dynamic> childData;

  const ChildInsightsScreen({
    super.key,
    required this.childId,
    required this.childData,
  });

  @override
  State<ChildInsightsScreen> createState() => _ChildInsightsScreenState();
}

class _ChildInsightsScreenState extends State<ChildInsightsScreen> {
  List<Map<String, dynamic>> weekActivity = [];
  bool isLoadingChart = true;
  double maxChartValue = 60.0;

  // 🎨 رنگ‌های تم Pro و کودکانه
  final Color primaryNeon = const Color(0xFF8B5CF6);
  final Color accentPink = const Color(0xFFEC4899);
  final Color darkGalaxy = const Color(0xFF0F0F13);
  final Color glassCard = const Color(0xFF1E1E24).withOpacity(0.7);

  @override
  void initState() {
    super.initState();
    _fetchWeeklyActivity();
  }

  Future<void> _fetchWeeklyActivity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DateTime now = DateTime.now();
    List<Map<String, dynamic>> tempData = [];
    List<String> dateStrings = [];

    for (int i = 6; i >= 0; i--) {
      DateTime d = now.subtract(Duration(days: i));
      String dateStr = DateFormat('yyyy-MM-dd').format(d);
      String dayName = DateFormat('E').format(d).substring(0, 3); // Mon, Tue...
      dateStrings.add(dateStr);
      tempData.add({'day': dayName, 'date': dateStr, 'val': 0.0});
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(user.uid)
          .collection('children')
          .doc(widget.childId)
          .collection('daily_activity')
          .where('date', whereIn: dateStrings)
          .get();

      double maxVal = 0;

      for (var doc in querySnapshot.docs) {
        String dDate = doc['date'];
        int mins = doc['minutes'] ?? 0;
        int index = tempData.indexWhere((element) => element['date'] == dDate);
        if (index != -1) {
          tempData[index]['val'] = mins.toDouble();
          if (mins > maxVal) maxVal = mins.toDouble();
        }
      }

      if (mounted) {
        setState(() {
          weekActivity = tempData;
          maxChartValue = maxVal > 60.0 ? maxVal : 60.0;
          isLoadingChart = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingChart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.childData['name'] ?? 'Explorer';
    final int xp = widget.childData['xp'] ?? 0;
    final int level = (xp ~/ 100) + 1;
    final int xpProgress = xp % 100;
    final int savedTime = widget.childData['timeBalance'] ?? 0;
    final List<dynamic> learnedWords = widget.childData['learnedWords'] ?? [];

    return Scaffold(
      backgroundColor: darkGalaxy, // تم کهکشان تاریک
      body: Stack(
        children: [
          // 🌌 هاله‌های نورانی کهکشان (فضای کودکانه)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: accentPink.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentPink.withOpacity(0.3),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // هدر
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          "$name's Journey 🚀",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // حفظ تعادل هدر
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ۱. کارت پیشرفت فضایی (Glassmorphism)
                        _buildProLevelCard(level, xpProgress, xp, savedTime),
                        const SizedBox(height: 35),

                        // ۲. نمودار فعالیت هفتگی
                        const Text(
                          "Activity This Week 📊",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 15),
                        isLoadingChart
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF8B5CF6),
                                ),
                              )
                            : _buildProActivityChart(),
                        const SizedBox(height: 35),

                        // ۳. گنجینه کلمات یادگرفته شده
                        const Text(
                          "Vocabulary Gems 💎",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 15),
                        learnedWords.isEmpty
                            ? _buildProEmptyWordsState()
                            : _buildProWordsGrid(learnedWords),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 🌟 بخش 1: کارت پیشرفت (شیشه‌ای و پفکی) ---
  Widget _buildProLevelCard(
    int level,
    int xpProgress,
    int totalXp,
    int savedTime,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: glassCard,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // حلقه لول (Level Ring)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: xpProgress / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryNeon),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "LEVEL",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white54,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        "$level",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Container(
                width: 1.5,
                height: 80,
                color: Colors.white.withOpacity(0.1),
              ),

              // آمارها (Stats)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProMiniStat(
                    "Total XP",
                    "$totalXp",
                    Icons.stars_rounded,
                    const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 20),
                  _buildProMiniStat(
                    "Saved Time",
                    "$savedTime min",
                    Icons.timer_rounded,
                    const Color(0xFF4ADE80),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 📈 بخش 2: نمودار ستونی (لوله نئونی شیشه‌ای) ---
  Widget _buildProActivityChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      decoration: BoxDecoration(
        color: glassCard,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weekActivity.map((data) {
          double rawPercent = data['val'] / maxChartValue;
          final double heightPercent = rawPercent.clamp(0.0, 1.0);
          final bool isToday =
              data['date'] == DateFormat('yyyy-MM-dd').format(DateTime.now());
          final bool hasData = data['val'] > 0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // لوله شیشه‌ای پس‌زمینه
              Expanded(
                child: Container(
                  width: 16,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    width: 16,
                    height: hasData
                        ? (140 * heightPercent).clamp(10.0, 140.0)
                        : 0, // حداقل ارتفاع برای روزهای دارای دیتا
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isToday
                            ? [const Color(0xFF4ADE80), const Color(0xFF22C55E)]
                            : [
                                const Color(0xFF3B82F6),
                                const Color(0xFF2563EB),
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: hasData
                          ? [
                              BoxShadow(
                                color: isToday
                                    ? const Color(0xFF4ADE80).withOpacity(0.4)
                                    : const Color(0xFF3B82F6).withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data['day'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                  color: isToday ? Colors.white : Colors.white38,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // --- 📖 بخش 3: کلمات (سنگ‌های کریستالی) ---
  Widget _buildProWordsGrid(List<dynamic> words) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: words.map((word) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A35).withOpacity(0.6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFBBF24),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                word.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProEmptyWordsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: glassCard,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Text("🌱", style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 20),
          const Text(
            "The journey has just begun!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "No magic words collected yet.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
