// Dart
import 'dart:async';
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:itservice/chat_list.dart';

// Utils
import 'utils/session_manager.dart';
import 'utils/protected_page.dart';

class ChatMessagePage extends ProtectedPage {
  final String problemId;

  const ChatMessagePage({super.key, required this.problemId});

  @override
  State<ChatMessagePage> createState() => _ChatMessagePageState();
}

class _ChatMessagePageState extends ProtectedState<ChatMessagePage> {
  bool isLoading = true;
  bool _isFetching = false;

  String? _problemStatus;

  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  Timer? _timer;

  // ======================= API ======================= //

  Future<void> checkProblemStatus() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/checkProblemStatus',
        ),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({"problem_id": widget.problemId}),
      );

      if (response.statusCode != 200) return;

      final List<dynamic> data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        _problemStatus =
            data.isNotEmpty ? data.first['problem_status'] : null;
      });
    } catch (e) {
      debugPrint("Error checkProblemStatus: $e");
    }
  }

  Future<void> changeChatStatus() async {
    try {
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      await http.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/changeChatStatus',
        ),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "ad_user": adUser,
          "problem_id": widget.problemId,
        }),
      );
    } catch (e) {
      debugPrint("Error changeChatStatus: $e");
    }
  }

  Future<void> fetchChatMessage() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      final response = await http.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/get-ChatMessage',
        ),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({"problem_id": widget.problemId}),
      );

      if (response.statusCode != 200) return;

      final List<dynamic> data = jsonDecode(response.body);
      final formatter = DateFormat('HH:mm');

      final List<Map<String, dynamic>> newMessages = data.map((msg) {
        return {
          "text": msg["message_text"],
          "isSender": msg["user_senderid"] == adUser,
          "time": formatter.format(
            DateTime.tryParse(msg["created_at"] ?? "") ?? DateTime.now(),
          ),
          "status": msg["notification_status"],
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(newMessages);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetchChatMessage: $e");
    } finally {
      _isFetching = false;
    }
  }

  Future<void> sendMessage(String textMessage) async {
    try {
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      await http.post(
        Uri.parse(
          'https://digitapp.rajavithi.go.th/ITService_API/api/sendMessage',
        ),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "problem_id": widget.problemId,
          "ad_user": adUser,
          "message": textMessage,
        }),
      );

      fetchChatMessage();
    } catch (e) {
      debugPrint("Error sendMessage: $e");
    }
  }

  // ======================= Lifecycle ======================= //

  @override
  void initState() {
    super.initState();

    changeChatStatus();
    fetchChatMessage();
    checkProblemStatus();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) fetchChatMessage();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  // ======================= UI ======================= //

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE6EF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(size),
            Expanded(child: _buildMessageList(size)),
            _problemStatus == "เสร็จสิ้น"
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "ปัญหานี้เสร็จสิ้นแล้ว ไม่สามารถส่งข้อความได้",
                      style: TextStyle(
                        fontFamily: "Kanit",
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : _buildInputArea(size),
          ],
        ),
      ),
    );
  }

  // ---------------- Header ---------------- //
  Widget _buildHeader(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.065,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFAD3A77), Color(0xFFC23B85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            widget.problemId,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "Kanit",
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Positioned(
            left: size.width * 0.02,
            top: size.height * 0.005,
            child: IconButton(
              icon: Image.asset(
                'assets/img/left_arrow.png',
                width: size.height * 0.02,
                height: size.height * 0.02,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Message List ---------------- //
  Widget _buildMessageList(Size size) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _buildChatBubble(
          size,
          msg["text"],
          msg["isSender"],
          msg["time"],
          msg["status"],
          index == _messages.length - 1,
        );
      },
    );
  }

  // ---------------- Chat Bubble ---------------- //
  Widget _buildChatBubble(
    Size size,
    String message,
    bool isSender,
    String time,
    String? status,
    bool isLast,
  ) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: size.height * 0.006),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: size.width * 0.7),
        decoration: BoxDecoration(
          color: isSender
              ? const Color.fromARGB(255, 188, 255, 185)
              : const Color(0xFFD6F5FF),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isSender ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight:
                isSender ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontFamily: "Kanit",
                fontSize: 14,
                color: Color(0xff333333),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: "Kanit",
                    fontSize: 11,
                    color: Color(0xff777777),
                  ),
                ),
                if (isSender && isLast) ...[
                  const SizedBox(width: 6),
                  Text(
                    status == "read" ? "อ่านแล้ว" : "ยังไม่อ่าน",
                    style: const TextStyle(
                      fontFamily: "Kanit",
                      fontSize: 11,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Input Area ---------------- //
  Widget _buildInputArea(Size size) {
    return Container(
      color: const Color(0xFFFDE6EF),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.012,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "พิมพ์ข้อความ...",
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          GestureDetector(
            onTap: () {
              final text = _messageController.text.trim();
              if (text.isEmpty) return;
              sendMessage(text);
              _messageController.clear();
            },
            child: Container(
              width: size.height * 0.045,
              height: size.height * 0.045,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC1E3), Color(0xFFFFE0F0)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.send, size: 20, color: Color(0xff333333)),
            ),
          ),
        ],
      ),
    );
  }
}
