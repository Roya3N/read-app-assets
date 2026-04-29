import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:read_unlock_app/core/services/audio_service.dart';
import 'package:read_unlock_app/core/services/database_service.dart';
import 'package:read_unlock_app/core/utils/app_state.dart';
import 'dart:ui'; // برای افکت شیشه‌ای

class QuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> quiz;
  final String level;
  final List<dynamic> vocabulary;

  const QuizScreen({
    super.key,
    required this.quiz,
    required this.level,
    this.vocabulary = const [],
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedOption;
  bool isCorrect = false;
  bool isSavingReward = false;

  // 🎨 رنگ‌های تم Pro
  final Color darkGalaxy = const Color(0xFF1A1A2E);
  final Color accentNeon = const Color(0xFF8B5CF6);

  int getRewardTime() {
    switch (widget.level.toLowerCase()) {
      case 'hard':
        return 15;
      case 'medium':
        return 10;
      case 'easy':
      default:
        return 5;
    }
  }

  void checkAnswer(String option) {
    if (selectedOption != null) return;

    final correctAnswer = widget.quiz[currentQuestionIndex]['answer'];
    bool correct = (option == correctAnswer);

    setState(() {
      selectedOption = option;
      isCorrect = correct;
    });

    if (correct) {
      AudioService.playCorrect();
      HapticFeedback.mediumImpact();

      Future.delayed(const Duration(seconds: 1), () {
        if (currentQuestionIndex < widget.quiz.length - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedOption = null;
            isCorrect = false;
          });
        } else {
          giveReward();
        }
      });
    } else {
      AudioService.playWrong();
      HapticFeedback.vibrate();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => selectedOption = null);
      });
    }
  }

  Future<void> giveReward() async {
    setState(() => isSavingReward = true);
    final reward = getRewardTime();
    final childId = AppState.activeChildId;

    if (childId != null) {
      try {
        await AudioService.playReward();
        await DatabaseService.addDailyTime(childId, reward);
        if (widget.vocabulary.isNotEmpty) {
          await DatabaseService.saveLearnedWords(childId, widget.vocabulary);
        }
      } catch (e) {
        debugPrint("Error: $e");
      }
    }

    if (mounted) {
      setState(() => isSavingReward = false);
      _showProRewardPopup(reward);
    }
  }

  // 🏆 پاپ‌آپ جایزه شیشه‌ای و نئونی
  void _showProRewardPopup(int reward) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, a1, a2) => const SizedBox(),
      transitionBuilder: (context, a1, a2, child) {
        return Transform.scale(
          scale: Curves.elasticOut.transform(a1.value),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E24).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.greenAccent.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🎊", style: TextStyle(fontSize: 70)),
                      const SizedBox(height: 10),
                      const Text(
                        "YOU DID IT!",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "You earned $reward minutes of play time!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.green, Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.4),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Claim Reward 🎁",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quiz.isEmpty) {
      return Scaffold(
        backgroundColor: darkGalaxy,
        body: Center(
          child: Text(
            "No quiz found! 🎈",
            style: TextStyle(color: Colors.white54, fontSize: 20),
          ),
        ),
      );
    }

    final currentQ = widget.quiz[currentQuestionIndex];
    final question = currentQ['question'] ?? 'Question?';
    final options = (currentQ['options'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    return Scaffold(
      backgroundColor: darkGalaxy,
      body: Stack(
        children: [
          // 🌌 افکت‌های پس‌زمینه
          Positioned(top: -100, right: -100, child: _buildGlowOrb(accentNeon)),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildGlowOrb(Colors.blue),
          ),

          SafeArea(
            child: isSavingReward
                ? _buildLoading()
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // هدر
                        const Text(
                          "Quiz Time 🎯",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // نوار پیشرفت لیزری
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value:
                                (currentQuestionIndex + 1) / widget.quiz.length,
                            minHeight: 12,
                            backgroundColor: Colors.white10,
                            color: accentNeon,
                          ),
                        ),

                        const Spacer(),

                        // 📝 باکس سوال شیشه‌ای
                        _buildGlassQuestion(question),

                        const Spacer(),

                        // 🔘 گزینه‌ها
                        ...options.map((option) => _buildOptionButton(option)),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassQuestion(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    bool isThisSelected = selectedOption == option;
    Color btnColor = Colors.white.withOpacity(0.05);
    Color borderColor = Colors.white.withOpacity(0.1);

    if (isThisSelected) {
      btnColor = isCorrect
          ? Colors.green.withOpacity(0.2)
          : Colors.red.withOpacity(0.2);
      borderColor = isCorrect ? Colors.green : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () => checkAnswer(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: btnColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isThisSelected
                ? [
                    BoxShadow(
                      color: borderColor.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              option,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isThisSelected ? borderColor : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 20),
          const Text(
            "Magic in progress... ✨",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 100)],
      ),
    );
  }
}
