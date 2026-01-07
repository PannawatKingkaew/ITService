// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;

// Local pages
import 'chat_list.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'user_problem_choice.dart';
import 'user_problem_detail.dart';
import 'user_problem_list.dart';

// Utils
import 'utils/session_manager.dart';
import 'utils/protected_page.dart';

class UserDashboard extends ProtectedPage {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends ProtectedState<UserDashboard> {
  List<Map<String, dynamic>> problemRows = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE6EF),
      floatingActionButton: _buildFab(context, size),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: Column(
        children: [
          RepaintBoundary(child: _buildHeader(context, size)),
          isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildBody(context, size),
          _buildFooter(context, size),
        ],
      ),
    );
  }

  // ============================== Floating ============================== //
  Widget _buildFab(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: size.height * 0.08,
        right: size.width * 0.01,
      ),
      child: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFC23B85),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 18),
        label: const Text(
          "แจ้งปัญหา",
          style: TextStyle(fontFamily: "Kanit", fontSize: 12),
        ),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserProblemChoice()),
        ),
      ),
    );
  }

  // ============================== Header ============================== //
  Widget _buildHeader(BuildContext context, Size size) {
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
                colors: [Color(0xFFAD3A77), Color(0xFFC23B85)],
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
              "รายการปัญหา",
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
            left: size.width * 0.005,
            child: IconButton(
              icon: Image.asset(
                'assets/img/left_arrow.png',
                width: size.height * 0.025,
                height: size.height * 0.025,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================== Body ============================== //
  Widget _buildBody(BuildContext context, Size size) {
    final List<Map<String, dynamic>> activeRows = problemRows
        .where((r) => r['status'] != 'เสร็จสิ้น' && r['status'] != 'ยกเลิก')
        .toList(growable: false);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.02),
            RepaintBoundary(child: _buildSummaryCards()),
            Expanded(
              child: RepaintBoundary(
                child: _buildProblemTable(context, activeRows),
              ),
            ),
            SizedBox(height: size.height * 0.025),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final rows = problemRows;

    int total = 0;
    int waiting = 0;
    int inProgress = 0;
    int evaluating = 0;
    int done = 0;

    for (final r in rows) {
      final status = r['status'];
      if (status == null || status == 'ยกเลิก') continue;

      total++;

      if (status == 'รอตรวจสอบ') {
        waiting++;
      } else if (status == 'รอดำเนินการ' || status == 'กำลังดำเนินการ') {
        inProgress++;
      } else if (status == 'รอประเมิน') {
        evaluating++;
      } else if (status == 'เสร็จสิ้น') {
        done++;
      }
    }

    final size = MediaQuery.sizeOf(context);
    final cardWidth = (size.width - 40) / 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: cardWidth,
                child: _summaryCard("ทั้งหมด", total, Colors.purple),
              ),
              SizedBox(
                width: cardWidth,
                child: _summaryCard("เสร็จสิ้น", done, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _summaryCard("รอตรวจสอบ", waiting, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(
                child: _summaryCard("รอดำเนินการ", inProgress, Colors.orange),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _summaryCard("รอประเมิน", evaluating, Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontFamily: "Kanit",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontFamily: "Kanit", fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemTable(
    BuildContext context,
    List<Map<String, dynamic>> rows,
  ) {
    return Container(
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
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: rows.length,
              itemExtent: 44, // fixed row height = smoother scrolling
              itemBuilder: (context, index) {
                final row = rows[index];
                final bgColor = index.isEven
                    ? const Color(0xFFFDE6F2)
                    : const Color(0xFFFFF0F8);

                return Container(
                  color: bgColor,
                  child: _buildTableRow(
                    context: context,
                    id: row['id'],
                    issue: row['issue'],
                    status: row['status'],
                    imagePath: row['image'],
                    statusColor: row['statusColor'],
                    priorityColor: row['priorityColor'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFFE9DFF5),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: "Kanit",
          fontSize: 13,
          color: Color(0xFF333333),
        ),
        child: const Row(
          children: [
            Expanded(flex: 3, child: Center(child: Text("หมายเลขปัญหา"))),
            Expanded(flex: 2, child: Center(child: Text("ปัญหา"))),
            Expanded(flex: 2, child: Center(child: Text("สถานะ"))),
            Expanded(flex: 1, child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow({
    required BuildContext context,
    required String id,
    required String issue,
    required String status,
    required String imagePath,
    required Color statusColor,
    required Color priorityColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildCell(id, flex: 3, color: priorityColor),
          _buildCell(issue, flex: 2, color: const Color(0xFF333333)),
          _buildCell(status, flex: 2, color: statusColor),
          Expanded(
            flex: 1,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProblemDetail(id: id),
                    ),
                  );
                },
                child: Image.asset(imagePath, width: 18, height: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {required int flex, required Color color}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: "Kanit", fontSize: 12, color: color),
        ),
      ),
    );
  }

  // ============================== Footer ============================== //
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
    final double size = MediaQuery.sizeOf(context).height * 0.03;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: size),
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
    final double size = MediaQuery.sizeOf(context).height * 0.03;
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

  // ============================== Logic ============================== //

  Future<void> fetchDashboardData() async {
    try {
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      final response = await http.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/get-userproblemdashboard',
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ad_user": adUser}),
      );

      if (!mounted) return;

      final List data = json.decode(response.body);
      setState(() {
        problemRows = data
            .map<Map<String, dynamic>>((item) {
              return {
                'id': item['problem_id'],
                'issue': item['problem_subtypename'],
                'status': item['problem_status'],
                'image': 'assets/img/inspect.png',
                'statusColor': _getStatusColor(
                  item['problem_status'] as String,
                ),
                'priorityColor': _getPriorityColor(
                  item['problem_speed'] as String,
                ),
              };
            })
            .toList(growable: false);
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint('Dashboard error: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'รอตรวจสอบ':
        return Colors.red;
      case 'เสร็จสิ้น':
        return Colors.green;
      case 'กำลังดำเนินการ':
        return Colors.blueAccent;
      case 'รอดำเนินการ':
        return Colors.orange;
      case 'รอประเมิน':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'ด่วนมาก':
        return Colors.red;
      case 'ด่วน':
        return Colors.orange;
      case 'ปกติ':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}
