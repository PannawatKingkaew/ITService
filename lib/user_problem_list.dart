// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;

// Local pages
import 'chat_list.dart';
import 'login_page.dart';
import 'user_dashboard.dart';
import 'user_problem_detail.dart';

// Utils
import 'utils/session_manager.dart';
import 'utils/protected_page.dart';

class UserProblemList extends ProtectedPage {
  const UserProblemList({super.key});

  @override
  State<UserProblemList> createState() => _UserProblemListState();
}

class _UserProblemListState extends ProtectedState<UserProblemList> {
  String? selectedStatus;
  String? sortOption;
  bool showAllUsers = false;

  String? adUser;

  late Future<List<Map<String, dynamic>>> _problemFuture;

  @override
  void initState() {
    super.initState();
    _problemFuture = fetchProblems();
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
            future: _problemFuture,
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

              final rows = snapshot.data ?? [];
              final filtered = _applyFiltersAndSort(List.of(rows));

              return filtered.isEmpty
                  ? const Expanded(child: Center(child: Text('ไม่มีข้อมูล')))
                  : _buildBody(context, size, filtered);
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
                  MaterialPageRoute(builder: (_) => const UserDashboard()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------- Body ---------------------- //
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
            Expanded(child: _buildProblemTable(context, rows)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(Size size, List<Map<String, dynamic>> rows) {
    final uniqueStatuses = rows
        .map((e) => e['status'] as String)
        .toSet()
        .toList();

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
          TextButton.icon(
            icon: Icon(
              showAllUsers ? Icons.person : Icons.people,
              color: const Color(0xFFC23B85),
              size: 18,
            ),
            label: Text(
              showAllUsers ? "ดูของฉัน" : "ดูทั้งหมด",
              style: const TextStyle(
                fontFamily: "Kanit",
                fontSize: 12,
                color: Color(0xFFC23B85),
              ),
            ),
            onPressed: _toggleShowAllUsers,
          ),
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
        border: Border.all(color: const Color(0xFFC23B85)),
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
          items: items
              .map(
                (val) => DropdownMenuItem(
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
              itemBuilder: (context, index) {
                final row = rows[index];
                final bg = index.isEven
                    ? const Color(0xFFFDE6F2)
                    : const Color(0xFFFFF0F8);

                return Container(
                  color: bg,
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFFE9DFF5),
      child: Row(
        children: List.generate(headers.length, (i) {
          return Expanded(
            flex: flexValues[i],
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
    return Padding(
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
                  MaterialPageRoute(builder: (_) => UserProblemDetail(id: id)),
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
          Icon(icon, size: iconSize),
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

  // ============================== Logic ============================== //

  Future<List<Map<String, dynamic>>> fetchProblems() async {
    final userData = await SessionManager.getUserData();
    adUser = userData['userid'];

    final url = Uri.parse(
      showAllUsers
          ? 'https://digitapp.rajavithi.go.th/ITService_API/api/get-alluserproblemlist'
          : 'https://digitapp.rajavithi.go.th/ITService_API/api/get-userproblemlist',
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(showAllUsers ? {} : {"ad_user": adUser}),
    );

    final List data = json.decode(response.body);

    return data.map<Map<String, dynamic>>((item) {
      return {
        'id': item['problem_id'],
        'issue': item['problem_subtypename'],
        'status': item['problem_status'],
        'priority': item['problem_speed'],
        'image': 'assets/img/inspect.png',
        'statusColor': _getStatusColor(item['problem_status']),
        'priorityColor': _getPriorityColor(item['problem_speed']),
        'createdBy': item['problem_createdby'],
        'createdAt': item['problem_createdat'],
      };
    }).toList();
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
        return const Color(0xFF696A75);
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

  void _toggleShowAllUsers() {
    setState(() {
      showAllUsers = !showAllUsers;
      _problemFuture = fetchProblems();
    });
  }

  void _updateFilter(String? value) => setState(() => selectedStatus = value);
  void _updateSort(String? value) => setState(() => sortOption = value);

  List<Map<String, dynamic>> _applyFiltersAndSort(
    List<Map<String, dynamic>> rows,
  ) {
    // -------- Filter --------
    if (selectedStatus != null && selectedStatus != "ทั้งหมด") {
      rows = rows.where((r) => r['status'] == selectedStatus).toList();
    }

    // -------- Sort --------
    final priorityOrder = {'ด่วนมาก': 0, 'ด่วน': 1, 'ปกติ': 2};

    if (sortOption != null) {
      rows.sort((a, b) {
        switch (sortOption) {
          case "ด่วนที่สุด":
            return (priorityOrder[a['priority']] ?? 99).compareTo(
              priorityOrder[b['priority']] ?? 99,
            );

          case "ด่วนน้อยที่สุด":
            return (priorityOrder[b['priority']] ?? 99).compareTo(
              priorityOrder[a['priority']] ?? 99,
            );

          case "รายการล่าสุด":
            final aTime =
                DateTime.tryParse(a['createdAt'] ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final bTime =
                DateTime.tryParse(b['createdAt'] ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime); // newest first

          case "รายการเก่าสุด":
            final aTime =
                DateTime.tryParse(a['createdAt'] ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final bTime =
                DateTime.tryParse(b['createdAt'] ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return aTime.compareTo(bTime); // oldest first

          default:
            return 0;
        }
      });
    }

    return rows;
  }
}
