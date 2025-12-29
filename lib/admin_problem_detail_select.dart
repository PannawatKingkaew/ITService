// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;

// Local pages
import 'admin_dashboard.dart';
import 'admin_problem_detail_edit.dart';
import 'admin_problem_list.dart';
import 'chat_list.dart';
import 'login_page.dart';

// Utils
import 'utils/session_manager.dart';
import 'utils/protected_page.dart';


class AdminProblemDetailSelect extends ProtectedPage {
  final String id;

  const AdminProblemDetailSelect({super.key, required this.id});

  @override
  State<AdminProblemDetailSelect> createState() =>
      _AdminProblemDetailSelectState();
}

class _AdminProblemDetailSelectState extends ProtectedState<AdminProblemDetailSelect> {
  @override
  void initState() {
    super.initState();

    fetchProblemData();
    fetchITList();
  }

  bool isLoading = true;
  List<Map<String, dynamic>> problemDatas = [];
  List<Map<String, dynamic>> itLists = [];

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
              : _buildBody(context, size),
          _buildFooter(context, size),
        ],
      ),
    );
  }

  // -------------------------------------- Header -------------------------------------- //
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------- Content -------------------------------------- //
  Widget _buildBody(BuildContext context, Size size) {
    const Color cardColor = Colors.white;
    final detail = problemDatas.isNotEmpty ? problemDatas[0] : null;
    final createdBy = detail?['created_by_username'] ?? "-";
    final company = detail?['company'] ?? "-";
    final callNumber = detail?['problem_callnumber'] ?? "-";
    final issue = detail?['problem_subtypename'] ?? "-";
    final speed = detail?['problem_speed'] ?? "-";
    final description = detail?['problem_description'] ?? "-";
    final status = detail?['problem_status'] ?? "-";
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
                      _buildDropdownRow(),
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
                      _buildActionButtons(context, size),
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

  // -------------------------------------- Dropdown -------------------------------------- // 
  Map<String, dynamic>? _selectedIT;

  Widget _buildDropdownRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 100,
          child: Text("ผู้รับผิดชอบ", style: _labelStyle),
        ),
        Expanded(
          child: _buildDropdownField(
            "",
            _selectedIT,
            items: itLists,
            searchVisible: false,
            onChanged: (newValue) {
              setState(() => _selectedIT = newValue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    Map<String, dynamic>? value, {
    List<Map<String, dynamic>>? items,
    bool readOnly = false,
    bool searchVisible = true,
    Function(Map<String, dynamic>?)? onChanged,
  }) {
    final double itemHeight = 32;
    final double searchBoxHeight = searchVisible ? 36 : 0;
    final EdgeInsets fieldPadding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 0,
    );
    const double fieldHeight = 28;

    if (readOnly) {
      return Container(
        height: fieldHeight,
        padding: fieldPadding,
        decoration: _inputDecoration(),
        alignment: Alignment.centerLeft,
        child: Text(
          value != null ? value['username'] ?? "" : "",
          style: const TextStyle(fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: fieldHeight,
      child: DropdownSearch<Map<String, dynamic>>(
        items: items ?? [],
        selectedItem: value,
        onChanged: onChanged,

        dropdownBuilder: (context, selectedItem) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            selectedItem?['username'] ?? '',
            style: const TextStyle(fontSize: 13, height: 1.1),
          ),
        ),

        popupProps: PopupProps.menu(
          showSearchBox: searchVisible,
          constraints: BoxConstraints(
            maxHeight:
                (items != null
                        ? (items.length.clamp(1, 4) * itemHeight) +
                              searchBoxHeight
                        : 200)
                    .toDouble(),
          ),

          searchFieldProps: TextFieldProps(
            style: const TextStyle(fontSize: 13, height: 1.1),
            decoration: _searchDecoration(),
          ),

          itemBuilder: (context, item, isSelected) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Text(
              item['username'] ?? "",
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
            ),
          ),
        ),

        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xfff9f9f9),
            contentPadding: fieldPadding,
            border: _outlineBorder(),
            enabledBorder: _outlineBorder(),
            focusedBorder: _outlineBorder(),
          ),
        ),

        dropdownButtonProps: const DropdownButtonProps(
          icon: Icon(Icons.arrow_drop_down, size: 20),
        ),
      ),
    );
  }

  // -------------------------------------- Action Buttons -------------------------------------- //
  Widget _buildActionButtons(BuildContext context, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          context,
          "แก้ไข",
          const Color(0xfffff59d),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminProblemDetailEdit(id: widget.id),
            ),
          ),
        ),
        _buildActionButton(
          context,
          "บันทึก",
          const Color(0xffd0f8ce),
          () async {
            if (_selectedIT == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("กรุณาเลือกเจ้าหน้าที่ก่อน")),
              );
              return;
            }

            final staffId = _selectedIT!['id'];

            await assignStaff(staffId);

            if (!context.mounted) return;
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.40,
        height: MediaQuery.of(context).size.height * 0.045,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xff333333),
            fontFamily: "Kanit",
            fontSize: 14,
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

  Future<void> fetchITList() async {
    try {
      final userData = await SessionManager.getUserData();
      final team = userData['team'];

      final url = Uri.parse('https://digitapp.rajavithi.go.th/ITService_API/api/get-stafflist');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"category": team}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load problem data');
      }
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        itLists = data.map((item) {
          return {
            'id': item['userid'],
            'username': item['username'],
            'company': item['company'] ?? '', 
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching problem data: $e');
    }
  }

  Future<void> assignStaff(String staffId) async {
    try {
      final assignStaffUrl = Uri.parse('https://digitapp.rajavithi.go.th/ITService_API/api/assignStaff');
      final sendMessageUrl = Uri.parse(
        'https://digitapp.rajavithi.go.th/ITService_API/api/sendMessageAssign',
      );
      final getStaffNameUrl = Uri.parse(
        'https://digitapp.rajavithi.go.th/ITService_API/api/get-staffname',
      );

      // -----------------------------------
      // 1) Get staff name
      // -----------------------------------
      final staffResponse = await http.post(
        getStaffNameUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"staffid": staffId}),
      );

      if (staffResponse.statusCode != 200) {
        debugPrint("❌ Failed to get staff name");
        return; 
      }

      dynamic staffData;
      try {
        staffData = jsonDecode(staffResponse.body);
      } catch (e) {
        debugPrint("❌ JSON decode error on staff name");
        return;
      }

      final String staffName = staffData["username"] ?? "";

      // -----------------------------------
      // 2) Send chat message
      // -----------------------------------
      final String messageText =
          "รายการปัญหานี้ถูกมอบให้กับ $staffName ในเวลา ${DateTime.now()}";

      final chatResponse = await http.post(
        sendMessageUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "problemID": widget.id,
          "staffid": staffId,
          "message": messageText,
        }),
      );

      if (chatResponse.statusCode != 200) {
        debugPrint("❌ Failed to send chat message");
        return; 
      }

      // -----------------------------------
      // 3) Assign staff
      // -----------------------------------
      final assignResponse = await http.post(
        assignStaffUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"problemID": widget.id, "staffid": staffId}),
      );

      if (assignResponse.statusCode != 200) {
        debugPrint("❌ Failed to assign staff");
        return;
      }

      debugPrint("✔ Staff assigned successfully");
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error assign staff: $e');
    }
  }


  // -------------------------------------- Utilities -------------------------------------- //

  OutlineInputBorder _outlineBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.black12),
  );

  InputDecoration _searchDecoration() => InputDecoration(
    hintText: 'ค้นหา...',
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    border: _outlineBorder(),
    enabledBorder: _outlineBorder(),
    focusedBorder: _outlineBorder(),
    isDense: true,
  );

  BoxDecoration _inputDecoration() => BoxDecoration(
    color: const Color(0xfff9f9f9),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.black12),
  );

  static const _labelStyle = TextStyle(
    color: Color(0xff333333),
    fontWeight: FontWeight.w400,
    fontFamily: "Kanit",
    fontSize: 14.0,
  );
}
