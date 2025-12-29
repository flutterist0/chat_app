import 'dart:convert';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/data/models/message.dart';
import 'package:test_app/feature/chat/presentation/widgets/message_bubble.dart';

@RoutePage()
class ChatScreen extends StatefulWidget {
  final Chat chat;

  ChatScreen({required this.chat});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FocusNode _focusNode = FocusNode();

  late String currentUserId;
  late String receiverId;
  late String chatId;
  final ScrollController _scrollController = ScrollController();

  bool _isEmojiVisible = false;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Message? replyMessage;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser!.uid;
    receiverId = widget.chat.id;

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    chatId = ids.join("_");

    _resetUnreadCount();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) setState(() => _isEmojiVisible = false);
    });
  }

  void _resetUnreadCount() async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCounts.$currentUserId': 0,
      });
    } catch (e) {
      print("Sıfırlama xətası: $e");
    }
  }

  void _toggleEmojiKeyboard() {
    if (_isEmojiVisible) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
    setState(() => _isEmojiVisible = !_isEmojiVisible);
  }

  Future<bool> _onWillPop() async {
    if (_isEmojiVisible) {
      setState(() => _isEmojiVisible = false);
      return false;
    }
    if (replyMessage != null) {
      _cancelReply();
      return false;
    }
    return true;
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    _messageController.text = _messageController.text + emoji.emoji;
  }

  void _onSwipeToReply(Message message) {
    setState(() {
      replyMessage = message;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 20,
        maxWidth: 600,
      );
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        _convertAndSendBase64(imageFile);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _convertAndSendBase64(File imageFile) async {
    setState(() => _isUploading = true);
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);

      await _sendMessageToFirestore(
        text: '',
        imageBase64: base64String,
        type: 'image',
      );

      _cancelReply();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xəta: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    await _sendMessageToFirestore(text: text, type: 'text');

    _cancelReply();
    _scrollToBottom();
  }

  Future<void> _sendMessageToFirestore({
    required String text,
    String? imageBase64,
    required String type,
  }) async {
    Map<String, dynamic> messageData = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'text': text,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (imageBase64 != null) {
      messageData['imageBase64'] = imageBase64;
    }

    if (replyMessage != null) {
      String replyPreview = replyMessage!.text.length > 50 && !replyMessage!.text.contains(' ')
          ? "📷 Şəkil"
          : replyMessage!.text;

      messageData['replyText'] = replyPreview;
      messageData['replySender'] = replyMessage!.isSentByMe ? "Sən" : widget.chat.name;
    }

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    String lastMsg = type == 'image' ? '📷 Şəkil' : text;
    _updateChatLastMessage(lastMsg);
  }

  void _updateChatLastMessage(String lastMsg) async {
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [currentUserId, receiverId],
      'lastMessage': lastMsg,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCounts': {receiverId: FieldValue.increment(1)}
    }, SetOptions(merge: true));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  bool _isSameDay(Timestamp t1, Timestamp t2) {
    DateTime d1 = t1.toDate();
    DateTime d2 = t2.toDate();
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _getDateLabel(DateTime date) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));
    DateTime dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) return "Bu gün";
    if (dateToCheck == yesterday) return "Dünən";
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime date = timestamp.toDate();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildDateHeader(Timestamp timestamp) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getDateLabel(timestamp.toDate()),
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Column(
          children: [
            // --- HEADER ---
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context)),
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                        child: Center(
                            child: Text(
                                widget.chat.name.isNotEmpty
                                    ? widget.chat.name.substring(0, 1).toUpperCase()
                                    : '?',
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.chat.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis),
                            Text(widget.chat.isOnline ? 'Onlayn' : 'Oflayn',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isUploading) LinearProgressIndicator(backgroundColor: Colors.blue[100]),

            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text('Xəta'));
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator());

                    var docs = snapshot.data!.docs;


                    if (docs.isEmpty) {
                      return Center(
                          child: Text('Hələ mesaj yoxdur.',
                              style: TextStyle(color: Colors.grey)));
                    }

                    return ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      padding: EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var data = docs[index].data() as Map<String, dynamic>;

                        bool showDateHeader = false;
                        Timestamp currentTs = data['timestamp'] ?? Timestamp.now();

                        if (index == docs.length - 1) {
                          showDateHeader = true;
                        } else {
                          var prevData = docs[index + 1].data() as Map<String, dynamic>;
                          Timestamp prevTs = prevData['timestamp'] ?? Timestamp.now();

                          showDateHeader = !_isSameDay(currentTs, prevTs);
                        }

                        bool isMe = data['senderId'] == currentUserId;
                        String type = data['type'] ?? 'text';
                        String content =
                        type == 'image' ? (data['imageBase64'] ?? '') : (data['text'] ?? '');

                        String? replyTxt = data['replyText'];
                        String? replySndr = data['replySender'];

                        Message message = Message(
                          text: content,
                          isSentByMe: isMe,
                          time: _formatTime(data['timestamp']),
                          replyText: replyTxt,
                          replySender: replySndr,
                        );

                        return Column(
                          children: [
                            if (showDateHeader) _buildDateHeader(currentTs),
                            MessageBubble(
                              message: message,
                              onSwipe: _onSwipeToReply,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // --- INPUT AREA ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    if (replyMessage != null)
                      Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            Icon(Icons.reply, color: Color(0xFF2563EB)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Replying to ${replyMessage!.isSentByMe ? 'Özünə' : widget.chat.name}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                  ),
                                  Text(
                                    replyMessage!.text.length > 50 &&
                                        !replyMessage!.text.contains(' ')
                                        ? "📷 Şəkil"
                                        : replyMessage!.text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.grey),
                              onPressed: _cancelReply,
                            )
                          ],
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                                _isEmojiVisible
                                    ? Icons.keyboard
                                    : Icons.emoji_emotions_outlined,
                                color: Colors.grey[600]),
                            onPressed: _toggleEmojiKeyboard,
                          ),
                          IconButton(
                            icon: Icon(Icons.image_outlined, color: Colors.grey[600]),
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                          IconButton(
                            icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[600]),
                            onPressed: () => _pickImage(ImageSource.camera),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _messageController,
                                decoration: InputDecoration(
                                    hintText: 'Mesaj yazın...',
                                    border: InputBorder.none,
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                                color: Color(0xFF2563EB), shape: BoxShape.circle),
                            child: IconButton(
                              icon: Icon(Icons.send, color: Colors.white, size: 20),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isEmojiVisible)
              SizedBox(
                height: 250.h,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) => _onEmojiSelected(category, emoji),
                  config: Config(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}