// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Local pages
import 'admin_dashboard.dart';
import 'admin_problem_list.dart';
import 'chat_list.dart';
import 'login_page.dart';

// Utils
import 'utils/session_manager.dart';
import 'utils/protected_page.dart';

class AdminProblemDetailEdit extends ProtectedPage {
  final String id;

  const AdminProblemDetailEdit({super.key, required this.id});

  @override
  State<AdminProblemDetailEdit> createState() => _AdminProblemDetailEditState();
}

class ProblemSubTypeList {
  final String id;
  final String name;

  ProblemSubTypeList({required this.id, required this.name});
}

class _AdminProblemDetailEditState
    extends ProtectedState<AdminProblemDetailEdit> {
  final List<String> _priorityOptions = ["ปกติ", "ด่วน", "ด่วนมาก"];
  List<String> problemsTypeList = [];
  List<ProblemSubTypeList> problemsSubTypeList = [];
  List<Map<String, dynamic>> problemDatas = [];
  bool isLoading = true;
  String selectedProblemType = "-";
  String selectedProblemSubType = "-";
  String selectedSpeed = "-";
  bool isNewSubType = false;
  String? selectedSubType;

  static const String _imageBaseUrl =
      "https://digitapp.rajavithi.go.th/ITService_API/storage/problem_images/";

  @override
  void initState() {
    super.initState();
    fetchProblemData().then((_) {
      fetchProblemSubTypeList(); // load subtypes after we have the main type
    });
    fetchProblemTypeList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE6EF),
      body: Column(
        children: [
          _buildHeader(size),
          isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildContent(size),
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

  //---------------------- Content ----------------------//
  Widget _buildContent(Size size) {
    final detail = problemDatas.isNotEmpty ? problemDatas[0] : null;

    // Null-safe dynamic values
    final createdBy = detail?['created_by_username'] ?? "-";
    final company = detail?['company'] ?? "-";
    final callNumber = detail?['problem_callnumber'] ?? "-";

    final description = detail?['problem_description'] ?? "-";

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
                      _summaryRow("ชื่อ", createdBy, highlight: true),
                      _spacer(context),
                      _summaryRow("หน่วยงาน", company, highlight: true),
                      _spacer(context),
                      _summaryRow("เบอร์ติดต่อ", callNumber, highlight: true),
                      Divider(color: Colors.grey[300], height: 30),

                      _sectionTitle("รายละเอียดปัญหา"),
                      _spacer(context),

                      _buildDropdownRow(
                        size: size,
                        label: "หมวดหมู่",
                        value: selectedProblemType,
                        items: problemsTypeList,
                        onChanged: (val) {
                          setState(() {
                            selectedProblemType = val!;
                            selectedProblemSubType = "-";
                          });
                          fetchProblemSubTypeList();
                        },
                      ),
                      _spacer(context),
                      _buildSubTypeDropdown(
                        size: size,
                        label: "ปัญหา",
                        value: selectedProblemSubType,
                        options: problemsSubTypeList,
                        onChanged: (val) {
                          if (val == null) return;

                          final exists = problemsSubTypeList.any(
                            (e) => e.id == val || e.name == val,
                          );

                          if (!exists) {
                            setState(() {
                              final newId = 'new:$val';

                              final newItem = ProblemSubTypeList(
                                id: newId,
                                name: val,
                              );

                              problemsSubTypeList.add(newItem);

                              selectedProblemSubType = newId;
                            });
                          } else {
                            setState(() {
                              selectedProblemSubType = val;
                            });
                          }
                        },
                      ),
                      _spacer(context),
                      _buildDropdownRow(
                        size: size,
                        label: "ความเร็ว",
                        value: selectedSpeed,
                        items: _priorityOptions,
                        onChanged: (val) =>
                            setState(() => selectedSpeed = val!),
                      ),

                      _spacer(context),
                      _summaryRow(
                        "อธิบายเพิ่มเติม",
                        description,
                        highlight: true,
                      ),
                      _spacer(context),

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
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            context,
                            "บันทึก",
                            const Color(0xffd0f8ce),
                            () async {
                              await saveProblemChanges();
                              if (!mounted) return;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminDashboard(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
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

  Widget _buildDropdownRow({
    required Size size,
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool searchable = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 100, child: Text(label, style: _labelStyle)),
        Expanded(
          child: SizedBox(
            height: kDropdownHeight,
            child: DropdownSearch<String>(
              items: items,
              selectedItem: value,
              onChanged: onChanged,
              dropdownBuilder: (context, selectedItem) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  selectedItem ?? '',
                  style: const TextStyle(fontSize: kDropdownFontSize),
                ),
              ),

              popupProps: PopupProps.menu(
                showSearchBox: searchable,
                constraints: const BoxConstraints(maxHeight: 180),

                itemBuilder: (context, item, isSelected) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: kDropdownFontSize,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                ),
              ),

              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xfff9f9f9),
                  contentPadding: kDropdownPadding,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTypeDropdown({
    required Size size,
    required String label,
    required String value,
    required List<ProblemSubTypeList> options,
    required Function(String?) onChanged,
  }) {
    final List<String> names = options.map((e) => e.name).toList();

    final Map<String, String> nameToId = {
      for (var item in options) item.name: item.id,
    };

    final Map<String, String> idToName = {
      for (var item in options) item.id: item.name,
    };

    final String? selectedName = idToName[value];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 100, child: Text(label, style: _labelStyle)),
        Expanded(
          child: SizedBox(
            height: kDropdownHeight,
            child: DropdownSearch<String>(
              items: names,
              selectedItem: selectedName,

              onChanged: (selectedName) {
                if (selectedName == null) return;

                if (nameToId.containsKey(selectedName)) {
                  onChanged(nameToId[selectedName]);
                } else {
                  onChanged(selectedName);
                }
              },

              dropdownBuilder: (context, selectedItem) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  selectedItem ?? '',
                  style: const TextStyle(fontSize: kDropdownFontSize),
                ),
              ),

              popupProps: PopupProps.menu(
                showSearchBox: true,

                searchFieldProps: TextFieldProps(
                  style: const TextStyle(fontSize: kDropdownFontSize),
                  decoration: InputDecoration(
                    hintText: 'ค้นหา...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                  ),
                ),

                emptyBuilder: (context, text) => ListTile(
                  leading: const Icon(Icons.add, color: Colors.blue),
                  title: Text('เพิ่ม "$text" เป็นรายการใหม่'),
                  onTap: () {
                    Navigator.pop(context);
                    onChanged(text);
                  },
                ),

                constraints: const BoxConstraints(maxHeight: 200),

                itemBuilder: (context, item, isSelected) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: kDropdownFontSize,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                ),
              ),

              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xfff9f9f9),
                  contentPadding: kDropdownPadding,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContainer(String imageName) {
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
        errorWidget: (_, __, ___) => _buildEmptyImageContainer(),
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

  static Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width * 0.40,
        height: size.height * 0.045,
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
      final url = Uri.parse(
        'https://digitapp.rajavithi.go.th/ITService_API/api/get-problemdetail',
      );

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
            'problem_typename': data['problem_typename'],
            'problem_typeid': data['problem_typeid'],
            'problem_speed': data['problem_speed'],
            'problem_description': data['problem_description'],
            'problem_status': data['problem_status'],
            'staff_username': data['staff_username'],
            'image1': attachments.isNotEmpty ? attachments[0] : null,
            'image2': attachments.length > 1 ? attachments[1] : null,
          },
        ];
        selectedProblemType = data['problem_typename'] ?? "-";
        selectedProblemSubType = data['problem_typeid'] != null
            ? data['problem_typeid'].toString()
            : "-";
        selectedSpeed = data['problem_speed'] ?? "-";

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching problem data: $e');
    }
  }

  Future<void> fetchProblemTypeList() async {
    if (!mounted) return;
    setState(() => isLoading = false);

    final url = Uri.parse(
      'https://digitapp.rajavithi.go.th/ITService_API/api/get-getProblemTypeList',
    );

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          problemsTypeList = List<String>.from(
            data.map((item) => item['problem_typename'].toString()),
          );
        });
      } else {
        debugPrint('Failed to load problems: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching problems: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchProblemSubTypeList() async {
    if (!mounted) return;
    setState(() => isLoading = false);

    final url = Uri.parse(
      'https://digitapp.rajavithi.go.th/ITService_API/api/get-getProblemSubTypeList',
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"category": selectedProblemType}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          problemsSubTypeList = List<ProblemSubTypeList>.from(
            data.map(
              (item) => ProblemSubTypeList(
                id: item['problem_typeid'].toString(),
                name: item['problem_subtypename'].toString(),
              ),
            ),
          );
        });
      } else {
        debugPrint('Failed to load problems: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching problems: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> saveProblemChanges() async {
    try {
      if (!mounted) return;
      setState(() => isLoading = false);

      // -----------------------------------
      // 0) Get session user
      // -----------------------------------
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      final url = Uri.parse(
        'https://digitapp.rajavithi.go.th/ITService_API/api/saveProblemChanges',
      );
      final sendMessageUrl = Uri.parse(
        'https://digitapp.rajavithi.go.th/ITService_API/api/sendMessageChangeType',
      );

      bool isNewValue = selectedProblemSubType.startsWith('new:');
      String? cleanNewValue = isNewValue
          ? selectedProblemSubType.replaceFirst('new:', '')
          : null;

      // -----------------------------------
      // 1) Save problem changes
      // -----------------------------------
      final body = {
        "problemID": widget.id,
        "subtype_id": isNewValue ? '' : selectedProblemSubType,
        "subtype_new": isNewValue ? cleanNewValue : null,
        "category": selectedProblemType,
        "speed": selectedSpeed,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save changes');
      }

      // -----------------------------------
      // 1.1) If old subtype → load existing Problem Subtype Name
      // -----------------------------------
      String problemNameText = cleanNewValue ?? "";

      if (!isNewValue) {
        final getProblemNameUrl = Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/get-ProblemName',
        );

        final nameResponse = await http.post(
          getProblemNameUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"ProblemTypeID": selectedProblemSubType}),
        );

        if (nameResponse.statusCode == 200) {
          try {
            final problemNameData = jsonDecode(nameResponse.body);
            problemNameText = problemNameData["problem_subtypename"] ?? "";
          } catch (e) {
            debugPrint("❌ JSON decode error on problem name");
          }
        } else {
          debugPrint("❌ Failed to get problem name");
        }
      }

      // -----------------------------------
      // 2) Send chat notification message
      // -----------------------------------
      final String messageText =
          "รายการปัญหานี้ถูกเปลี่ยนประเภทเป็น $problemNameText "
          "อยู่ในหมวดหมู่ $selectedProblemType "
          "ความเร็ว $selectedSpeed "
          "ในเวลา ${DateTime.now()}";

      final chatResponse = await http.post(
        sendMessageUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "problemID": widget.id,
          "staffid": adUser,
          "message": messageText,
        }),
      );

      if (chatResponse.statusCode != 200) {
        debugPrint("❌ Failed to send chat message");
        return;
      }

      // -----------------------------------
      // 3) Finished
      // -----------------------------------
      debugPrint("✔ Problem changes saved and message sent");
    } catch (e) {
      debugPrint('Error saveProblemChanges: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  //---------------------- Styles / Utilities ----------------------//
  static const _labelStyle = TextStyle(
    color: Color(0xff333333),
    fontWeight: FontWeight.w400,
    fontFamily: "Kanit",
    fontSize: 14.0,
  );
}

// ================= Dropdown Constants ================= //
const double kDropdownHeight = 34;
const double kDropdownFontSize = 13;
const EdgeInsets kDropdownPadding = EdgeInsets.symmetric(horizontal: 8);
