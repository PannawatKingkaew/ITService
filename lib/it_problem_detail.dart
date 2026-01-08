// Dart
import 'dart:convert';
import 'dart:io';
// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Local pages
import 'chat_list.dart';
import 'login_page.dart';
import 'it_dashboard.dart';
import 'chat_message.dart';
import 'it_problem_list.dart';

// Utils
import 'utils/session_manager.dart';
import 'utils/protected_page.dart';

class ITProblemDetail extends ProtectedPage {
  final String id;
  const ITProblemDetail({super.key, required this.id});

  @override
  State<ITProblemDetail> createState() => _ITProblemDetailState();
}

class _ITProblemDetailState extends ProtectedState<ITProblemDetail> {
  List<Map<String, dynamic>> problemDatas = [];
  bool isLoading = true;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  static const Color _primaryColor = Color(0xFFC23B85);
  static const Color _accentColor = Color(0xFFAD3A77);
  static const Color _backgroundColor = Color(0xFFFDE6EF);
  static const Color _cardColor = Colors.white;

  static const String _imageBaseUrl =
      "https://digitapp.rajavithi.go.th/ITService_API/storage/problem_images/";

  @override
  void initState() {
    super.initState();
    fetchProblemData();
  }

  Future<void> fetchProblemData() async {
    try {
      final url = Uri.parse(
        'https://digitapp.rajavithi.go.th/ITService_API/api/get-problemdetail',
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"problemID": widget.id}),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      final attachments = data['attachment_paths'] ?? [];

      setState(() {
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
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> markProblemAsInprogress() async {
    try {
      final url = Uri.parse(
        'https://digitapp.rajavithi.go.th/ITService_API/api/markProblemAsInprogress',
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"problemID": widget.id}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to markProblemAsInprogress');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error assign staff: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85, // ช่วยลดขนาด + บางเครื่องแปลงเป็น jpg ให้
    );

    if (picked != null && mounted) {
      setState(() => _image = File(picked.path));
    }
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

  Future<void> markProblemAsEvalueted() async {
    try {
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      final uri = Uri.parse(
        'https://digitapp.rajavithi.go.th/ITService_API/api/markProblemAsEvalueted',
      );

      final request = http.MultipartRequest('POST', uri);

      request.fields['problemID'] = widget.id.toString();
      request.fields['ad_user'] = adUser.toString();

      if (_image != null) {
        // 🔥 จุดสำคัญที่สุด
        final jpegFile = await convertToJpeg(_image!);

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            jpegFile.path, // ✅ เป็น .jpg แล้ว
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to mark as evaluated');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error mark evaluated: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Column(
        children: [
          _buildHeader(size),
          isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildBody(size),
          _buildFooter(context, size),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return SafeArea(
      top: true,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: size.height * 0.06,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_accentColor, _primaryColor],
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ITDashboard()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Size size) {
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
                      _spacer(size),
                      _summaryRow("หน่วยงาน", company, highlight: true),
                      _spacer(size),
                      _summaryRow("เบอร์ติดต่อ", callNumber, highlight: true),
                      Divider(color: Colors.grey[300], height: 30),

                      _sectionTitle("รายละเอียดปัญหา"),
                      _spacer(size),
                      _summaryRow("ปัญหา", issue, highlight: true),
                      _spacer(size),
                      _summaryRow("ความเร็ว", speed, highlight: true),
                      _spacer(size),
                      _summaryRow(
                        "อธิบายเพิ่มเติม",
                        description,
                        highlight: true,
                      ),
                      _spacer(size),
                      _summaryRow("สถานะ", status, highlight: true),
                      _spacer(size),
                      _summaryRow("ผู้รับผิดชอบ", staff, highlight: true),
                      Divider(color: Colors.grey[300], height: 30),

                      _sectionTitle("รูปภาพประกอบ"),
                      _spacer(size),
                      image1 != null
                          ? _buildImageContainer(image1)
                          : _buildEmptyImageContainer(),
                      if (image2 != null) ...[
                        _spacer(size),
                        _buildImageContainer(image2),
                      ],

                      if (status == "กำลังดำเนินการ") ...[
                        _buildImagePicker(size),
                      ],
                      SizedBox(height: size.height * 0.025),

                      Row(
                        children: [
                          if (status != "รอดำเนินการ" &&
                              status != "กำลังดำเนินการ")
                            const Spacer(),

                          _actionButton(
                            context,
                            "ตอบกลับ",
                            const Color(0xFFFFF59D),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatMessagePage(problemId: widget.id),
                                ),
                              );
                            },
                          ),

                          if (status != "รอดำเนินการ" &&
                              status != "กำลังดำเนินการ")
                            const Spacer(),

                          if (status == "รอดำเนินการ") ...[
                            const Spacer(),
                            _actionButton(
                              context,
                              "รับเรื่อง",
                              const Color(0xFFD0F8CE),
                              () async {
                                await markProblemAsInprogress();

                                if (!mounted) return;

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ITDashboard(),
                                  ),
                                );
                              },
                            ),
                          ],

                          if (status == "กำลังดำเนินการ") ...[
                            const Spacer(),
                            _actionButton(
                              context,
                              "เสร็จสิ้น",
                              const Color(0xFFD0F8CE),
                              () async {
                                await markProblemAsEvalueted();

                                if (!mounted) return;

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ITDashboard(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildImageContainer(String? imageName) {
    if (imageName == null) {
      return _buildEmptyImageContainer();
    }

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
      ),
    );
  }

  Widget _buildEmptyImageContainer() {
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

  Widget _spacer(Size size) => SizedBox(height: size.height * 0.0075);

  Widget _actionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width * 0.4,
        height: size.height * 0.045,
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
            fontWeight: FontWeight.w500,
            color: Color(0xff333333),
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

  Widget _buildImagePicker(Size size) {
    return Column(
      children: [
        if (_image == null)
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('เลือกจากเครื่อง'),
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('ถ่ายรูป'),
                        onTap: () {
                          _pickImage(ImageSource.camera);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 192, 225),
            ),
            icon: const Icon(Icons.add_a_photo),
            label: const Text("เพิ่มรูปภาพ"),
          ),
        if (_image != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _image!,
                width: size.width * 0.6,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }
}
