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
          _buildHeader(context, size),
          isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : _buildBody(context, size, problemRows),
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
          style: TextStyle(
            fontFamily: "Kanit",
            fontSize: 12,
            color: Colors.white,
          ),
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
                MaterialPageRoute(builder: (_) => const HomePage()),
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
            Expanded(child: _buildProblemTable(context)),
            SizedBox(height: size.height * 0.025),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final filteredRows = problemRows.toList();

    final total = filteredRows.where((r) => r['status'] != 'ยกเลิก').length;

    final waiting = filteredRows
        .where((r) => r['status'] == 'รอตรวจสอบ')
        .length;

    final inProgress = filteredRows
        .where(
          (r) =>
              r['status'] == 'รอดำเนินการ' || r['status'] == 'กำลังดำเนินการ',
        )
        .length;

    final evaluating = filteredRows
        .where((r) => r['status'] == 'รอประเมิน')
        .length;

    final done = filteredRows.where((r) => r['status'] == 'เสร็จสิ้น').length;

    final cards = [
      _summaryCard("ทั้งหมด", total, Colors.purple),
      _summaryCard("เสร็จสิ้น", done, Colors.green),
      _summaryCard("รอตรวจสอบ", waiting, Colors.blue),
      _summaryCard("รอดำเนินการ", inProgress, Colors.orange),
      _summaryCard("รอประเมิน", evaluating, Colors.orange),
    ];

    final size = MediaQuery.of(context).size;
    final cardWidth = (size.width - 40) / 2; 

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
  
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: cards.sublist(0, 2).map((card) {
              return SizedBox(width: cardWidth, child: card);
            }).toList(),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: cards
                .sublist(2)
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: card,
                    ),
                  ),
                )
                .toList(),
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
            style: const TextStyle(
              fontFamily: "Kanit",
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemTable(BuildContext context) {
    final filteredRows = problemRows
        .where(
          (row) => row['status'] != 'เสร็จสิ้น' && row['status'] != 'ยกเลิก',
        )
        .toList();
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeader(),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: filteredRows.length,
              itemBuilder: (context, index) {
                final row = filteredRows[index];
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
    const headers = ["หมายเลขปัญหา", "ปัญหา", "สถานะ"];
    const flexValues = [3, 2, 2, 1];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      color: const Color(0xFFE9DFF5),
      child: Row(
        children: List.generate(headers.length, (i) {
          return Expanded(
            flex: flexValues[i],
            child: Center(
              child: Text(
                headers[i],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: "Kanit",
                  fontSize: 13,
                  color: Color(0xFF333333),
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
    const textColor = Color(0xFF333333);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCell(id, flex: 3, color: priorityColor),
          _buildCell(issue, flex: 2, color: textColor),
          _buildCell(status, flex: 2, color: statusColor),
          Expanded(
            flex: 1,
            child: Center(
              child: GestureDetector(
                onTap: () async {
   
                  if (!context.mounted) return;
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
          style: TextStyle(fontFamily: "Kanit", fontSize: 12, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

  // ============================== Logic ============================== //

  Future<void> fetchDashboardData() async {
    try {
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      final url = Uri.parse(
        'https://digitapp.rajavithi.go.th/ITService_API/api/get-userproblemdashboard',
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ad_user": adUser}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load dashboard data');
      }

      final List<Map<String, dynamic>> data =
          (json.decode(response.body) as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();

      setState(() {
        problemRows = data.map((item) {
          final statusColor = _getStatusColor(item['problem_status'] as String);
          final priorityColor = _getPriorityColor(
            item['problem_speed'] as String,
          );
          return {
            'id': item['problem_id'],
            'issue': item['problem_subtypename'],
            'status': item['problem_status'],
            'priority': item['problem_speed'],
            'image': 'assets/img/inspect.png',
            'statusColor': statusColor,
            'priorityColor': priorityColor,
            'createdBy': item['problem_createdby'],
            'createdAt': item['problem_createdat'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching dashboard: $e');
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
