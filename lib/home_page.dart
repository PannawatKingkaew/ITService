// Flutter
import 'package:flutter/material.dart';

// Local pages
import 'it_dashboard.dart';
import 'login_page.dart';
import 'user_dashboard.dart';

// Utils
import 'utils/protected_page.dart';
import 'utils/session_manager.dart';

class HomePage extends ProtectedPage {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ProtectedState<HomePage> {
  // ===== State =====
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<Map<String, dynamic>?> _userData =
      ValueNotifier<Map<String, dynamic>?>(null);

  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _userData.dispose();
    super.dispose();
  }

  // ============================== UI ============================== //

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (_, loading, __) {
        if (loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFDE6EF),
          body: SafeArea(
            child: Column(
              children: [
                RepaintBoundary(child: _buildHeader(context, size)),
                Expanded(
                  child: RepaintBoundary(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06,
                        vertical: size.height * 0.03,
                      ),
                      child: Column(
                        children: [
                          _buildMenuCard(
                            context,
                            size,
                            title: "แจ้งปัญหา",
                            image: 'assets/img/employee.png',
                            backgroundColor: const Color(0xFFFFE0F0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UserDashboard(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: size.height * 0.02),

                          // ===== IT / Admin Menu =====
                          ValueListenableBuilder<Map<String, dynamic>?>(
                            valueListenable: _userData,
                            builder: (_, data, __) {
                              final type = data?['usertype'];

                              if (type != "Admin" && type != "IT") {
                                return const SizedBox.shrink();
                              }

                              return _buildMenuCard(
                                context,
                                size,
                                title: "สำหรับพนักงาน IT",
                                image: 'assets/img/it_employee.png',
                                backgroundColor: const Color(0xFFE9F2FF),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ITDashboard(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================== Header ============================== //

  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.08,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFAD3A77), Color(0xFFC23B85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: _userData,
              builder: (_, data, __) {
                return Text(
                  "สวัสดี, ${data?['username'] ?? ''}",
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          _buildLogoutButton(context, size),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, Size size) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _logout(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.01,
          horizontal: size.width * 0.04,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD563A1), Color(0xFFDB69A7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'ออกจากระบบ',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ============================== Menu Card ============================== //

  Widget _buildMenuCard(
    BuildContext context,
    Size size, {
    required String title,
    required String image,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return RepaintBoundary(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Card(
          color: backgroundColor,
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: SizedBox(
            width: double.infinity,
            height: size.height * 0.13,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
                children: [
                  Image.asset(
                    image,
                    width: size.height * 0.1,
                    height: size.height * 0.1,
                    cacheWidth: 300,
                    cacheHeight: 300,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: size.width * 0.05),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: size.height * 0.035,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================== Logic ============================== //

  Future<void> _loadUserSession() async {
    final data = await SessionManager.getUserData();
    if (!mounted) return;

    _userData.value = data;
    _isLoading.value = false;
  }

  Future<void> _logout(BuildContext context) async {
    if (_loggingOut) return;
    _loggingOut = true;

    await SessionManager.clearSession();
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
