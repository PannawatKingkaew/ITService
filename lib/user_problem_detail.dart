// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    fetchProblemData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE6EF),
      body: Column(
        children: [
          _buildHeader(context, size),
          isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : _buildBody(context),
          _buildFooter(context, size),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
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
            left: size.width * 0.005,
            child: IconButton(
              icon: Image.asset(
                'assets/img/left_arrow.png',
                width: size.height * 0.025,
                height: size.height * 0.025,
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

  Widget _buildBody(BuildContext context) {
    const Color cardColor = Colors.white;

    final detail = problemDatas.isNotEmpty ? problemDatas[0] : null;

    final createdBy = detail?['created_by_username'] ?? "-";
    final company = detail?['company'] ?? "-";
    final callNumber = detail?['problem_callnumber'] ?? "-";
    final issue = detail?['problem_subtypename'] ?? "-";
    final speed = detail?['problem_speed'] ?? "-";
    final description = detail?['problem_description'] ?? "-";
    final status = detail?['problem_status'] ?? "-";
    final staff = detail?['staff_username'] ?? "-";
    final image1 = detail?['image1'];
    final image2 = detail?['image2'];

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Expanded(
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("ข้อมูลผู้ใช้งาน"),
                      _summaryRow("ชื่อ", createdBy, highlight: true),
                      _spacer(context),
                      _summaryRow("หน่วยงาน", company, highlight: true),
                      _spacer(context),
                      _summaryRow("เบอร์ติดต่อ", callNumber, highlight: true),
                      Divider(color: Colors.grey[300], height: 30),

                      _sectionTitle("รายละเอียดปัญหา"),
                      _spacer(context),
                      _summaryRow("ปัญหา", issue, highlight: true),
                      _spacer(context),
                      _summaryRow("ความเร็ว", speed, highlight: true),
                      _spacer(context),
                      _summaryRow(
                        "อธิบายเพิ่มเติม",
                        description,
                        highlight: true,
                      ),
                      _spacer(context),
                      _summaryRow("สถานะ", status, highlight: true),
                      _spacer(context),
                      _summaryRow("ผู้รับผิดชอบ", staff, highlight: true),
                      Divider(color: Colors.grey[300], height: 30),

                      _sectionTitle("รูปภาพประกอบ"),
                      _spacer(context),
                      if (image1 != null)
                        _buildImageContainer(image1)
                      else
                        _buildEmptyImageContainer(),
                      if (image2 != null) ...[
                        _spacer(context),
                        _buildImageContainer(image2),
                      ],

                      Divider(color: Colors.grey[300], height: 30),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(String imageName) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xfff0e6ff),
        image: DecorationImage(
          image: NetworkImage(
            "https://digitapp.rajavithi.go.th/ITService_API/storage/problem_images/$imageName",
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildEmptyImageContainer() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xfff0e6ff),
      ),
      alignment: Alignment.center,
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

  //-------------------------------------- Helper Widgets --------------------------------------//
  Widget _summaryRow(
    String label,
    String value, {
    bool highlight = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$label :",
              style: TextStyle(
                fontFamily: "Kanit",
                fontSize: fontSize,
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
                  fontSize: fontSize,
                  fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                  color: highlight ? const Color(0xffc23b85) : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _spacer(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.0075);

  //-------------------------------------- Action Buttons --------------------------------------//
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

  //-------------------------------------- Footer Helpers --------------------------------------//
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
              MaterialPageRoute(builder: (_) => const UserDashboard()),
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
              MaterialPageRoute(builder: (_) => const UserProblemList()),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: "Kanit",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFC23B85),
        ),
      ),
    );
  }

  Future<void> fetchProblemData() async {
    try {
      final url = Uri.parse('https://digitapp.rajavithi.go.th/ITService_API/api/get-problemdetail');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"problemID": widget.id}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load problem data');
      }
      final Map<String, dynamic> data = json.decode(response.body);

      setState(() {
        final attachments = data['attachment_paths'] ?? [];

        problemDatas = [
          {
            'id': data['problem_id'],
            'created_by_username': data['created_by_username'],
            'company': data['company'],
            'problem_location': data['problem_location'],
            'problem_callnumber': data['problem_callnumber'],
            'problem_subtypename': data['problem_subtypename'],
            'problem_speed': data['problem_speed'],
            'problem_description': data['problem_description'],
            'problem_status': data['problem_status'],
            'staff_username': data['staff_username'],
            'image1': attachments.isNotEmpty ? attachments[0] : null,
            'image2': attachments.length > 1 ? attachments[1] : null,
          },
        ];

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching problem data: $e');
    }
  }

  Future<void> markProblemAsCanceled() async {
    try {
      final url = Uri.parse('https://digitapp.rajavithi.go.th/ITService_API/api/markProblemAsCanceled');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"problemID": widget.id}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to markProblemAsCanceled');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error assign staff: $e');
    }
  }
}
