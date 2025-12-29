// Dart
import 'dart:convert';
import 'dart:io';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;
import 'user_problem_list.dart';

// Local pages
import 'chat_list.dart';
import 'login_page.dart';
import 'user_dashboard.dart';
import 'user_problem_result_message.dart';

// Utils
import 'utils/protected_page.dart';
import 'utils/session_manager.dart';

class UserProblemConfirm extends ProtectedPage {
  final String name;
  final String company;
  final String location;
  final String phone;
  final String category;
  final String problemName;
  final String problemID;
  final String priority;
  final String description;
  final File? image;

  const UserProblemConfirm({
    super.key,
    required this.name,
    required this.company,
    required this.location,
    required this.phone,
    required this.category,
    required this.problemName,
    required this.problemID,
    required this.priority,
    required this.description,
    this.image,
  });

  @override
  State<UserProblemConfirm> createState() => _UserProblemConfirmState();
}

class _UserProblemConfirmState extends ProtectedState<UserProblemConfirm> {
  bool isLoading = true;
  String adUser = "";
  String? username;
  String? department;
  String? usertype;
  late final TextEditingController adNumberController;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    adNumberController = TextEditingController(text: adUser);
  }

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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [accentColor, primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Text(
          "ยืนยันข้อมูลปัญหา",
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _sectionTitle("ข้อมูลผู้ใช้งาน"),
              _summaryRow("เลข AD", adNumberController.text),
              _summaryRow("ชื่อ", widget.name),
              _summaryRow("หน่วยงาน", widget.company),
              _summaryRow("สถานที่", widget.location),
              _summaryRow("เบอร์ติดต่อ", widget.phone, highlight: true),
              Divider(color: Colors.grey[300], height: 30),

              _sectionTitle("รายละเอียดปัญหา"),
              _summaryRow("หมวดหมู่", widget.category),
              _summaryRow("ปัญหา", widget.problemName, highlight: true),
              _summaryRow("ความเร็ว", widget.priority, highlight: true),
              _summaryRow("อธิบายเพิ่มเติม", widget.description),
              Divider(color: Colors.grey[300], height: 30),

              _sectionTitle("รูปภาพประกอบ"),
              if (widget.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    widget.image!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xfff0e6ff),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 60, color: Colors.grey[600]),
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
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionButton(
                    context,
                    size,
                    "ยกเลิก",
                    const Color(0xffffe0f0),
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserDashboard(),
                        ),
                      );
                    },
                  ),
                  _actionButton(
                    context,
                    size,
                    "แก้ไข",
                    const Color(0xffd6f5ff),
                    () {
                      Navigator.pop(context);
                    },
                  ),
                  _actionButton(
                    context,
                    size,
                    "ยืนยันปัญหา",
                    const Color(0xffe6ffd6),
                    () {
                      submitProblem(context); 
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //---------------------- Helper Widgets ----------------------//
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 5),
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

  Widget _actionButton(
    BuildContext context,
    Size size,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width * 0.25,
        height: size.height * 0.05,
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

  //---------------------- Submit Problem ----------------------//
  Future<void> submitProblem(BuildContext context) async {
    final saveProblemUrl = Uri.parse("https://digitapp.rajavithi.go.th/ITService_API/api/save-problem");
    final saveSubtypeUrl = Uri.parse(
      "https://digitapp.rajavithi.go.th/ITService_API/api/save-problemsubtype",
    );

    String? problemID = widget.problemID;

    if (widget.problemID == 'null' || widget.problemID.startsWith('new:')) {
      try {
        final checkResponse = await http.post(
          saveSubtypeUrl,
          body: {
            'category': widget.category,
            'problem_name': widget.problemName,
          },
        );

        if (checkResponse.statusCode == 200) {
          final data = jsonDecode(checkResponse.body);
          problemID = data['id'].toString(); 
        } else {}
      } catch (e) {
        // intentionally ignored
      }
    }

    Map<String, dynamic> data = {
      'ad': adUser,
      'name': widget.name,
      'company': widget.company,
      'phone': widget.phone,
      'category': widget.category,
      'problemName': widget.problemName,
      'problemID': problemID, 
      'priority': widget.priority,
      'description': widget.description,
      'location': widget.location,
    };

    try {
      http.Response response;

      if (widget.image == null) {
        response = await http.post(
          saveProblemUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'data': data}),
        );
      } else {
        var request = http.MultipartRequest("POST", saveProblemUrl);
        request.fields['data'] = jsonEncode(data);
        request.files.add(
          await http.MultipartFile.fromPath("image", widget.image!.path),
        );

        var streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      }

      if (response.statusCode == 200) {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserProblemResultMessage()),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ผิดพลาด: ${response.body}",
              style: const TextStyle(fontFamily: "Kanit"),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "ข้อผิดพลาด: $e",
            style: const TextStyle(fontFamily: "Kanit"),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Future<void> _loadUserSession() async {
    final userData = await SessionManager.getUserData();
    if (!mounted) return;

    if (!(userData['isLoggedIn'] ?? false)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      setState(() {
        adUser = userData['userid'];
        username = userData['username'];
        department = userData['department'];
        usertype = userData['usertype'];

        adNumberController.text = adUser;
        isLoading = false;
      });
    }
  }
}
