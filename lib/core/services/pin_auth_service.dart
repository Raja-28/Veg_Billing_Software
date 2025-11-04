import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ==============================
/// 🔐 PIN Authentication Service
/// ==============================
/// Handles secure PIN storage, verification, and management
class PinAuthService {
  static const String _pinKey = 'user_pin_hash';
  static const String _pinSetKey = 'pin_is_set';
  static const String _maxAttemptsKey = 'max_attempts';
  static const String _lockoutTimeKey = 'lockout_time';
  static const int _maxAttempts = 5;
  static const int _lockoutDurationMinutes = 5;

  final FlutterSecureStorage? _secureStorage;
  final SharedPreferences _prefs;
  final bool _useSecureStorage;

  PinAuthService({
    FlutterSecureStorage? secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs,
        _useSecureStorage = !Platform.isMacOS; // Use SharedPreferences on macOS for development

  /// Initialize the service
  static Future<PinAuthService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return PinAuthService(prefs: prefs);
  }

  /// Hash the PIN using SHA-256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if PIN is set
  Future<bool> isPinSet() async {
    return _prefs.getBool(_pinSetKey) ?? false;
  }

  /// Set up a new PIN
  Future<bool> setupPin(String pin) async {
    if (pin.length != 4 || !_isNumeric(pin)) {
      return false;
    }

    final hashedPin = _hashPin(pin);
    if (_useSecureStorage && _secureStorage != null) {
      await _secureStorage!.write(key: _pinKey, value: hashedPin);
    } else {
      await _prefs.setString(_pinKey, hashedPin);
    }
    await _prefs.setBool(_pinSetKey, true);
    await _resetAttempts();
    return true;
  }

  /// Verify the PIN
  Future<bool> verifyPin(String pin) async {
    // Check if locked out
    if (await _isLockedOut()) {
      return false;
    }

    final storedHash = _useSecureStorage && _secureStorage != null
        ? await _secureStorage!.read(key: _pinKey)
        : _prefs.getString(_pinKey);
    if (storedHash == null) {
      return false;
    }

    final inputHash = _hashPin(pin);
    final isValid = storedHash == inputHash;

    if (isValid) {
      await _resetAttempts();
    } else {
      await _incrementAttempts();
    }

    return isValid;
  }

  /// Change the PIN (requires old PIN verification)
  Future<bool> changePin(String oldPin, String newPin) async {
    if (newPin.length != 4 || !_isNumeric(newPin)) {
      return false;
    }

    final isOldPinValid = await verifyPin(oldPin);
    if (!isOldPinValid) {
      return false;
    }

    return await setupPin(newPin);
  }

  /// Reset PIN (for admin/recovery purposes)
  Future<void> resetPin() async {
    if (_useSecureStorage && _secureStorage != null) {
      await _secureStorage!.delete(key: _pinKey);
    } else {
      await _prefs.remove(_pinKey);
    }
    await _prefs.setBool(_pinSetKey, false);
    await _resetAttempts();
  }

  /// Get remaining attempts
  Future<int> getRemainingAttempts() async {
    final attempts = _prefs.getInt(_maxAttemptsKey) ?? 0;
    return _maxAttempts - attempts;
  }

  /// Check if account is locked out
  Future<bool> _isLockedOut() async {
    final lockoutTime = _prefs.getInt(_lockoutTimeKey);
    if (lockoutTime == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lockoutEnd = lockoutTime + (_lockoutDurationMinutes * 60 * 1000);

    if (now < lockoutEnd) {
      return true;
    } else {
      // Lockout period expired, reset
      await _resetAttempts();
      return false;
    }
  }

  /// Get lockout remaining time in seconds
  Future<int> getLockoutRemainingSeconds() async {
    final lockoutTime = _prefs.getInt(_lockoutTimeKey);
    if (lockoutTime == null) return 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lockoutEnd = lockoutTime + (_lockoutDurationMinutes * 60 * 1000);
    final remaining = lockoutEnd - now;

    return remaining > 0 ? (remaining / 1000).ceil() : 0;
  }

  /// Increment failed attempts
  Future<void> _incrementAttempts() async {
    final attempts = (_prefs.getInt(_maxAttemptsKey) ?? 0) + 1;
    await _prefs.setInt(_maxAttemptsKey, attempts);

    if (attempts >= _maxAttempts) {
      // Lock out the user
      await _prefs.setInt(
        _lockoutTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  /// Reset failed attempts
  Future<void> _resetAttempts() async {
    await _prefs.remove(_maxAttemptsKey);
    await _prefs.remove(_lockoutTimeKey);
  }

  /// Check if string is numeric
  bool _isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  /// Clear all data (for testing/debugging)
  Future<void> clearAll() async {
    if (_useSecureStorage && _secureStorage != null) {
      await _secureStorage!.deleteAll();
    }
    await _prefs.clear();
  }
}
