// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;
import 'it_dashboard.dart';

// Local pages
import 'admin_problem_detail_select.dart';
import 'admin_problem_list.dart';
import 'chat_list.dart';
import 'login_page.dart';

// Utils
import 'utils/session_manager.dart';
import 'utils/protected_page.dart';

class AdminDashboard extends ProtectedPage {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ProtectedState<AdminDashboard> {
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
      body: Column(
        children: [
          _buildHeader(context, size),
          isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildBody(context, size, problemRows),
          _buildFooter(context, size),
        ],
      ),
    );
  }

  // ============================== Header ============================== //
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
                MaterialPageRoute(builder: (_) => const ITDashboard()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================== Body ============================== //
  Widget _buildBody(
    BuildContext context,
    Size size,
    List<Map<String, dynamic>> rows,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.02),
            _buildSummaryCards(context),
            Expanded(child: _buildProblemTable(context, rows)),
            SizedBox(height: size.height * 0.025),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final waiting = problemRows.where((r) => r['status'] == 'รอตรวจสอบ').length;
    final cards = [_summaryCard("รอตรวจสอบ", waiting, Colors.blue)];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: cards.map((card) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: card,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _summaryCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4)],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                return Container(
                  color: index.isEven
                      ? const Color(0xFFFDE6F2)
                      : const Color(0xFFFFF0F8),
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
    const headers = ["หมายเลขปัญหา", "ปัญหา", "สถานะ"];
    const flex = [3, 2, 2, 1];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFFE9DFF5),
      child: Row(
        children: List.generate(headers.length, (i) {
          return Expanded(
            flex: flex[i],
            child: Center(
              child: Text(
                headers[i],
                style: const TextStyle(
                  fontFamily: "Kanit",
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        })..add(const Expanded(flex: 1, child: SizedBox())),
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
    return Container(
      // ✅ FIXED: no top gap
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildCell(id, flex: 3, color: priorityColor),
          _buildCell(issue, flex: 2, color: Colors.black87),
          _buildCell(status, flex: 2, color: statusColor),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminProblemDetailSelect(id: id),
                  ),
                );
              },
              child: Image.asset(imagePath, width: 18, height: 18),
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(path, width: 22, height: 22),
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
    final userData = await SessionManager.getUserData();
    final category = userData['team'];

    final response = await http.post(
      Uri.parse(
        'https://digitapp.rajavithi.go.th/ITService_API/api/get-adminproblemdashboard',
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"category": category}),
    );

    final List<Map<String, dynamic>> data = (json.decode(response.body) as List)
        .cast<Map<String, dynamic>>();

    setState(() {
      problemRows =
          data.map((item) {
            return {
              'id': item['problem_id'],
              'issue': item['problem_subtypename'],
              'status': item['problem_status'],
              'priority': item['problem_speed'],
              'image': 'assets/img/inspect.png',
              'statusColor': _getStatusColor(item['problem_status']),
              'priorityColor': _getPriorityColor(item['problem_speed']),
              'createdAt': item['problem_createdat'],
            };
          }).toList()..sort((a, b) {
            final aTime =
                DateTime.tryParse(a['createdAt'] ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final bTime =
                DateTime.tryParse(b['createdAt'] ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime); // latest first
          });

      isLoading = false;
    });
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
        return Colors.grey;
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
