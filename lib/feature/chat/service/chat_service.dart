import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/data/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Chat>> getChats(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      return await _mapQuerySnapshotToChats(snapshot, currentUserId);
    });
  }

  Stream<List<Message>> getMessages(String chatId, String currentUserId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
              (doc) => _mapDocumentToMessage(doc.id, doc.data(), currentUserId))
          .where((msg) => msg != null)
          .cast<Message>()
          .toList();
    });
  }

  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }

    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCounts.$currentUserId': 0,
      });
    } catch (e) {}
  }

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String currentUserId,
    required String text,
    String? type = 'text',
    String? imageBase64,
    Message? replyMessage,
    String? receiverName,
  }) async {
    Map<String, dynamic> messageData = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'text': text,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'deletedBy': [],
    };

    if (imageBase64 != null) messageData['imageBase64'] = imageBase64;

    if (replyMessage != null) {
      String replyPreview =
          replyMessage.text.length > 50 && !replyMessage.text.contains(' ')
              ? "📷 Şəkil"
              : replyMessage.text;

      messageData['replyText'] = replyPreview;
      messageData['replySender'] =
          replyMessage.isSentByMe ? "Sən" : (receiverName ?? "İstifadəçi");
    }

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    String lastMsg = type == 'image'
        ? '📷 Şəkil'
        : (type == 'audio' ? '🎤 Səsli mesaj' : text);

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [currentUserId, receiverId],
      'lastMessage': lastMsg,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCounts': {receiverId: FieldValue.increment(1)}
    }, SetOptions(merge: true));
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String currentUserId,
    required bool forEveryone,
  }) async {
    if (forEveryone) {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } else {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'deletedBy': FieldValue.arrayUnion([currentUserId])
      });
    }
  }

  Message? _mapDocumentToMessage(
      String docId, Map<String, dynamic> data, String currentUserId) {
    List<dynamic> deletedBy = data['deletedBy'] ?? [];
    if (deletedBy.contains(currentUserId)) {
      return null;
    }

    bool isMe = data['senderId'] == currentUserId;
    String type = data['type'] ?? 'text';
    String content = type == 'image'
        ? (data['imageBase64'] ?? '')
        : (type == 'audio'
            ? (data['audioBase64'] ?? '')
            : (data['text'] ?? ''));

    return Message(
      id: docId,
      text: content,
      isSentByMe: isMe,
      time: _formatTime(data['timestamp']),
      replyText: data['replyText'],
      replySender: data['replySender'],
      type: type,
      isRead: data['isRead'] ?? false,
    );
  }

  Future<List<Chat>> _mapQuerySnapshotToChats(
      QuerySnapshot snapshot, String currentUserId) async {
    List<Future<Chat?>> futures = snapshot.docs.map((doc) async {
      var chatData = doc.data() as Map<String, dynamic>;
      List<dynamic> participants = chatData['participants'] ?? [];

      String otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isEmpty) return null;

      var userDoc = await _firestore.collection('users').doc(otherUserId).get();
      var userData = userDoc.data();

      String name = userData?['name'] ?? 'Naməlum';
      bool isOnline = userData?['isOnline'] ?? false;

      Map<String, dynamic> unreadCounts = chatData['unreadCounts'] ?? {};
      int myUnreadCount = unreadCounts[currentUserId] ?? 0;

      return Chat(
        id: otherUserId,
        name: name,
        lastMessage: chatData['lastMessage'] ?? '',
        time: _formatTimestamp(chatData['lastMessageTime']),
        unreadCount: myUnreadCount,
        isOnline: isOnline,
      );
    }).toList();

    var results = await Future.wait(futures);
    return results.whereType<Chat>().toList();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime date = timestamp.toDate();
    DateTime now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day}/${date.month}";
    }
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime date = timestamp.toDate();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
