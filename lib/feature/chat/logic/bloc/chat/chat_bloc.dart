import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/data/models/message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ImagePicker _picker;
  
  StreamSubscription? _messagesSubscription;
  late String currentUserId;
  late String chatId;
  late String receiverId;
  late String receiverName;

  ChatBloc(this._firestore, this._auth, this._picker) : super(const ChatState()) {
    on<ChatStarted>(_onChatStarted);
    on<ChatUpdated>(_onChatUpdated);
    on<SendMessage>(_onSendMessage);
    on<SendImage>(_onSendImage);
    on<SetReplyMessage>((event, emit) => emit(state.copyWith(replyMessage: event.message)));
    on<CancelReply>((event, emit) => emit(state.copyWith(clearReply: true)));
    on<ChatErrorOccurred>((event, emit) => emit(state.copyWith(status: ChatStatus.failure, errorMessage: event.error)));
  }

  void _onChatStarted(ChatStarted event, Emitter<ChatState> emit) {
    emit(state.copyWith(status: ChatStatus.loading));
    
    currentUserId = _auth.currentUser!.uid;
    receiverId = event.chat.id;
    receiverName = event.chat.name;

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    chatId = ids.join("_");

    _resetUnreadCount();

    _messagesSubscription?.cancel();
    _messagesSubscription = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        return _mapDocumentToMessage(data);
      }).toList();
      add(ChatUpdated(messages));
    }, onError: (e) {
      add(ChatErrorOccurred(e.toString()));
    });
  }

  void _onChatUpdated(ChatUpdated event, Emitter<ChatState> emit) {
    emit(state.copyWith(
      status: ChatStatus.success,
      messages: event.messages,
    ));
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    if (event.text.isEmpty) return;
    await _uploadMessageToFirestore(text: event.text, type: 'text');
    emit(state.copyWith(clearReply: true)); 
  }

  Future<void> _onSendImage(SendImage event, Emitter<ChatState> emit) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: event.source,
        imageQuality: 20,
        maxWidth: 600,
      );

      if (pickedFile != null) {
        emit(state.copyWith(isUploading: true));
        
        File imageFile = File(pickedFile.path);
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64String = base64Encode(imageBytes);

        await _uploadMessageToFirestore(
          text: '',
          imageBase64: base64String,
          type: 'image',
        );

        emit(state.copyWith(isUploading: false, clearReply: true));
      }
    } catch (e) {
      emit(state.copyWith(isUploading: false, errorMessage: "Şəkil xətası: $e"));
    }
  }

  Future<void> _uploadMessageToFirestore({
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

    if (state.replyMessage != null) {
      final reply = state.replyMessage!;
      String replyPreview = reply.text.length > 50 && !reply.text.contains(' ')
          ? "📷 Şəkil"
          : reply.text;

      messageData['replyText'] = replyPreview;
      messageData['replySender'] = reply.isSentByMe ? "Sən" : receiverName;
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

  void _resetUnreadCount() async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCounts.$currentUserId': 0,
      });
    } catch (e) {
    }
  }

  Message _mapDocumentToMessage(Map<String, dynamic> data) {
    bool isMe = data['senderId'] == currentUserId;
    String type = data['type'] ?? 'text';
    String content = type == 'image' ? (data['imageBase64'] ?? '') : (data['text'] ?? '');

    return Message(
      text: content,
      isSentByMe: isMe,
      time: _formatTime(data['timestamp']),
      replyText: data['replyText'],
      replySender: data['replySender'],
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime date = timestamp.toDate();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}