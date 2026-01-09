// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;

// Local pages
import 'chat_list.dart';
import 'it_problem_detail_read.dart';
import 'it_dashboard.dart';
import 'login_page.dart';

// Utils
import 'utils/session_manager.dart';
import 'utils/protected_page.dart';

class ITProblemList extends ProtectedPage {
  const ITProblemList({super.key});

  @override
  State<ITProblemList> createState() => _ITProblemListState();
}

class _ITProblemListState extends ProtectedState<ITProblemList> {
  String? selectedStatus;
  String? sortOption;
  bool showAllUsers = false;
  List<String> _allStatuses = [];

  String? adUser;

  @override
  void initState() {
    super.initState();
    fetchProblems();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE6EF),
      body: Column(
        children: [
          _buildHeader(size),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchProblems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Expanded(
                  child: Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                  ),
                );
              }

              final rows = snapshot.data?.isNotEmpty == true
                  ? _applyFiltersAndSort(snapshot.data!)
                  : [];

              return rows.isEmpty
                  ? const Expanded(child: Center(child: Text('ไม่มีข้อมูล')))
                  : _buildBody(
                      context,
                      size,
                      rows.cast<Map<String, dynamic>>(),
                    );
            },
          ),
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
            left: size.width * -0.01,
            child: IconButton(
              icon: Image.asset(
                'assets/img/left_arrow.png',
                width: size.height * 0.025,
                height: size.height * 0.025,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ITDashboard()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //---------------------- Filter Bar ----------------------//
  Widget _buildFilterBar(Size size, List<Map<String, dynamic>> rows) {
    final uniqueStatuses = _allStatuses;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F0FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              label: "สถานะ",
              value: selectedStatus,
              items: ["ทั้งหมด", ...uniqueStatuses],
              onChanged: _updateFilter,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildDropdown(
              label: "เรียงโดย",
              value: sortOption,
              items: const [
                "ด่วนที่สุด",
                "ด่วนน้อยที่สุด",
                "รายการล่าสุด",
                "รายการเก่าสุด",
              ],
              onChanged: _updateSort,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC23B85), width: 1),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: const TextStyle(fontFamily: "Kanit", fontSize: 12),
          ),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFFC23B85),
            size: 18,
          ),
          items: items
              .map(
                (val) => DropdownMenuItem<String>(
                  value: val,
                  child: Text(
                    val,
                    style: const TextStyle(fontFamily: "Kanit", fontSize: 12),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

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
            const SizedBox(height: 10),
            _buildFilterBar(size, rows),
            const SizedBox(height: 10),
            Expanded(
              child: _buildProblemTable(
                context,
                rows.cast<Map<String, dynamic>>(),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemTable(
    BuildContext context,
    List<Map<String, dynamic>> rows,
  ) {
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
              itemCount: rows.length,
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
    const textColor = Colors.black87;

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
                      builder: (_) => ITProblemDetailRead(id: id),
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
              MaterialPageRoute(builder: (_) => const ITDashboard()),
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
              MaterialPageRoute(builder: (_) => const ITProblemList()),
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

  Future<List<Map<String, dynamic>>> fetchProblems() async {
    final userData = await SessionManager.getUserData();
    final adUser = userData['userid'];

    final url = Uri.parse(
      'https://digitapp.rajavithi.go.th/ITService_API/api/get-itproblemlist',
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ad_user": adUser}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load problems. Status code: ${response.statusCode}',
      );
    }

    final List<Map<String, dynamic>> data = (json.decode(response.body) as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    final rows = data.map((item) {
      final statusColor = _getStatusColor(item['problem_status'] as String);
      final priorityColor = _getPriorityColor(item['problem_speed'] as String);
      return {
        'id': item['problem_id'] as String,
        'issue': item['problem_subtypename'] as String,
        'status': item['problem_status'] as String,
        'priority': item['problem_speed'] as String,
        'image': 'assets/img/inspect.png',
        'statusColor': statusColor,
        'priorityColor': priorityColor,
        'createdBy': item['problem_createdby'] as String,
        'createdAt': item['problem_createdat'] as String,
      };
    }).toList();

    if (_allStatuses.isEmpty) {
      _allStatuses = rows.map((e) => e['status'] as String).toSet().toList();
    }
    return rows;
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
      case 'ยกเลิก':
        return const Color.fromARGB(255, 105, 106, 117);
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

  void _updateFilter(String? status) => setState(() => selectedStatus = status);
  void _updateSort(String? sort) => setState(() => sortOption = sort);

  List<Map<String, dynamic>> _applyFiltersAndSort(
    List<Map<String, dynamic>> rows,
  ) {
    if (!showAllUsers && adUser != null) {
      rows = rows.where((row) => row['createdBy'] == adUser).toList();
    }

    if (selectedStatus != null && selectedStatus != "ทั้งหมด") {
      rows = rows.where((row) => row['status'] == selectedStatus).toList();
    }

    final priorityOrder = {'ด่วนมาก': 0, 'ด่วน': 1, 'ปกติ': 2};

    rows.sort((a, b) {
      final aPriority = priorityOrder[a['priority']] ?? 3;
      final bPriority = priorityOrder[b['priority']] ?? 3;
      return aPriority.compareTo(bPriority);
    });

    switch (sortOption) {
      case "ด่วนที่สุด":
        rows.sort((a, b) {
          final aPriority = priorityOrder[a['priority']] ?? 3;
          final bPriority = priorityOrder[b['priority']] ?? 3;
          return aPriority.compareTo(bPriority);
        });
        break;
      case "ด่วนน้อยที่สุด":
        rows.sort((a, b) {
          final aPriority = priorityOrder[a['priority']] ?? 3;
          final bPriority = priorityOrder[b['priority']] ?? 3;
          return bPriority.compareTo(aPriority);
        });
        break;
      case "รายการล่าสุด":
        rows.sort(
          (a, b) => DateTime.parse(
            b['createdAt'],
          ).compareTo(DateTime.parse(a['createdAt'])),
        );
        break;
      case "รายการเก่าสุด":
        rows.sort(
          (a, b) => DateTime.parse(
            a['createdAt'],
          ).compareTo(DateTime.parse(b['createdAt'])),
        );
        break;
    }

    return rows;
  }
}
