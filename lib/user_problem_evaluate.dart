// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;

// Pages
import 'user_problem_list.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'chat_list.dart';
import 'user_dashboard.dart';

// Utils
import 'utils/session_manager.dart';
import 'utils/protected_page.dart';

class UserProblemEvaluate extends ProtectedPage {
  final String id;
  final String issue;
  final String status;

  const UserProblemEvaluate({
    super.key,
    required this.id,
    required this.issue,
    required this.status,
  });

  @override
  State<UserProblemEvaluate> createState() => _UserProblemEvaluateState();
}

class _UserProblemEvaluateState
    extends ProtectedState<UserProblemEvaluate> {
  double rating = 0;
  bool isLoading = false;

  final TextEditingController commentController =
      TextEditingController();

  static const Color primaryColor = Color(0xFFC23B85);
  static const Color accentColor = Color(0xFFAD3A77);
  static const Color backgroundColor = Color(0xFFFDE6EF);
  static const Color cardColor = Colors.white;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> markProblemAsCompleted() async {
    final userData = await SessionManager.getUserData();
    final adUser = userData['userid'];

    final url = Uri.parse(
      'https://digitapp.rajavithi.go.th/ITService_API/api/markProblemAsCompleted',
    );

    final response = await http.post(
      url,
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "problemID": widget.id,
        "ad_user": adUser,
        "rating": rating,
        "comment": commentController.text.trim(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit evaluation');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildHeader(size, context),
          _buildContent(size, context),
          _buildFooter(context, size),
        ],
      ),
    );
  }

  //---------------------- Header ----------------------//
  Widget _buildHeader(Size size, BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Container(
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
              "ประเมินผลการซ่อม",
              style: TextStyle(
                fontFamily: "Kanit",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: Image.asset(
                'assets/img/left_arrow.png',
                width: size.height * 0.025,
                height: size.height * 0.025,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserDashboard(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //---------------------- Content ----------------------//
  Widget _buildContent(Size size, BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.02),
            Expanded(
              child: SingleChildScrollView(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "หมายเลขปัญหา: ${widget.id}",
                        style: const TextStyle(
                          fontFamily: "Kanit",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "หัวข้อ: ${widget.issue}",
                        style: const TextStyle(
                          fontFamily: "Kanit",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff555555),
                        ),
                      ),
                      const Divider(height: 20),

                      const Text(
                        "ให้คะแนนการซ่อม",
                        style: TextStyle(
                          fontFamily: "Kanit",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            iconSize: 36,
                            onPressed: () {
                              setState(() {
                                rating = index + 1.0;
                              });
                            },
                            icon: Icon(
                              index < rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                          );
                        }),
                      ),

                      Center(
                        child: Text(
                          "คะแนน: ${rating.toInt()} / 5",
                          style: const TextStyle(
                            fontFamily: "Kanit",
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        "ความคิดเห็นเพิ่มเติม",
                        style: TextStyle(
                          fontFamily: "Kanit",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "กรอกความคิดเห็นของคุณ...",
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: size.height * 0.045,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (rating == 0) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "กรุณาให้คะแนนก่อนส่ง"),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  try {
                                    await markProblemAsCompleted();

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "ส่งผลการประเมินเรียบร้อยแล้ว"),
                                      ),
                                    );

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const HomePage(),
                                      ),
                                    );
                                  } catch (_) {
                                    setState(
                                        () => isLoading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xffe6ffd6),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "ส่งผลการประเมิน",
                            style: TextStyle(
                              fontFamily: "Kanit",
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.025),
          ],
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
          _footerIcon(Icons.home, "Home", size, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const UserDashboard()),
            );
          }),
          _footerImage('assets/img/mail.png', "Message",
              size, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ChatListPage()),
            );
          }),
          _footerImage('assets/img/list.png', "List",
              size, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const UserProblemList()),
            );
          }),
          _footerIcon(Icons.logout, "Logout", size, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const LoginPage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _footerIcon(
    IconData icon,
    String label,
    Size size,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: size.height * 0.03),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontFamily: "Kanit", fontSize: 12)),
        ],
      ),
    );
  }

  Widget _footerImage(
    String path,
    String label,
    Size size,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            path,
            width: size.height * 0.03,
            height: size.height * 0.03,
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontFamily: "Kanit", fontSize: 12)),
        ],
      ),
    );
  }
}
