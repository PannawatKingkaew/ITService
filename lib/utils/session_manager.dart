import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // ================= CONFIG ================= //
  static const Duration sessionTimeout = Duration(minutes: 30);

  // จำกัดความถี่ในการเขียน lastActiveTime
  static const Duration activityThrottle = Duration(seconds: 10);

  static int _lastWriteTime = 0;

  // ================= SAVE SESSION ================= //
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userid', user['userid'] ?? '');
    await prefs.setString('username', user['username'] ?? '');
    await prefs.setString('department', user['department'] ?? '');
    await prefs.setString('company', user['company'] ?? '');
    await prefs.setString('team', user['team'] ?? '');
    await prefs.setString('usertype', user['usertype'] ?? '');

    await _updateLastActiveTime(force: true);
  }

  // ================= GET SESSION ================= //
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final lastActiveTime = prefs.getInt('lastActiveTime') ?? 0;

    if (isLoggedIn && _isSessionExpired(lastActiveTime)) {
      await clearSession();
      return _emptySession();
    }

    if (isLoggedIn) {
      await updateActivity();
    }

    return {
      'isLoggedIn': isLoggedIn,
      'userid': prefs.getString('userid') ?? '',
      'username': prefs.getString('username') ?? '',
      'department': prefs.getString('department') ?? '',
      'company': prefs.getString('company') ?? '',
      'team': prefs.getString('team') ?? '',
      'usertype': prefs.getString('usertype') ?? '',
    };
  }

  // ================= CHECK VALID ================= //
  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final lastActiveTime = prefs.getInt('lastActiveTime') ?? 0;

    if (!isLoggedIn) return false;

    if (_isSessionExpired(lastActiveTime)) {
      await clearSession();
      return false;
    }

    await updateActivity();
    return true;
  }

  // ================= ACTIVITY ================= //
  static Future<void> updateActivity() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // throttle การเขียน
    if (now - _lastWriteTime < activityThrottle.inMilliseconds) {
      return;
    }

    _lastWriteTime = now;
    await _updateLastActiveTime();
  }

  // ================= CLEAR ================= //
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ================= HELPERS ================= //
  static Future<void> _updateLastActiveTime({bool force = false}) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (!force && now - _lastWriteTime < activityThrottle.inMilliseconds) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastActiveTime', now);
    _lastWriteTime = now;
  }

  static bool _isSessionExpired(int lastActiveTime) {
    final now = DateTime.now();
    final lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveTime);

    return now.difference(lastActive) >= sessionTimeout;
  }

  static Map<String, dynamic> _emptySession() {
    return {
      'isLoggedIn': false,
      'userid': '',
      'username': '',
      'department': '',
      'company': '',
      'team': '',
      'usertype': '',
    };
  }
}
