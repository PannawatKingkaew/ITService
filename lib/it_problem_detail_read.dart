// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

// Local pages
import 'it_dashboard.dart';
import 'it_problem_list.dart';
import 'chat_list.dart';
import 'login_page.dart';

// Utils
import 'utils/protected_page.dart';

class ITProblemDetailRead extends ProtectedPage {
  final String id;

  const ITProblemDetailRead({super.key, required this.id});

  @override
  State<ITProblemDetailRead> createState() => _ITProblemDetailReadState();
}

class _ITProblemDetailReadState extends ProtectedState<ITProblemDetailRead> {
  bool isLoading = true;

  List<Map<String, dynamic>> problemDatas = [];

  static const String _imageBaseUrl =
      "https://digitapp.rajavithi.go.th/ITService_API/storage/problem_images/";

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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(context, size),
          ),
          _buildFooter(context, size),
        ],
      ),
    );
  }

  // -------------------------------- HEADER -------------------------------- //

  Widget _buildHeader(BuildContext context, Size size) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Container(
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
              "หน้ารายการปัญหา",
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
            left: size.width * 0.01,
            child: IconButton(
              icon: Image.asset(
                'assets/img/left_arrow.png',
                width: size.height * 0.02,
                height: size.height * 0.02,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ITProblemList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------- BODY -------------------------------- //

  Widget _buildBody(BuildContext context, Size size) {
    final detail = problemDatas.isNotEmpty ? problemDatas.first : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          Expanded(
            child: Container(
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("ข้อมูลผู้ใช้งาน"),
                    _summaryRow(
                      "ชื่อ",
                      detail?['created_by_username'] ?? "-",
                      highlight: true,
                    ),
                    _spacer(size),
                    _summaryRow(
                      "หน่วยงาน",
                      detail?['company'] ?? "-",
                      highlight: true,
                    ),
                    _spacer(size),
                    _summaryRow(
                      "เบอร์ติดต่อ",
                      detail?['problem_callnumber'] ?? "-",
                      highlight: true,
                    ),
                    Divider(color: Colors.grey[300], height: 30),

                    _sectionTitle("รายละเอียดปัญหา"),
                    _spacer(size),
                    _summaryRow(
                      "ปัญหา",
                      detail?['problem_subtypename'] ?? "-",
                      highlight: true,
                    ),
                    _spacer(size),
                    _summaryRow(
                      "ความเร็ว",
                      detail?['problem_speed'] ?? "-",
                      highlight: true,
                    ),
                    _spacer(size),
                    _summaryRow(
                      "อธิบายเพิ่มเติม",
                      detail?['problem_description'] ?? "-",
                      highlight: true,
                    ),
                    _spacer(size),
                    _summaryRow(
                      "สถานะ",
                      detail?['problem_status'] ?? "-",
                      highlight: true,
                    ),
                    _spacer(size),
                    _summaryRow(
                      "ผู้รับผิดชอบ",
                      detail?['staff_username'] ?? "-",
                      highlight: true,
                    ),
                    Divider(color: Colors.grey[300], height: 30),

                    _sectionTitle("รูปภาพประกอบ"),
                    _spacer(size),
                    detail?['image1'] != null
                        ? _buildCachedImage(detail!['image1'])
                        : _buildEmptyImage(),
                    if (detail?['image2'] != null) ...[
                      _spacer(size),
                      _buildCachedImage(detail!['image2']),
                    ],
                    Divider(color: Colors.grey[300], height: 30),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
        ],
      ),
    );
  }

  // -------------------------------- IMAGE -------------------------------- //

  Widget _buildCachedImage(String imageName) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: "$_imageBaseUrl$imageName",
        width: double.infinity,
        fit: BoxFit.fitWidth, // ✅ auto height
        placeholder: (_, __) => Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 200, // ✅ prevents collapse
          ),
          color: const Color(0xfff0e6ff),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (_, __, ___) => _buildEmptyImage(),
      ),
    );
  }

  Widget _buildEmptyImage() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 180, // looks like an image placeholder
      ),
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

  // -------------------------------- UI HELPERS -------------------------------- //

  Widget _summaryRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
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

  Widget _spacer(Size size) => SizedBox(height: size.height * 0.0075);

  // -------------------------------- ACTION BUTTONS -------------------------------- //

  // -------------------------------- FOOTER -------------------------------- //

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
          _footerIcon(
            context,
            Icons.home,
            "Home",
            () => _nav(context, const ITDashboard()),
          ),
          _footerImage(
            context,
            'assets/img/mail.png',
            "Message",
            () => _nav(context, const ChatListPage()),
          ),
          _footerImage(
            context,
            'assets/img/list.png',
            "List",
            () => _nav(context, const ITProblemList()),
          ),
          _footerIcon(
            context,
            Icons.logout,
            "Logout",
            () => _nav(context, const LoginPage()),
          ),
        ],
      ),
    );
  }

  void _nav(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
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
          Icon(icon, size: size),
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
          Text(
            label,
            style: const TextStyle(fontFamily: "Kanit", fontSize: 12),
          ),
        ],
      ),
    );
  }

  // -------------------------------- API -------------------------------- //

  Future<void> fetchProblemData() async {
    final url = Uri.parse(
      'https://digitapp.rajavithi.go.th/ITService_API/api/get-problemdetail',
    );

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"problemID": widget.id}),
    );

    final data = jsonDecode(res.body);
    setState(() {
      problemDatas = [
        {
          'created_by_username': data['created_by_username'],
          'company': data['company'],
          'problem_callnumber': data['problem_callnumber'],
          'problem_subtypename': data['problem_subtypename'],
          'problem_speed': data['problem_speed'],
          'problem_description': data['problem_description'],
          'problem_status': data['problem_status'],
          'staff_username': data['staff_username'],
          'image1': data['attachment_paths'].isNotEmpty ? data['attachment_paths'][0] : null,
          'image2': data['attachment_paths']?.length > 1
              ? data['attachment_paths'][1]
              : null,
        },
      ];
      isLoading = false;
    });
  }
}
