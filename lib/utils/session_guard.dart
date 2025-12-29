import 'package:flutter/material.dart';
import '../login_page.dart';
import 'session_manager.dart';

class SessionGuard {
  static Future<void> checkSessionAndRedirect(
    BuildContext context,
  ) async {
    final isValid = await SessionManager.isSessionValid();

    if (!isValid) {
      await SessionManager.clearSession();

      if (!context.mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Session หมดอายุ'),
          content: const Text(
            'Session ของคุณหมดอายุแล้ว\nกรุณาเข้าสู่ระบบใหม่',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }
}
