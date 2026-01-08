// Dart
import 'dart:convert';
import 'dart:io';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Local pages
import 'chat_list.dart';
import 'login_page.dart';
import 'user_dashboard.dart';
import 'user_problem_list.dart';
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
  String adUser = "";
  String? username;
  String? department;
  String? usertype;

  late final TextEditingController adNumberController;

  // ---------- CONSTANT COLORS (NO UI CHANGE) ----------
  static const Color primaryColor = Color(0xFFC23B85);
  static const Color accentColor = Color(0xFFAD3A77);
  static const Color backgroundColor = Color(0xFFFDE6EF);
  static const Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    adNumberController = TextEditingController();
    _loadUserSession();
  }

  @override
  void dispose() {
    adNumberController.dispose();
    super.dispose();
  }

  // ---------------- BUILD ----------------
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
              _buildImagePreview(),
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
                    () => Navigator.pop(context),
                  ),
                  _actionButton(
                    context,
                    size,
                    "ยืนยันปัญหา",
                    const Color(0xffe6ffd6),
                    () => submitProblem(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (widget.image == null) {
      return Container(
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
              style: TextStyle(fontFamily: "Kanit", fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        widget.image!,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        cacheWidth: 800, // ⭐ performance critical
      ),
    );
  }

  Future<File> convertToJpeg(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(
      tempDir.path,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      format: CompressFormat.jpeg,
      quality: 85,
    );

    if (result == null) {
      throw Exception('Image conversion failed');
    }

    return File(result.path);
  }

  //---------------------- Submit Problem ----------------------//
  Future<void> submitProblem(BuildContext context) async {
    final saveProblemUrl = Uri.parse(
      "https://digitapp.rajavithi.go.th/ITService_API/api/save-problem",
    );
    final saveSubtypeUrl = Uri.parse(
      "https://digitapp.rajavithi.go.th/ITService_API/api/save-problemsubtype",
    );

    String finalProblemID = widget.problemID;

    // ---------------- SAVE NEW SUBTYPE ----------------
    if (finalProblemID == 'null' || finalProblemID.startsWith('new:')) {
      try {
        final response = await http.post(
          saveSubtypeUrl,
          body: {
            'category': widget.category,
            'problem_name': widget.problemName,
          },
        );

        if (response.statusCode == 200) {
          finalProblemID =
              jsonDecode(response.body)['id']?.toString() ?? finalProblemID;
        }
      } catch (_) {}
    }

    // ---------------- PAYLOAD ----------------
    final payload = {
      'ad': adUser,
      'name': widget.name,
      'company': widget.company,
      'phone': widget.phone,
      'category': widget.category,
      'problemName': widget.problemName,
      'problemID': finalProblemID,
      'priority': widget.priority,
      'description': widget.description,
      'location': widget.location,
    };

    try {
      http.Response response;

      // ---------------- NO IMAGE ----------------
      if (widget.image == null) {
        response = await http.post(
          saveProblemUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'data': payload}),
        );
      } else {
        // 🔥 แปลง HEIF / HEIC → JPG ก่อนส่ง
        final jpegFile = await convertToJpeg(widget.image!);

        final request = http.MultipartRequest("POST", saveProblemUrl);

        // backend เดิม: รับ JSON ใน field "data"
        request.fields['data'] = jsonEncode(payload);

        // ส่งเฉพาะ JPG เท่านั้น (backend รับชัวร์)
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            jpegFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        final streamed = await request.send();
        response = await http.Response.fromStream(streamed);
      }

      if (!context.mounted) return;

      // ---------------- RESULT ----------------
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserProblemResultMessage()),
        );
      } else {
        _showError(context, response.body);
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, e.toString());
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: "Kanit")),
        backgroundColor: Colors.red,
      ),
    );
  }

  //---------------------- Session ----------------------//
  Future<void> _loadUserSession() async {
    final userData = await SessionManager.getUserData();
    if (!mounted) return;

    if (!(userData['isLoggedIn'] ?? false)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    setState(() {
      adUser = userData['userid'];
      username = userData['username'];
      department = userData['department'];
      usertype = userData['usertype'];
      adNumberController.text = adUser;
    });
  }

  // ---------------- FOOTER (UNCHANGED) ----------------
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

  //---------------------- UI Helpers ----------------------//
  Widget _sectionTitle(String title) => Padding(
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
}
