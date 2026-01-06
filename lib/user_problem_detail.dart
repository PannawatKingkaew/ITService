// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

// Local pages
import 'chat_list.dart';
import 'login_page.dart';
import 'user_dashboard.dart';
import 'user_problem_evaluate.dart';
import 'user_problem_list.dart';

// Utils
import 'utils/protected_page.dart';

class UserProblemDetail extends ProtectedPage {
  final String id;
  const UserProblemDetail({super.key, required this.id});

  @override
  State<UserProblemDetail> createState() => _UserProblemDetailState();
}

class _UserProblemDetailState extends ProtectedState<UserProblemDetail> {
  List<Map<String, dynamic>> problemDatas = [];
  bool isLoading = true;

  // ---------- Constants ----------
  static const Color backgroundColor = Color(0xFFFDE6EF);
  static const Color primaryColor = Color(0xFFC23B85);

  static const BoxDecoration headerDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFAD3A77), Color(0xFFC23B85)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
    ],
  );

  static const BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  @override
  void initState() {
    super.initState();
    fetchProblemData();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double headerHeight = size.height * 0.06;
    final double footerHeight = size.height * 0.07;
    final double imageHeight = size.height * 0.25;
    final double spacer = size.height * 0.0075;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildHeader(context, size, headerHeight),
          isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildBody(context, size, imageHeight, spacer),
          _buildFooter(context, footerHeight),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context, Size size, double height) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: height,
            alignment: Alignment.center,
            decoration: headerDecoration,
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
            left: size.width * 0.005,
            child: IconButton(
              icon: Image.asset(
                'assets/img/left_arrow.png',
                width: size.height * 0.025,
                height: size.height * 0.025,
                gaplessPlayback: true,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserDashboard()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- BODY ----------------
  Widget _buildBody(
    BuildContext context,
    Size size,
    double imageHeight,
    double spacer,
  ) {
    final detail = problemDatas.first;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.02),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: cardDecoration,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("ข้อมูลผู้ใช้งาน"),
                      _summaryRow("ชื่อ", detail['created_by_username'], true),
                      SizedBox(height: spacer),
                      _summaryRow("หน่วยงาน", detail['company'], true),
                      SizedBox(height: spacer),
                      _summaryRow(
                        "เบอร์ติดต่อ",
                        detail['problem_callnumber'],
                        true,
                      ),
                      Divider(color: Colors.grey[300], height: 30),

                      _sectionTitle("รายละเอียดปัญหา"),
                      _summaryRow("ปัญหา", detail['problem_subtypename'], true),
                      SizedBox(height: spacer),
                      _summaryRow("ความเร็ว", detail['problem_speed'], true),
                      SizedBox(height: spacer),
                      _summaryRow(
                        "อธิบายเพิ่มเติม",
                        detail['problem_description'],
                        true,
                      ),
                      SizedBox(height: spacer),
                      _summaryRow("สถานะ", detail['problem_status'], true),
                      SizedBox(height: spacer),
                      _summaryRow(
                        "ผู้รับผิดชอบ",
                        detail['staff_username'],
                        true,
                      ),
                      Divider(color: Colors.grey[300], height: 30),

                      _sectionTitle("รูปภาพประกอบ"),
                      if (detail['image1'] != null)
                        _buildNetworkImage(detail['image1'], imageHeight)
                      else
                        _buildEmptyImage(imageHeight),

                      if (detail['image2'] != null) ...[
                        SizedBox(height: spacer),
                        _buildNetworkImage(detail['image2'], imageHeight),
                      ],

                      Divider(color: Colors.grey[300], height: 30),
                      _buildActionButtons(context),
                    ],
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

  Widget _actionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: "Kanit",
            fontSize: 14,
            color: Color(0xff333333),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final detail = problemDatas.isNotEmpty ? problemDatas[0] : null;
    final status = detail?['problem_status'] ?? "-";
    final issue = detail?['problem_subtypename'] ?? "-";
    final id = detail?['id'] ?? "-";

    List<Widget> buttons = [];

    if (status == "รอดำเนินการ" || status == "รอตรวจสอบ") {
      buttons.add(
        _actionButton(
          context,
          "ยกเลิกปัญหา",
          const Color(0xFFFF9E9E),
          () async {
            await markProblemAsCanceled();
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserProblemList()),
            );
          },
        ),
      );
    } else if (status == "รอประเมิน") {
      buttons.add(
        _actionButton(
          context,
          "ประเมินความพึงพอใจ",
          const Color(0xffe6ffd6),
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    UserProblemEvaluate(id: id, issue: issue, status: status),
              ),
            );
          },
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttons
            .map(
              (btn) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: btn,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildNetworkImage(String imageName, double height) {
    return RepaintBoundary(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xfff0e6ff),
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              "https://digitapp.rajavithi.go.th/ITService_API/storage/problem_images/$imageName",
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyImage(double height) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xfff0e6ff),
      ),
      child: const Text(
        "ไม่มีรูปภาพแนบมา",
        style: TextStyle(
          fontFamily: "Kanit",
          fontSize: 16,
          color: Color(0xff333333),
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: "Kanit",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool highlight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
                  color: highlight ? primaryColor : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- NETWORK ----------------
  Future<void> fetchProblemData() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/get-problemdetail',
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"problemID": widget.id}),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);
      final attachments = data['attachment_paths'] ?? [];

      setState(() {
        problemDatas = [
          {
            'id': data['problem_id'],
            'created_by_username': data['created_by_username'] ?? "-",
            'company': data['company'] ?? "-",
            'problem_callnumber': data['problem_callnumber'] ?? "-",
            'problem_subtypename': data['problem_subtypename'] ?? "-",
            'problem_speed': data['problem_speed'] ?? "-",
            'problem_description': data['problem_description'] ?? "-",
            'problem_status': data['problem_status'] ?? "-",
            'staff_username': data['staff_username'] ?? "-",
            'image1': attachments.isNotEmpty ? attachments[0] : null,
            'image2': attachments.length > 1 ? attachments[1] : null,
          },
        ];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> markProblemAsCanceled() async {
    await http.post(
      Uri.parse(
        'https://digitapp.rajavithi.go.th/ITService_API/api/markProblemAsCanceled',
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"problemID": widget.id}),
    );
  }

  // ---------------- FOOTER ----------------
  Widget _buildFooter(BuildContext context, double height) {
    final double iconSize = MediaQuery.of(context).size.height * 0.03;

    return Container(
      height: height,
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
          _footerIcon(Icons.home, "Home", iconSize, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserDashboard()),
            );
          }),
          _footerImage('assets/img/mail.png', "Message", iconSize, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListPage()),
            );
          }),
          _footerImage('assets/img/list.png', "List", iconSize, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserProblemList()),
            );
          }),
          _footerIcon(Icons.logout, "Logout", iconSize, () {
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
    IconData icon,
    String label,
    double size,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: size),
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
          Image.asset(path, width: size, height: size, gaplessPlayback: true),
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
