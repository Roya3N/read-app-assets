import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:read_unlock_app/core/services/audio_service.dart';
import 'package:read_unlock_app/core/services/database_service.dart';
import 'package:read_unlock_app/core/utils/app_state.dart';

class ReadingScreen extends StatefulWidget {
  final List<String> pages;
  final List<String> pageTexts;
  final String title;
  final String level;
  final List<Map<String, dynamic>> quiz;
  final int xpReward;
  final int timeReward;
  final List<String> vocabulary;

  const ReadingScreen({
    super.key,
    required this.pages,
    required this.pageTexts,
    required this.title,
    required this.level,
    required this.quiz,
    required this.xpReward,
    required this.timeReward,
    this.vocabulary = const [],
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  bool isButtonEnabled = false;
  int currentPageIndex = 0;
  late List<String> pages;

  late FlutterTts flutterTts;
  Set<int> answeredQuizIndices = {};
  bool isTextVisible = false;

  double _ttsRate = 0.45;
  double _ttsPitch = 1.2;

  // 🎨 رنگ‌های تم Pro (Dark Neon)
  final Color primaryGlow = const Color(0xFF8B5CF6);
  final Color accentNeon = const Color(0xFF4ADE80);
  final Color darkGlass = const Color(0xFF1E1E24).withOpacity(0.85);

  @override
  void initState() {
    super.initState();
    pages = widget.pages;
    flutterTts = FlutterTts();
    _initTts();
    startReadingDelay();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(_ttsRate);
    await flutterTts.setPitch(_ttsPitch);
    await flutterTts.setVolume(1.0);
  }

  void _applyTtsSettings() {
    flutterTts.setSpeechRate(_ttsRate);
    flutterTts.setPitch(_ttsPitch);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void startReadingDelay() {
    isButtonEnabled = false;
    Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => isButtonEnabled = true);
    });
  }

  // ==========================================
  // 🎛️ دیالوگ تنظیمات صدا (Glass Design)
  // ==========================================
  void _showVoiceSettingsDialog() {
    HapticFeedback.lightImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'VoiceSettings',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, a1, a2) => const SizedBox(),
      transitionBuilder: (context, a1, a2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(a1.value),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: darkGlass,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.tune_rounded, color: Color(0xFF8B5CF6)),
                          SizedBox(width: 8),
                          Text(
                            "Voice Magic",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // سرعت صدا
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "🐢 Slow",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                          Text(
                            "Speed",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Fast 🐇",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
                          value: _ttsRate,
                          min: 0.1,
                          max: 1.0,
                          activeColor: accentNeon,
                          inactiveColor: Colors.white12,
                          onChanged: (val) {
                            setState(() => _ttsRate = val);
                            _applyTtsSettings();
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // زیری و بمی صدا
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "🐻 Deep",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                          Text(
                            "Voice",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "High 🐦",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
                          value: _ttsPitch,
                          min: 0.5,
                          max: 2.0,
                          activeColor: const Color(0xFFF59E0B),
                          inactiveColor: Colors.white12,
                          onChanged: (val) {
                            setState(() => _ttsPitch = val);
                            _applyTtsSettings();
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // دکمه تست
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGlow.withOpacity(0.2),
                          foregroundColor: primaryGlow,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: primaryGlow.withOpacity(0.5),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          flutterTts.speak("Hello! I am ready to read a book.");
                        },
                        icon: const Icon(Icons.play_circle_fill),
                        label: const Text(
                          "Test Voice",
                          style: TextStyle(fontWeight: FontWeight.bold),
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

  // ==========================================
  // 🧩 پاپ‌آپ کوئیز هوشمند (Pro Edition)
  // ==========================================
  void _showSequenceQuizPopup({bool isFinish = false}) {
    List<int> pendingQuizIndices = [];
    for (int i = 0; i < widget.quiz.length; i++) {
      final pageNum = widget.quiz[i]['page'] ?? 999;
      if (pageNum <= (currentPageIndex + 1) &&
          !answeredQuizIndices.contains(i)) {
        pendingQuizIndices.add(i);
      }
    }

    if (pendingQuizIndices.isEmpty) {
      if (isFinish) {
        _finishBookAndReward();
      } else {
        startReadingDelay();
      }
      return;
    }

    int sequenceIndex = 0;
    HapticFeedback.heavyImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, a1, a2) => const SizedBox(),
      transitionBuilder: (context, a1, a2, child) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            final quizIndexInDb = pendingQuizIndices[sequenceIndex];
            final currentQuiz = widget.quiz[quizIndexInDb];
            final question = currentQuiz['question'] ?? '';
            final answer = currentQuiz['answer'] ?? '';
            final optionsRaw = currentQuiz['options'] as List<dynamic>? ?? [];
            final options = optionsRaw.map((e) => e.toString()).toList();
            String? selectedOption;
            bool? isCorrect;

            return Transform.scale(
              scale: Curves.easeOutBack.transform(a1.value),
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A24).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: primaryGlow.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryGlow.withOpacity(0.2),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryGlow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Challenge ${sequenceIndex + 1} of ${pendingQuizIndices.length}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryGlow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Center(
                            child: Text(
                              "🎯 Quiz Time!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            question,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 25),

                          ...options.map((option) {
                            bool isThisSelected = (selectedOption == option);
                            Color btnColor = const Color(0xFF2A2A35);
                            Color borderColor = Colors.white12;
                            Color textColor = Colors.white;

                            if (isThisSelected) {
                              btnColor = (isCorrect == true)
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2);
                              borderColor = (isCorrect == true)
                                  ? Colors.greenAccent
                                  : Colors.redAccent;
                              textColor = (isCorrect == true)
                                  ? Colors.greenAccent
                                  : Colors.redAccent;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  if (selectedOption != null) return;
                                  setPopupState(() {
                                    selectedOption = option;
                                    isCorrect = (option == answer);
                                  });

                                  if (isCorrect == true) {
                                    AudioService.playCorrect();
                                    HapticFeedback.lightImpact();
                                    answeredQuizIndices.add(quizIndexInDb);
                                    Future.delayed(
                                      const Duration(seconds: 1),
                                      () {
                                        if (sequenceIndex <
                                            pendingQuizIndices.length - 1) {
                                          setPopupState(() {
                                            sequenceIndex++;
                                            selectedOption = null;
                                            isCorrect = null;
                                          });
                                        } else {
                                          // ✅ کدهای جدید (Pro Fix):
                                          Navigator.pop(context);
                                          Future.delayed(
                                            const Duration(milliseconds: 50),
                                            () {
                                              if (isFinish) {
                                                _finishBookAndReward();
                                              } else {
                                                startReadingDelay();
                                              }
                                            },
                                          );
                                        }
                                      },
                                    );
                                  } else {
                                    AudioService.playWrong();
                                    HapticFeedback.heavyImpact();
                                    Future.delayed(
                                      const Duration(seconds: 1),
                                      () {
                                        Navigator.pop(context);
                                        setState(() {
                                          int goBackTo =
                                              (currentQuiz['page'] ?? 1) - 1;
                                          currentPageIndex = goBackTo >= 0
                                              ? goBackTo
                                              : 0;
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              "🤔 Let's read this page again!",
                                            ),
                                            backgroundColor:
                                                Colors.orange.shade800,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        startReadingDelay();
                                      },
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: btnColor,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 🎁 سیستم جایزه‌دهی امن و ابری (Cloud Sync)
  // ==========================================
  Future<void> _finishBookAndReward() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
      ),
    );

    try {
      int earnedXp = widget.xpReward;
      int earnedTime = widget.timeReward;
      final parentId = FirebaseAuth.instance.currentUser?.uid;

      // ☁️ ۱. ذخیره مستقیم و قطعی در سرور فایربیس
      if (parentId != null && AppState.activeChildId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('parents')
            .doc(parentId)
            .collection('children')
            .doc(AppState.activeChildId)
            .update({
              'xp': FieldValue.increment(earnedXp),
              'timeBalance': FieldValue.increment(earnedTime),
            });

        // آپدیت حافظه موقت (برای تغییرات لحظه‌ای در UI)
        AppState.timeBalance += earnedTime;
        await AppState.save();

        // 🛡️ ۲. تلاش برای ذخیره آمار روزانه و کلمات (با سپر محافظتی)
        try {
          await DatabaseService.addDailyTime(
            AppState.activeChildId,
            earnedTime,
          );
          if (widget.vocabulary.isNotEmpty) {
            await DatabaseService.saveLearnedWords(
              AppState.activeChildId,
              widget.vocabulary,
            );
          }
        } catch (dbError) {
          debugPrint(
            "⚠️ Rules blocked stats/vocab save, but XP is safe! Error: $dbError",
          );
        }
      }

      // 🎵 ۳. پخش صدای جایزه
      await AudioService.playReward();
      HapticFeedback.heavyImpact();

      if (mounted) {
        Navigator.pop(context); // بستن لودینگ

        // 🚀 ۴. نمایش پیام موفقیت جذاب
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "YAY! +$earnedXp XP  &  +$earnedTime Min Time! ⏳",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4ADE80),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );

        // ۵. بازگشت به داشبورد
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
        });
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint("❌ CRITICAL ERROR saving rewards: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error syncing with server!"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void goNext() {
    flutterTts.stop();
    HapticFeedback.lightImpact();
    if (currentPageIndex < pages.length - 1) {
      setState(() {
        currentPageIndex++;
        isTextVisible = false;
      });
      if ((currentPageIndex + 1) % 3 == 0) {
        _showSequenceQuizPopup(isFinish: false);
      } else {
        startReadingDelay();
      }
    } else {
      _showSequenceQuizPopup(isFinish: true);
    }
  }

  void goPrevious() {
    flutterTts.stop();
    HapticFeedback.lightImpact();
    if (currentPageIndex > 0) {
      setState(() {
        currentPageIndex--;
        isTextVisible = false;
      });
      startReadingDelay();
    }
  }

  // ==========================================
  // 📖 ویجت کلمات قابل لمس (Interactive Text)
  // ==========================================
  Widget _buildInteractiveText() {
    if (widget.pageTexts.isEmpty ||
        currentPageIndex >= widget.pageTexts.length) {
      return const SizedBox.shrink();
    }
    String currentText = widget.pageTexts[currentPageIndex];
    List<String> words = currentText.split(RegExp(r'\s+'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A35).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 10.0,
        children: words.map((word) {
          String cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '');
          return GestureDetector(
            onTap: () async {
              HapticFeedback.selectionClick();
              await flutterTts.speak(cleanWord);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                word,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = pages.length;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // 🌌 پس‌زمینه فضایی/نئونی
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: primaryGlow.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryGlow.withOpacity(0.2),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: accentNeon.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentNeon.withOpacity(0.15),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 🛸 AppBar اختصاصی
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.settings_voice_rounded,
                          color: Colors.white,
                        ),
                        tooltip: "Voice Settings",
                        onPressed: _showVoiceSettingsDialog,
                      ),
                    ],
                  ),
                ),

                // 📊 کنترل‌های بالای تصویر
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Page ${currentPageIndex + 1} of $totalPages',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      if (widget.pageTexts.isNotEmpty &&
                          currentPageIndex < widget.pageTexts.length)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => isTextVisible = !isTextVisible);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isTextVisible
                                  ? primaryGlow.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isTextVisible
                                    ? primaryGlow
                                    : Colors.white24,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isTextVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 16,
                                  color: isTextVisible
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isTextVisible ? "Hide Text" : "Read Text",
                                  style: TextStyle(
                                    color: isTextVisible
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 🖼️ تصویر کتاب
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 15,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          pages[currentPageIndex],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF8B5CF6),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Text(
                                  "Error loading image 😢",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 📝 باکس کلمات
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isTextVisible
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ).copyWith(bottom: 15),
                          child: _buildInteractiveText(),
                        )
                      : const SizedBox.shrink(),
                ),

                // 🚢 داک شناور پایین صفحه (Glass Dock)
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: darkGlass,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // نوار پیشرفت مینیاتوری
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: LinearProgressIndicator(
                          value: (currentPageIndex + 1) / totalPages,
                          backgroundColor: Colors.white12,
                          color: primaryGlow,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // دکمه قبلی
                          IconButton(
                            onPressed: currentPageIndex > 0 ? goPrevious : null,
                            icon: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: currentPageIndex > 0
                                  ? Colors.white70
                                  : Colors.white24,
                            ),
                          ),

                          // دکمه بعدی / پایان
                          GestureDetector(
                            onTap: isButtonEnabled ? goNext : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isButtonEnabled
                                    ? accentNeon
                                    : Colors.white12,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isButtonEnabled
                                    ? [
                                        BoxShadow(
                                          color: accentNeon.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(
                                isButtonEnabled
                                    ? (currentPageIndex == totalPages - 1
                                          ? 'Finish 🎉'
                                          : 'Next ➡️')
                                    : 'Reading...',
                                style: TextStyle(
                                  color: isButtonEnabled
                                      ? Colors.black87
                                      : Colors.white38,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
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
}
