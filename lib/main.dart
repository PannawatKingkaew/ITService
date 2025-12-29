// Flutter
import 'package:flutter/material.dart';

// Local pages
import 'home_page.dart';
import 'login_page.dart';

// Utils
import 'utils/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userData = await SessionManager.getUserData();
  final bool isLoggedIn = userData['isLoggedIn'] ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: SessionManager.updateActivity,
      onPanDown: (_) => SessionManager.updateActivity(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isLoggedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }
}
