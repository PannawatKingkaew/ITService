// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;

// Local pages
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final String? adUser;
  final String? department;
  final String? company;
  final String? firstName;
  final String? lastName;

  const RegisterPage({
    super.key,
    this.adUser,
    this.department,
    this.company,
    this.firstName,
    this.lastName,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ============================== Theme Colors ============================== //
  static const Color primaryColor = Color(0xFFC23B85);
  static const Color accentColor = Color(0xFFAD3A77);
  static const Color backgroundColor = Color(0xFFFDE6EF);
  static const Color fieldColor = Colors.white;
  static const Color textColor = Color(0xFF333333);

  // ============================== Form Controllers ============================== //
  final _formKey = GlobalKey<FormState>();
  final TextEditingController adNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController companyController = TextEditingController();

  String? selectedTeam;
  bool isAdmin = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    adNumberController.text = widget.adUser ?? '';
    nameController.text = '${widget.firstName ?? ''} ${widget.lastName ?? ''}'
        .trim();
    departmentController.text = widget.department ?? '';
    companyController.text = widget.company ?? '';
  }

  @override
  void dispose() {
    adNumberController.dispose();
    nameController.dispose();
    departmentController.dispose();
    companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(size),
              const SizedBox(height: 30),

              // ---------------------- Form ---------------------- //
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: adNumberController,
                      label: "เลข AD",
                      icon: Icons.badge,
                      validator: (value) =>
                          value!.isEmpty ? 'กรุณากรอกเลข AD' : null,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: nameController,
                      label: "ชื่อ - สกุล",
                      icon: Icons.person,
                      validator: (value) =>
                          value!.isEmpty ? 'กรุณากรอกชื่อ - สกุล' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: departmentController,
                      label: "Department",
                      icon: Icons.apartment,
                      validator: (value) =>
                          value!.isEmpty ? 'กรุณากรอกแผนก' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: companyController,
                      label: "Company",
                      icon: Icons.business,
                      validator: (value) =>
                          value!.isEmpty ? 'กรุณากรอกชื่อหน่วยงาน' : null,
                    ),
                    const SizedBox(height: 16),

                    // ---------------------- Conditional Team & Admin ---------------------- //
                    if (companyController.text == "ศูนย์คอมพิวเตอร์") ...[
                      _buildDropdownTeam(),
                      const SizedBox(height: 8),
                      _buildAdminCheckbox(),
                    ],

                    const SizedBox(height: 30),
                    _buildSaveButton(size),
                    const SizedBox(height: 20),
                    _buildLoginRedirect(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================== Header ============================== //
  Widget _buildHeader(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
       child: const Column(
        children: [
          Text(
            "ตรวจสอบข้อมูล",
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Rajavithi IT Helpdesk System",
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ============================== TextField ============================== //
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: readOnly,
      style: const TextStyle(fontFamily: 'Kanit', color: textColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: fieldColor,
        prefixIcon: Icon(icon, color: accentColor),
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Kanit', color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }

  // ============================== Dropdown Team ============================== //
  Widget _buildDropdownTeam() {
    const teams = ['Implement', 'Network', 'Helpdesk', 'Programmer'];
    return DropdownButtonFormField<String>(
      initialValue: selectedTeam,
      items: teams
          .map(
            (team) => DropdownMenuItem(
              value: team,
              child: Text(team, style: const TextStyle(fontFamily: 'Kanit')),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => selectedTeam = value),
      decoration: InputDecoration(
        filled: true,
        fillColor: fieldColor,
        labelText: "Team",
        labelStyle: const TextStyle(fontFamily: 'Kanit', color: Colors.grey),
        prefixIcon: const Icon(Icons.groups, color: accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
      validator: (value) => value == null ? 'กรุณาเลือกทีม' : null,
    );
  }

  // ============================== Checkbox Admin ============================== //
  Widget _buildAdminCheckbox() {
    return CheckboxListTile(
      value: isAdmin,
      onChanged: (value) => setState(() => isAdmin = value!),
      title: const Text(
        "เป็นผู้ดูแลระบบ (Admin)",
        style: TextStyle(fontFamily: 'Kanit', fontSize: 15),
      ),
      activeColor: accentColor,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }

  // ============================== Save Button ============================== //
  Widget _buildSaveButton(Size size) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: primaryColor,
        ),
        onPressed: isLoading ? null : saveData,
        child: isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text(
                "บันทึกข้อมูล",
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // ============================== Login Redirect ============================== //
  Widget _buildLoginRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "กลับไปหน้า ",
          style: TextStyle(fontFamily: 'Kanit', color: textColor),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          ),
          child: const Text(
            "เข้าสู่ระบบ",
            style: TextStyle(
              fontFamily: 'Kanit',
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================== Save Data to Laravel API ============================== //
  Future<void> saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    Map<String, dynamic> data = {
      'adUser': adNumberController.text,
      'name': nameController.text,
      'department': departmentController.text,
      'company': companyController.text,
    };

    if (companyController.text == "ศูนย์คอมพิวเตอร์") {
      data['team'] = selectedTeam;
      data['usertype'] = isAdmin ? 'Admin' : 'IT';
    } else {
      data['team'] = selectedTeam;
      data['usertype'] = 'User';
    }

    try {
      final response = await http.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/register-newuser',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': data}),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ลงทะเบียนสำเร็จ!',
              style: TextStyle(fontFamily: 'Kanit'),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ลงทะเบียนล้มเหลว: ${response.body}',
              style: const TextStyle(fontFamily: 'Kanit'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'เกิดข้อผิดพลาด: $e',
            style: const TextStyle(fontFamily: 'Kanit'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
