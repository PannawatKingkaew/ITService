// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;

// Local pages
import 'home_page.dart';
import 'register_page.dart';

// Utils
import 'utils/session_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ===== Controllers =====
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ===== State =====
  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  // ===== Reused HTTP Client =====
  final http.Client _client = http.Client();

  @override
  void dispose() {
    _client.close();
    _usernameController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  // ============================== UI ============================== //

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: RepaintBoundary(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD8EC), Color(0xFFEFB7D0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.12),
                RepaintBoundary(child: _buildLogoRow(size)),
                SizedBox(height: size.height * 0.03),
                const Text(
                  "ระบบแจ้งปัญหา IT ศูนย์คอมพิวเตอร์",
                  style: TextStyle(
                    fontFamily: "Kanit",
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Color(0xFF5A2A50),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.03),
                RepaintBoundary(child: _buildLoginCard(size)),
                SizedBox(height: size.height * 0.06),
                Text(
                  "โรงพยาบาลราชวิถี • Rajavithi Hospital",
                  style: TextStyle(
                    fontFamily: "Kanit",
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================== Widgets ============================== //

  Widget _buildLogoRow(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/img/logo1.png',
          width: size.height * 0.1,
          cacheWidth: 200,
        ),
        SizedBox(width: size.width * 0.04),
        Image.asset(
          'assets/img/logo2.png',
          width: size.height * 0.18,
          cacheWidth: 400,
        ),
      ],
    );
  }

  Widget _buildLoginCard(Size size) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFieldLabel("ชื่อผู้ใช้"),
          _buildTextField(
            controller: _usernameController,
            hintText: "กรอกชื่อผู้ใช้ของคุณ",
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
          _buildTextFieldLabel("รหัสผ่าน"),
          _buildPasswordField(),
          SizedBox(height: size.height * 0.04),
          _buildLoginButton(size),
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: "Kanit",
        fontSize: 15,
        color: Color(0xFF555555),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontFamily: "Kanit"),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFC23B85)),
        filled: true,
        fillColor: const Color(0xFFF8F5F8),
        hintText: hintText,
        hintStyle: const TextStyle(fontFamily: "Kanit", color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscurePassword,
      builder: (_, obscure, __) {
        return TextField(
          controller: _passwordController,
          obscureText: obscure,
          style: const TextStyle(fontFamily: "Kanit"),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: Color(0xFFC23B85)),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () =>
                  _obscurePassword.value = !_obscurePassword.value,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F5F8),
            hintText: "กรอกรหัสผ่านของคุณ",
            hintStyle:
                const TextStyle(fontFamily: "Kanit", color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton(Size size) {
    return Center(
      child: SizedBox(
        width: size.width * 0.55,
        height: 52,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (_, loading, __) {
            return ElevatedButton(
              onPressed: loading ? null : _handleLoginForTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC23B85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 6,
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "เข้าสู่ระบบ",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Kanit",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  // ============================== Logic ============================== //

  Future<void> _handleLogin() async {
    if (_isLoading.value) return;

    FocusScope.of(context).unfocus();
    _isLoading.value = true;

    final user = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (user.isEmpty || password.isEmpty) {
      _showError("กรุณากรอกชื่อผู้ใช้และรหัสผ่าน");
      _isLoading.value = false;
      return;
    }

    try {
      final adResponse = await _client.post(
        Uri.parse('https://rjuserad.rajavithi.go.th/ad_api/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user': user, 'password': password}),
      );

      final adData =
          await compute(jsonDecode, adResponse.body) as Map<String, dynamic>;

      if (adResponse.statusCode != 200 || adData['success'] != true) {
        _showError("ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง");
        return;
      }

      final checkResponse = await _client.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/check-user',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': adData}),
      );

      final checkData =
          await compute(jsonDecode, checkResponse.body) as Map<String, dynamic>;

      if (!mounted) return;

      if (checkResponse.statusCode == 200 && checkData['exists'] == true) {
        await SessionManager.saveUserData(checkData['user']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterPage(
              adUser: adData['user_data']['ad_user'],
              department: adData['user_data']['department'],
              company: adData['user_data']['company'],
              firstName: adData['user_data']['first_name'],
              lastName: adData['user_data']['last_name'],
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        _showError("ไม่สามารถเชื่อมต่อระบบได้ กรุณาลองใหม่อีกครั้ง");
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _handleLoginForTest() async {
    if (_isLoading.value) return;

    FocusScope.of(context).unfocus();
    _isLoading.value = true;

    final user = _usernameController.text.trim();

    if (user.isEmpty) {
      _showError("กรุณากรอกชื่อผู้ใช้");
      _isLoading.value = false;
      return;
    }

    try {
      final response = await _client.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/loginForTest',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ad_user': user}),
      );

      final data =
          await compute(jsonDecode, response.body) as Map<String, dynamic>;

      await SessionManager.saveUserData(data['user']);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (_) {
      if (mounted) _showError("เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ");
    } finally {
      _isLoading.value = false;
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "เข้าสู่ระบบไม่สำเร็จ",
          style: TextStyle(fontFamily: "Kanit", fontWeight: FontWeight.w600),
        ),
        content: Text(message,
            style: const TextStyle(fontFamily: "Kanit")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "ตกลง",
              style: TextStyle(
                fontFamily: "Kanit",
                color: Color(0xFFC23B85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
