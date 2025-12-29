// Dart
import 'dart:async';
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  String? _problemStatus;

  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  Timer? _timer;

  Future<void> checkProblemStatus() async {
    try {
      final url = Uri.parse('https://digitapp.rajavithi.go.th/ITService_API/api/checkProblemStatus');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"problem_id": widget.problemId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to check problem status');
      }

      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        _problemStatus = data.isNotEmpty ? data[0]['problem_status'] : null;
      });
    } catch (e) {
      debugPrint("Error checkProblemStatus: $e");
    }
  }

  Future<void> changeChatStatus() async {
    try {
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      final url = Uri.parse('https://digitapp.rajavithi.go.th/ITService_API/api/changeChatStatus');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ad_user": adUser, "problem_id": widget.problemId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load chat list');
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchchatmessage() async {
    try {
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      final url = Uri.parse('https://digitapp.rajavithi.go.th/ITService_API/api/get-ChatMessage');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"problem_id": widget.problemId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load chat messages');
      }

      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        _messages.clear();

        for (var msg in data) {
          _messages.add({
            "text": msg["message_text"],
            "isSender": msg["user_senderid"] == adUser,
            "time": DateFormat('HH:mm').format(DateTime.now()),
            "status": msg["notification_status"],
          });
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> sendMessage(String textMessage) async {
    try {
      final userData = await SessionManager.getUserData();
      final adUser = userData['userid'];

      final url = Uri.parse('https://digitapp.rajavithi.go.th/ITService_API/api/sendMessage');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "problem_id": widget.problemId,
          'ad_user': adUser,
          'message': textMessage,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load chat messages');
      }

      fetchchatmessage();
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    changeChatStatus();
    fetchchatmessage();
    checkProblemStatus(); 

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchchatmessage();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE6EF),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(size),
            Expanded(child: _buildMessageList(size)),
            if (_problemStatus == "เสร็จสิ้น")
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "ปัญหานี้เสร็จสิ้นแล้ว ไม่สามารถส่งข้อความได้",
                  style: TextStyle(
                    fontFamily: "Kanit",
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              _buildInputArea(size),
          ],
        ),
      ),
    );
  }

  // ---------------------- Header ---------------------- //
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
            style: TextStyle(
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
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------- Message List ---------------------- //
  Widget _buildMessageList(Size size) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isLast = index == _messages.length - 1;

        return _buildChatBubble(
          size,
          msg["text"],
          msg["isSender"],
          msg["time"],
          msg["status"],
          isLast,
        );
      },
    );
  }

  // ---------------------- Chat Bubble ---------------------- //
  Widget _buildChatBubble(
    Size size,
    String message,
    bool isSender,
    String time,
    String? status,
    bool isLastMessage,
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
            bottomLeft: isSender
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isSender
                ? const Radius.circular(4)
                : const Radius.circular(16),
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
          crossAxisAlignment: isSender
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
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

                if (isSender && isLastMessage) ...[
                  const SizedBox(width: 6),
                  Text(
                    status == "read" ? "อ่านแล้ว" : "ยังไม่อ่าน",
                    style: TextStyle(
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

  // ---------------------- Input Area ---------------------- //
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
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "พิมพ์ข้อความ...",
                  hintStyle: TextStyle(
                    fontFamily: "Kanit",
                    fontSize: 14,
                    color: Color(0xff888888),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: "Kanit",
                  fontSize: 14,
                  color: Color(0xff333333),
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),

          GestureDetector(
            onTap: () {
              final text = _messageController.text.trim();
              if (text.isNotEmpty) {
                sendMessage(text);
                _messageController.clear();
              }
            },
            child: Container(
              width: size.height * 0.045,
              height: size.height * 0.045,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC1E3), Color(0xFFFFE0F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
              child: const Icon(Icons.send, size: 20, color: Color(0xff333333)),
            ),
          ),
        ],
      ),
    );
  }
}
