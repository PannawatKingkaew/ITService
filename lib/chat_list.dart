// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;

// Local pages
import 'chat_message.dart';

// Utils
import 'utils/session_manager.dart';
import 'utils/protected_page.dart';

class ChatListPage extends ProtectedPage {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ProtectedState<ChatListPage> {
  List<Map<String, dynamic>> chatList = [];
  bool isLoading = true;

  static const Color primaryColor = Color(0xFFC23B85);
  static const Color secondaryColor = Color(0xFFAD3A77);
  static const Color backgroundColor = Color(0xFFFDE6EF);

  @override
  void initState() {
    super.initState();
    fetchChatList();
  }

  // ========================= UI ========================== //
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildHeader(size),
          Expanded(child: _buildChatList(size)),
        ],
      ),
    );
  }

  // ---------------------- Header ---------------------- //
  Widget _buildHeader(Size size) {
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
                colors: [secondaryColor, primaryColor],
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
              "Message",
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
                width: size.height * 0.02,
                height: size.height * 0.02,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------- Chat List ---------------------- //
  Widget _buildChatList(Size size) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (chatList.isEmpty) {
      return const Center(
        child: Text(
          "ไม่มีแชทที่ใช้งานอยู่",
          style: TextStyle(
            fontFamily: "Kanit",
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final item = chatList[index];

          return _buildChatTile(
            size,
            item["problem_id"] as String,
            item["message_text"] as String,
            item["unread"] as int,
          );
        },
      ),
    );
  }

  // ---------------------- Chat Tile ---------------------- //
  Widget _buildChatTile(
    Size size,
    String problemId,
    String messageText,
    int unread,
  ) {
    return GestureDetector(
      onTap: () async {
        final shouldReload = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatMessagePage(problemId: problemId),
          ),
        );

        if (!mounted || shouldReload != true) return;

        setState(() {
          isLoading = true;
          chatList.clear();
        });

        fetchChatList();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAccentLine(size),
            _buildChatInfo(problemId, messageText),
            _buildBadgeOrTime(size, unread),
          ],
        ),
      ),
    );
  }

  // ---------------------- Accent Line ---------------------- //
  Widget _buildAccentLine(Size size) {
    return Container(
      width: 6,
      height: size.height * 0.09,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [secondaryColor, primaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
    );
  }

  // ---------------------- Chat Info ---------------------- //
  Widget _buildChatInfo(String problemId, String messageText) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              problemId,
              style: const TextStyle(
                fontFamily: "Kanit",
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xff333333),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              messageText.isNotEmpty ? messageText : "ยังไม่มีข้อความ",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "Kanit",
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------- Badge or Time ---------------------- //
  Widget _buildBadgeOrTime(Size size, int unread) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: unread > 0
          ? Container(
              width: size.height * 0.028,
              height: size.height * 0.028,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6262),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                unread.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Kanit",
                  fontSize: 12,
                ),
              ),
            )
          : Text(
              "09:42",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontFamily: "Kanit",
                fontSize: 12,
              ),
            ),
    );
  }

  // ========================= API ========================== //
  Future<void> fetchChatList() async {
    try {
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      final response = await http.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/get-ChatList',
        ),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({"ad_user": adUser}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load chat list');
      }

      final List<dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> baseList = data
          .map(
            (e) => {
              "problem_id": e["problem_id"],
              "message_text": e["message_text"] ?? "",
              "unread": 0,
            },
          )
          .toList();

      if (!mounted) return;

      setState(() {
        chatList = baseList;
        isLoading = false;
      });

      fetchNotification();
    } catch (e) {
      debugPrint("Error fetchChatList: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> fetchNotification() async {
    try {
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      final response = await http.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/get-checknotification',
        ),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({"ad_user": adUser}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load notifications');
      }

      final List<dynamic> data = json.decode(response.body);

      final Map<String, int> notificationMap = {
        for (var item in data)
          item["problem_id"]:
              int.tryParse(
                    (item["total_unread_notifications"] ?? "0").toString(),
                  ) ??
                  0,
      };

      if (!mounted) return;

      setState(() {
        chatList = chatList.map((chat) {
          return {
            ...chat,
            "unread": notificationMap[chat["problem_id"]] ?? 0,
          };
        }).toList();
      });
    } catch (e) {
      debugPrint("Error fetchNotification: $e");
    }
  }
}
