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

  static const Color primaryColor = Color(0xFFC23B85);
  static const Color accentColor = Color(0xFFAD3A77);
  static const Color backgroundColor = Color(0xFFFDE6EF);
  static const Color cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildHeader(size),
          _buildContent(size, context),
          _buildFooter(context, size),
        ],
      ),
    );
  }

  //---------------------- Header ----------------------//
  Widget _buildHeader(Size size) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        width: double.infinity,
        height: size.height * 0.06,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
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
        ),
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
  Widget _buildContent(Size size, BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.02),
            SizedBox(
              height: size.height * 0.25,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "บันทึกปัญหาที่พบเรียบร้อย\nกรุณารอเจ้าหน้าที่แก้ไขหรือติดต่อกลับ",
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Kanit",
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }

  //---------------------- Footer Helpers ----------------------//
  Widget _buildFooter(BuildContext context, Size size) {
    return Container(
      height: size.height * 0.07,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerIcon(context, Icons.home, "Home", size, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserDashboard()),
            );
          }),
          _footerImage(context, 'assets/img/mail.png', "Message", size, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListPage()),
            );
          }),
          _footerImage(context, 'assets/img/list.png', "List", size, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserProblemList()),
            );
          }),
          _footerIcon(context, Icons.logout, "Logout", size, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _footerIcon(
    BuildContext context,
    IconData icon,
    String label,
    Size size,
    VoidCallback onTap,
  ) {
    final iconSize = size.height * 0.03;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: Colors.black87),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontFamily: "Kanit", fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _footerImage(
    BuildContext context,
    String path,
    String label,
    Size size,
    VoidCallback onTap,
  ) {
    final imageSize = size.height * 0.03;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(path, width: imageSize, height: imageSize),
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
