// Dart
import 'dart:convert';
import 'dart:io';

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Packages
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// Local pages
import 'chat_list.dart';
import 'login_page.dart';
import 'user_dashboard.dart';
import 'user_problem_confirm.dart';
import 'user_problem_list.dart';

// Utils
import 'utils/session_manager.dart';
import 'utils/protected_page.dart';

class ProblemItem {
  final String id;
  final String name;

  const ProblemItem({required this.id, required this.name});
}

class UserProblemForm extends ProtectedPage {
  final String category;
  const UserProblemForm({super.key, required this.category});

  @override
  State<UserProblemForm> createState() => _UserProblemFormState();
}

class _UserProblemFormState extends ProtectedState<UserProblemForm> {
  ProblemItem? selectedProblemItem;
  String? selectedPriority;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  String ad = "";
  String username = "";
  String company = "";

  late final TextEditingController adController;
  late final TextEditingController nameController;
  late final TextEditingController companyController;
  late final TextEditingController phoneController;
  late final TextEditingController descriptionController;
  late final TextEditingController categoryController;
  late final TextEditingController locationController;

  final List<String> _priorityOptions = ["ปกติ", "ด่วน", "ด่วนมาก"];

  final Color _primaryColor = const Color(0xFFC23B85);
  final Color _accentColor = const Color(0xFFAD3A77);
  final Color _backgroundColor = const Color(0xFFFDE6EF);

  final double _fieldHeight = 36;
  final EdgeInsets _fieldPadding = const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 0,
  );

  List<ProblemItem> problemsFromApi = [];
  bool isLoadingProblems = false;

  @override
  void initState() {
    super.initState();

    adController = TextEditingController();
    nameController = TextEditingController();
    companyController = TextEditingController();
    phoneController = TextEditingController();
    descriptionController = TextEditingController();
    locationController = TextEditingController();
    categoryController = TextEditingController(text: widget.category);

    _loadUserSession();
  }

  @override
  void dispose() {
    adController.dispose();
    nameController.dispose();
    companyController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Column(
        children: [
          _buildHeader(context, size),
          _buildContent(context, size),
          _buildFooter(context, size),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context, Size size) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: size.height * 0.06,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_accentColor, _primaryColor],
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
          "รายละเอียดปัญหา",
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

  // ---------------- CONTENT ----------------
  Widget _buildContent(BuildContext context, Size size) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Container(
          width: size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("ข้อมูลผู้ใช้งาน"),
              _buildTextField("เลข AD", adController, readOnly: true),
              const SizedBox(height: 16),
              _buildTextField("ชื่อ", nameController, readOnly: true),
              const SizedBox(height: 16),
              _buildTextField("หน่วยงาน", companyController, readOnly: true),
              const SizedBox(height: 16),
              _buildTextField("สถานที่", locationController),
              const SizedBox(height: 16),
              _buildTextField(
                "เบอร์ติดต่อ",
                phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
              ),
              Divider(color: Colors.grey[300], height: 30),
              _sectionTitle("รายละเอียดปัญหา"),
              const SizedBox(height: 16),
              _buildTextField("หมวดหมู่", categoryController, readOnly: true),
              const SizedBox(height: 16),
              isLoadingProblems
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDropdownField(
                      "เลือกปัญหา",
                      selectedProblemItem?.name,
                      items: problemsFromApi.map((e) => e.name).toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        final exist = problemsFromApi
                            .where((p) => p.name == val)
                            .isNotEmpty;

                        ProblemItem item;
                        if (!exist) {
                          item = ProblemItem(id: 'new:$val', name: val);
                          problemsFromApi.add(item);
                        } else {
                          item = problemsFromApi.firstWhere(
                            (p) => p.name == val,
                          );
                        }

                        setState(() => selectedProblemItem = item);
                      },
                    ),
              const SizedBox(height: 16),
              _buildDropdownField(
                "ความเร็ว",
                selectedPriority,
                items: _priorityOptions,
                searchVisible: false,
                onChanged: (val) => setState(() => selectedPriority = val),
              ),
              const SizedBox(height: 16),
              _buildDescriptionField(
                "อธิบายเพิ่มเติม",
                controller: descriptionController,
              ),
              Divider(color: Colors.grey[300], height: 30),
              _buildImagePicker(size),
              const SizedBox(height: 48),
              Align(
                alignment: Alignment.center,
                child: _buildButton(
                  text: "ต่อไป",
                  color: _primaryColor,
                  borderColor: _primaryColor,
                  textColor: Colors.white,
                  onTap: _onNextTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- TEXT FIELD ----------------
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label :",
          style: const TextStyle(fontFamily: "Kanit", fontSize: 13),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: _fieldHeight,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontSize: 13, height: 1.1),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xfff9f9f9),
              contentPadding: _fieldPadding,
              border: _buildBorder(),
              enabledBorder: _buildBorder(),
              focusedBorder: _buildBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(
    String label, {
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label :", style: const TextStyle(fontFamily: "Kanit")),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 8,
          style: const TextStyle(fontSize: 13, height: 1.2),
          decoration: InputDecoration(
            hintText: "อธิบายเพิ่มเติม...",
            filled: true,
            fillColor: const Color(0xfff9f9f9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: _buildBorder(radius: 12),
            enabledBorder: _buildBorder(radius: 12),
            focusedBorder: _buildBorder(radius: 12),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder({double radius = 10}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: Colors.black12),
    );
  }

  // ---------------- DROPDOWN ----------------
  Widget _buildDropdownField(
    String label,
    String? value, {
    List<String>? items,
    bool readOnly = false,
    bool searchVisible = true,
    Function(String?)? onChanged,
  }) {
    final double itemHeight = 32;
    final double searchBoxHeight = searchVisible ? 36 : 0;
    final EdgeInsets fieldPadding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 0,
    );
    final double fieldHeight = 36;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label :", style: const TextStyle(fontFamily: "Kanit")),
        const SizedBox(height: 6),
        readOnly
            ? Container(
                height: fieldHeight,
                padding: fieldPadding,
                decoration: BoxDecoration(
                  color: const Color(0xfff9f9f9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                alignment: Alignment.centerLeft,
                child: Text(value ?? "", style: const TextStyle(fontSize: 13)),
              )
            : SizedBox(
                height: fieldHeight,
                child: DropdownSearch<String>(
                  items: items ?? [],
                  selectedItem: value,
                  onChanged: onChanged,
                  dropdownBuilder: (context, selectedItem) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      selectedItem ?? '',
                      style: const TextStyle(fontSize: 13, height: 1.1),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: searchVisible,
                    showSelectedItems: true,
                    emptyBuilder: (context, searchEntry) => ListTile(
                      title: Text('เพิ่ม "$searchEntry" เป็นรายการใหม่'),
                      onTap: () async {
                        Navigator.pop(context);
                        if (onChanged != null) onChanged(searchEntry);
                      },
                    ),
                    constraints: BoxConstraints(
                      maxHeight: (items != null
                          ? (items.length.clamp(1, 4) * itemHeight) +
                                searchBoxHeight
                          : 200),
                    ),
                    searchFieldProps: TextFieldProps(
                      style: const TextStyle(fontSize: 13, height: 1.1),
                      decoration: InputDecoration(
                        hintText: 'ค้นหา...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        isDense: true,
                      ),
                    ),
                    itemBuilder: (context, item, isSelected) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      child: Text(
                        item,
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  // ---------------- IMAGE ----------------
  Widget _buildImagePicker(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("รูปภาพ :", style: TextStyle(fontFamily: "Kanit")),
        const SizedBox(height: 6),
        ElevatedButton.icon(
          icon: const Icon(Icons.photo_camera),
          label: const Text("เลือกรูป", style: TextStyle(fontFamily: "Kanit")),
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
        ),
        if (_image != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Image.file(_image!, width: size.width * 0.6),
          ),
      ],
    );
  }

  // ---------------- BUTTON ----------------
  Widget _buildButton({
    required String text,
    required Color color,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: "Kanit",
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      title,
      style: const TextStyle(
        fontFamily: "Kanit",
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ---------------- FOOTER ----------------
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
          _footerIcon(context, Icons.home, "Home", size, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserDashboard()),
            );
          }),
          _footerImage(context, 'assets/img/mail.png', "Message", size, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListPage()),
            );
          }),
          _footerImage(context, 'assets/img/list.png', "List", size, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserProblemList()),
            );
          }),
          _footerIcon(context, Icons.logout, "Logout", size, () {
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
    Size size,
    VoidCallback onTap,
  ) {
    final iconSize = size.height * 0.03;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: Colors.black87),
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
    Size size,
    VoidCallback onTap,
  ) {
    final imageSize = size.height * 0.03;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(path, width: imageSize, height: imageSize),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontFamily: "Kanit", fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ---------------- LOGIC ----------------
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
      username = userData['username'];
      company = userData['company'];
      ad = userData['userid'];

      nameController.text = username;
      companyController.text = company;
      adController.text = ad;
    });

    fetchProblems();
  }

  Future<void> fetchProblems() async {
    setState(() => isLoadingProblems = true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/get-problemsubtypelist',
        ),
        body: {'category': categoryController.text},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          problemsFromApi = List<ProblemItem>.from(
            data.map(
              (item) => ProblemItem(
                id: item['problem_typeid'].toString(),
                name: item['problem_subtypename'].toString(),
              ),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint("Error fetching problems: $e");
    }

    setState(() => isLoadingProblems = false);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null && mounted) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _onNextTap() {
    final phone = phoneController.text.trim();

    if (selectedProblemItem == null || selectedPriority == null) {
      _showError("กรุณากรอกข้อมูลให้ครบถ้วน");
      return;
    }

    if (phone.isEmpty) {
      _showError("กรุณากรอกเบอร์โทร 5 หลัก");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProblemConfirm(
          name: nameController.text,
          company: companyController.text,
          phone: phone,
          category: categoryController.text,
          problemName: selectedProblemItem!.name,
          problemID: selectedProblemItem!.id,
          priority: selectedPriority!,
          description: descriptionController.text,
          location: locationController.text,
          image: _image,
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade400,
        content: Text(msg, style: const TextStyle(fontFamily: "Kanit")),
      ),
    );
  }
}
