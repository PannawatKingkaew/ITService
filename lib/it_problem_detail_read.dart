// Flutter
import 'package:flutter/material.dart';

// Packages
import 'it_dashboard.dart';

// Local pages
import 'chat_list.dart';
import 'it_problem_list.dart';
import 'login_page.dart';

// Utils
import 'utils/protected_page.dart';


class ITProblemDetailRead extends ProtectedPage {
  const ITProblemDetailRead({super.key});

  @override
  State<ITProblemDetailRead> createState() => _ITProblemDetailReadState();
}

class _ITProblemDetailReadState extends ProtectedState<ITProblemDetailRead> {
  static const Color _backgroundColor = Color(0xFFFDE6EF);
  static const Color _cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Column(
        children: [
          _buildHeader(size, context),
          _buildContent(size, context),
          _buildFooter(context, size), 
        ],
      ),
    );
  }

  //-------------------------------------- Header --------------------------------------//
  Widget _buildHeader(Size size, BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: size.height * 0.06,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFAD3A77), Color(0xFFC23B85)],
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
              "รายละเอียดปัญหา",
              style: TextStyle(
                fontFamily: "Kanit",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.005,
            left: 10,
            child: IconButton(
              icon: Image.asset(
                'assets/img/left_arrow.png',
                width: size.height * 0.025,
                height: size.height * 0.025,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  //-------------------------------------- Content --------------------------------------//
  Widget _buildContent(Size size, BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView(
                  children: [
                    _summaryRow("ชื่อ", "นายโชคดี ไม่มีทรัพย์"),
                    SizedBox(height: size.height * 0.015),
                    _summaryRow("หน่วยงาน", "ศูนย์การจัดการความรู้ (KM)"),
                    SizedBox(height: size.height * 0.015),
                    _summaryRow("เบอร์ติดต่อ", "00000", highlight: true),
                    SizedBox(height: size.height * 0.015),
                    _summaryRow("ปัญหา", "Internet ช้า", highlight: true),
                    SizedBox(height: size.height * 0.015),
                    _summaryRow("ความเร็ว", "ด่วน", highlight: true),
                    SizedBox(height: size.height * 0.015),
                    _summaryRow("อธิบายเพิ่มเติม", "อินเทอร์เน็ตช้าในชั้น 3"),
                    SizedBox(height: size.height * 0.02),

                    Container(
                      width: double.infinity,
                      height: size.height * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xfff0e6ff),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: size.height * 0.06,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "รูปภาพตัวอย่าง",
                            style: TextStyle(
                              fontFamily: "Kanit",
                              fontSize: 16,
                              color: Color(0xff333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }

  //-------------------------------------- Footer (unchanged) --------------------------------------//


  //-------------------------------------- Helper Widgets --------------------------------------//
  Widget _summaryRow(String label, String value, {bool highlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            "$label :",
            style: const TextStyle(
              fontFamily: "Kanit",
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: highlight
                ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4)
                : null,
            decoration: highlight
                ? BoxDecoration(
                    color: const Color(0xffffe0f0),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: "Kanit",
                fontSize: 14,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                color: highlight ? const Color(0xffc23b85) : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  //---------------------- Footer ----------------------//
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
          _footerIcon(context, Icons.home, "Home", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ITDashboard()),
            );
          }),
          _footerImage(context, 'assets/img/mail.png', "Message", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListPage()),
            );
          }),
          _footerImage(context, 'assets/img/list.png', "List", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ITProblemList()),
            );
          }),
          _footerIcon(context, Icons.logout, "Logout", () {
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
    VoidCallback onTap,
  ) {
    final size = MediaQuery.of(context).size.height * 0.03;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: size, color: Colors.black87),
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
    VoidCallback onTap,
  ) {
    final size = MediaQuery.of(context).size.height * 0.03;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(path, width: size, height: size),
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
