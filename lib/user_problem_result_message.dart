import 'package:flutter/material.dart';
import 'user_problem_list.dart';
import 'chat_list.dart';
import 'login_page.dart';
import 'user_dashboard.dart';
import 'utils/protected_page.dart';

class UserProblemResultMessage extends ProtectedPage {
  const UserProblemResultMessage({super.key});

  @override
  State<UserProblemResultMessage> createState() =>
      _UserProblemResultMessageState();
}

class _UserProblemResultMessageState
    extends ProtectedState<UserProblemResultMessage> {
  // ---------- Constants (compile-time) ----------
  static const Color primaryColor = Color(0xFFC23B85);
  static const Color accentColor = Color(0xFFAD3A77);
  static const Color backgroundColor = Color(0xFFFDE6EF);
  static const Color cardColor = Colors.white;

  static const BoxDecoration headerDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [accentColor, primaryColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );

  static const BoxDecoration footerDecoration = BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 4,
        offset: Offset(0, -2),
      ),
    ],
  );

  static const BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double headerHeight = size.height * 0.06;
    final double footerHeight = size.height * 0.07;
    final double cardHeight = size.height * 0.25;
    final double iconSize = size.height * 0.03;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildHeader(headerHeight),
          _buildContent(cardHeight),
          _buildFooter(context, footerHeight, iconSize),
        ],
      ),
    );
  }

  //---------------------- Header ----------------------//
  Widget _buildHeader(double height) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        width: double.infinity,
        height: height,
        alignment: Alignment.center,
        decoration: headerDecoration,
        child: const Text(
          "แจ้งการบันทึกปัญหา",
          style: TextStyle(
            fontFamily: "Kanit",
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  //---------------------- Content ----------------------//
  Widget _buildContent(double cardHeight) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: cardHeight,
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: cardDecoration,
                child: const Center(
                  child: Text(
                    "บันทึกปัญหาที่พบเรียบร้อย\nกรุณารอเจ้าหน้าที่แก้ไขหรือติดต่อกลับ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Kanit",
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  //---------------------- Footer ----------------------//
  Widget _buildFooter(
    BuildContext context,
    double height,
    double iconSize,
  ) {
    return Container(
      height: height,
      decoration: footerDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerIcon(
            Icons.home,
            "Home",
            iconSize,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserDashboard()),
            ),
          ),
          _footerImage(
            'assets/img/mail.png',
            "Message",
            iconSize,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListPage()),
            ),
          ),
          _footerImage(
            'assets/img/list.png',
            "List",
            iconSize,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserProblemList()),
            ),
          ),
          _footerIcon(
            Icons.logout,
            "Logout",
            iconSize,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerIcon(
    IconData icon,
    String label,
    double iconSize,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: Colors.black87),
          const SizedBox(height: 2),
          const Text(
            '',
            style: TextStyle(fontSize: 0),
          ),
          Text(
            label,
            style: const TextStyle(fontFamily: "Kanit", fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _footerImage(
    String path,
    String label,
    double size,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            path,
            width: size,
            height: size,
            gaplessPlayback: true,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontFamily: "Kanit", fontSize: 12),
          ),
        ],
      ),
    );
  }
}
