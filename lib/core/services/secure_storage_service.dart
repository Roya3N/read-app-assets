import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // ساخت یک نمونه (Instance) از کلاس استوریج با تنظیمات امن‌تر برای اندروید
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // تعریف کلیدها در یک جا برای جلوگیری از خطای تایپی (Best Practice)
  static const String _pinKey = 'parent_pin';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lockoutTimeKey = 'lockout_time';

  // ==========================================
  // 🔑 بخش مدیریت پین‌کد
  // ==========================================

  // 🔒 متد برای ذخیره پین‌کد والدین
  Future<void> saveParentPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  // 🔓 متد برای خواندن پین‌کد والدین
  Future<String?> getParentPin() async {
    return await _storage.read(key: _pinKey);
  }

  // 🗑️ متد برای پاک کردن پین‌کد (مثلا زمان حذف اکانت)
  Future<void> deleteParentPin() async {
    await _storage.delete(key: _pinKey);
  }

  // ==========================================
  // 🛡️ سیستم قفل در برابر حدس رمز (Brute-Force)
  // ==========================================

  // ذخیره تعداد دفعات اشتباه
  Future<void> saveFailedAttempts(int attempts) async {
    await _storage.write(key: _failedAttemptsKey, value: attempts.toString());
  }

  // خواندن تعداد دفعات اشتباه
  Future<int> getFailedAttempts() async {
    String? attemptsStr = await _storage.read(key: _failedAttemptsKey);
    return int.tryParse(attemptsStr ?? '0') ?? 0;
  }

  // ذخیره زمانِ پایان قفل (مثلاً 15 دقیقه آینده)
  Future<void> saveLockoutTime(DateTime lockoutUntil) async {
    await _storage.write(
      key: _lockoutTimeKey,
      value: lockoutUntil.toIso8601String(),
    );
  }

  // خواندن زمانِ پایان قفل
  Future<DateTime?> getLockoutTime() async {
    String? timeStr = await _storage.read(key: _lockoutTimeKey);
    if (timeStr != null) {
      return DateTime.tryParse(timeStr);
    }
    return null;
  }

  // ریست کردن قفل (وقتی رمز درست وارد شد یا زمان قفل تموم شد)
  Future<void> resetLockout() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockoutTimeKey);
  }
}
