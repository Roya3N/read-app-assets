import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 ایمپورت فایربیس اضافه شد
import 'package:firebase_auth/firebase_auth.dart'; // 👈 ایمپورت احراز هویت اضافه شد
import 'package:read_unlock_app/core/services/secure_storage_service.dart';
import 'dart:ui';
import 'dart:async';

class PinScreen extends StatefulWidget {
  final bool isSetup;

  const PinScreen({super.key, this.isSetup = false});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _controller = TextEditingController();
  final SecureStorageService _secureStorage =
      SecureStorageService(); // نمونه‌سازی از کلاس

  String error = '';
  bool _isObscured = true;
  bool _isLoading = true; // وضعیت بررسی اطلاعات اولیه

  // متغیرهای امنیتی
  String? _savedPin;
  bool _isLockedOut = false;
  String _lockoutMessage = '';
  Timer? _lockoutTimer;

  bool get isSetupMode =>
      widget.isSetup || _savedPin == null || _savedPin!.isEmpty;

  @override
  void initState() {
    super.initState();
    _checkSecurityStatus(); // به محض باز شدن صفحه، وضعیت امنیتی بررسی میشه
  }

  // ==========================================
  // 🛡️ بررسی وضعیت امنیتی و هماهنگی با دیتابیس (Pro Fix)
  // ==========================================
  Future<void> _checkSecurityStatus() async {
    // ۱. آیا در وضعیت مسدودی هستیم؟
    DateTime? lockoutTime = await _secureStorage.getLockoutTime();
    if (lockoutTime != null && DateTime.now().isBefore(lockoutTime)) {
      _startLockoutTimer(lockoutTime);
      return;
    } else {
      // اگر زمان مسدودی تمام شده بود، قفل را باز کن
      await _secureStorage.resetLockout();
    }

    // ۲. خواندن رمز از حافظه امن گوشی
    _savedPin = await _secureStorage.getParentPin();

    // ۳. 👈 چک کردن دیتابیس ابری اگر گوشی خالی بود
    if (_savedPin == null || _savedPin!.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('parents')
              .doc(user.uid)
              .get();

          if (doc.exists && doc.data()!.containsKey('parentPin')) {
            _savedPin = doc.data()!['parentPin'];
            // رمز دانلود شده رو تو حافظه امن گوشی هم ذخیره کن تا دفعات بعد سریع‌تر باز شه
            await _secureStorage.saveParentPin(_savedPin!);
          }
        } catch (e) {
          debugPrint("Error fetching PIN from Firebase: $e");
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ==========================================
  // ⏳ تایمر مسدودی (۱۵ دقیقه)
  // ==========================================
  void _startLockoutTimer(DateTime lockoutTime) {
    if (mounted) {
      setState(() {
        _isLockedOut = true;
        _isLoading = false;
      });
    }

    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isAfter(lockoutTime)) {
        timer.cancel();
        _secureStorage.resetLockout();
        if (mounted) {
          setState(() {
            _isLockedOut = false;
            _lockoutMessage = '';
            error = '';
          });
        }
      } else {
        final remaining = lockoutTime.difference(now);
        final minutes = remaining.inMinutes;
        final seconds = remaining.inSeconds % 60;
        if (mounted) {
          setState(() {
            _lockoutMessage =
                'Too many attempts. Try again in ${minutes}m ${seconds}s';
          });
        }
      }
    });
  }

  // ==========================================
  // ✅ متد تایید و ذخیره رمز عبور
  // ==========================================
  void _submit() async {
    if (_isLockedOut) {
      HapticFeedback.vibrate();
      return;
    }

    HapticFeedback.mediumImpact();
    final input = _controller.text.trim();

    if (input.length < 4) {
      setState(() => error = 'Password must be at least 4 characters');
      return;
    }

    // حالت تنظیم رمز جدید
    if (isSetupMode) {
      // 🔒 ۱. ذخیره امن در حافظه گوشی
      await _secureStorage.saveParentPin(input);

      // ☁️ ۲. ذخیره در دیتابیس ابری فایربیس (Pro Fix)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('parents')
              .doc(user.uid)
              .set({'parentPin': input}, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Error saving PIN to Firebase: $e");
        }
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    }
    // حالت بررسی رمز وارد شده
    else {
      if (input == _savedPin) {
        // اگر رمز درست بود، همه خطاها را صفر کن و وارد شو
        await _secureStorage.resetLockout();
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        HapticFeedback.vibrate();

        // 🚨 منطق Brute-Force Protection
        int failedAttempts = await _secureStorage.getFailedAttempts();
        failedAttempts += 1;

        if (failedAttempts >= 5) {
          // بعد از ۵ بار اشتباه، صفحه را برای ۱۵ دقیقه قفل کن
          final lockoutTime = DateTime.now().add(const Duration(minutes: 15));
          await _secureStorage.saveLockoutTime(lockoutTime);
          _startLockoutTimer(lockoutTime);
          setState(() {
            _controller.clear();
          });
        } else {
          // فقط خطا رو نشون بده و بگو چند بار دیگه فرصت داره
          await _secureStorage.saveFailedAttempts(failedAttempts);
          setState(() {
            error = 'Incorrect Password. ${5 - failedAttempts} attempts left!';
            _controller.clear();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // 🌌 تم کهکشانی
      body: Stack(
        children: [
          // 🎨 افکت‌های نوری پس‌زمینه
          Positioned(
            top: -100,
            right: -100,
            child: _buildGlowOrb(const Color(0xFF8B5CF6)),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildGlowOrb(const Color(0xFF3B82F6)),
          ),

          // 👈 جادوی وسط‌چین کردن صفحه
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // آیکون قفل نئونی
                        _buildNeonIcon().animate().scale(
                          curve: Curves.easeOutBack,
                          duration: 600.ms,
                        ),

                        const SizedBox(height: 30),
                        Text(
                          _isLockedOut
                              ? 'Access Blocked'
                              : (isSetupMode
                                    ? 'Security Setup'
                                    : 'Parent Access'),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: _isLockedOut
                                ? Colors.redAccent
                                : Colors.white,
                            letterSpacing: 1,
                          ),
                        ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 10),
                        Text(
                          _isLockedOut
                              ? 'Security measure activated'
                              : 'Use letters, numbers, and symbols',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fade(delay: 300.ms),

                        const SizedBox(height: 50),

                        // اگر مسدود شده بود، پیام زمان رو نشون بده، در غیر این صورت فیلد ورودی
                        if (_isLockedOut)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 25,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.timer_off_rounded,
                                  color: Colors.redAccent,
                                  size: 30,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _lockoutMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fade().shake()
                        else ...[
                          // ⌨️ ورودی متنی شیشه‌ای
                          _buildGlassInput()
                              .animate()
                              .fade(delay: 400.ms)
                              .slideX(),

                          if (error.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                error,
                                style: const TextStyle(
                                  color: Color(0xFFF87171),
                                  fontWeight: FontWeight.bold,
                                ),
                              ).animate().shake(),
                            ),

                          const SizedBox(height: 40),

                          // دکمه تایید
                          _buildConfirmButton()
                              .animate()
                              .fade(delay: 500.ms)
                              .scale(),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // دکمه بازگشت
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white70,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonIcon() {
    final color = _isLockedOut ? Colors.redAccent : const Color(0xFF60A5FA);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 30)],
      ),
      child: Icon(
        _isLockedOut
            ? Icons.block_rounded
            : (isSetupMode
                  ? Icons.security_rounded
                  : Icons.lock_outline_rounded),
        size: 50,
        color: color,
      ),
    );
  }

  Widget _buildGlassInput() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _controller,
            obscureText: _isObscured,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              hintText: 'Enter Password',
              hintStyle: const TextStyle(
                color: Colors.white24,
                letterSpacing: 0,
              ),
              contentPadding: const EdgeInsets.all(20),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isObscured = !_isObscured);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: _submit,
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
        child: const Center(
          child: Text(
            'CONFIRM ACCESS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowOrb(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 100)],
      ),
    );
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
