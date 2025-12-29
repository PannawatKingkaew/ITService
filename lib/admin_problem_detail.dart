// Flutter
import 'package:flutter/material.dart';

// Local pages
import 'admin_dashboard.dart';
import 'admin_problem_list.dart';
import 'chat_list.dart';
import 'login_page.dart';

// Utils
import 'utils/protected_page.dart';

class AdminProblemDetail extends ProtectedPage {
  final String id;
  final String issue;
  final String status;

  const AdminProblemDetail({
    super.key,
    required this.id,
    required this.issue,
    required this.status,
  });

  @override
  State<AdminProblemDetail> createState() => _AdminProblemDetailState();
}

class _AdminProblemDetailState extends ProtectedState<AdminProblemDetail> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE6EF),
      body: Column(
        children: [
          _buildHeader(size, context),
          _buildContent(size, context),
          _buildFooter(context, size),
        ],
      ),
    );
  }

  // ---------------- HEADER ---------------- //
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
            left: 0,
            child: IconButton(
              icon: Image.asset(
                'assets/img/left_arrow.png',
                width: size.height * 0.025,
                height: size.height * 0.025,
              ),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- CONTENT ---------------- //
  Widget _buildContent(Size size, BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            _gap(size.height * 0.02),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryRow("ชื่อ", "นายโชคดี ไม่มีทรัพย์"),
                    _gap(size.height * 0.0075),
                    _summaryRow("หน่วยงาน", "ศูนย์การจัดการความรู้ (KM)"),
                    _gap(size.height * 0.0075),
                    _summaryRow("เบอร์ติดต่อ", "00000"),
                    _gap(size.height * 0.0075),
                    _summaryRow("ปัญหา", "Internet ช้า"),
                    _gap(size.height * 0.0075),
                    _summaryRow("ความเร็ว", "ด่วน"),
                    _gap(size.height * 0.0075),
                    _summaryRow("อธิบายเพิ่มเติม", "อินเทอร์เน็ตช้าในชั้น 3"),
                    _gap(size.height * 0.02),

                    Container(
                      width: double.infinity,
                      height: size.height * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xfff0e6ff),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "รูปภาพตัวอย่าง",
                        style: TextStyle(
                          fontFamily: "Kanit",
                          fontSize: 16,
                          color: Color(0xff333333),
                        ),
                      ),
                    ),

                    _gap(size.height * 0.22),
                  ],
                ),
              ),
            ),
            _gap(size.height * 0.02),
          ],
        ),
      ),
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
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
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
              MaterialPageRoute(builder: (_) => const AdminProblemList()),
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

  // ---------------- SMALL HELPERS ---------------- //
  Widget _gap(double height) => SizedBox(height: height);

  Widget _summaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text("$label :", style: _labelStyle)),
        Expanded(child: Text(value, style: _valueStyle)),
      ],
    );
  }

  static const _labelStyle = TextStyle(
    fontFamily: "Kanit",
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const _valueStyle = TextStyle(
    fontFamily: "Kanit",
    fontSize: 14,
    color: Color(0xff333333),
  );
}
