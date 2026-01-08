import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/data/models/message.dart';
import 'package:test_app/feature/chat/domain/repositories/chat_repository.dart';
import 'package:test_app/feature/chat/service/chat_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService _chatService;
  final ImagePicker _picker;

  ChatRepositoryImpl(this._chatService, this._picker);

  @override
  Stream<List<Chat>> getChats(String currentUserId) {
    return _chatService.getChats(currentUserId);
  }

  @override
  Stream<List<Message>> getMessages(String chatId, String currentUserId) {
    return _chatService.getMessages(chatId, currentUserId);
  }

  @override
  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    await _chatService.markMessagesAsRead(chatId, currentUserId);
  }

  @override
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
    await _chatService.sendMessage(
      chatId: chatId,
      receiverId: receiverId,
      currentUserId: currentUserId,
      text: text,
      type: type,
      imageBase64: imageBase64,
      replyMessage: replyMessage,
      receiverName: receiverName,
    );
  }

  @override
  Future<void> sendImage({
    required String chatId,
    required String receiverId,
    required String currentUserId,
    required ImageSource source,
    String? receiverName,
  }) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 20,
      maxWidth: 600,
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);

      await _chatService.sendMessage(
        chatId: chatId,
        receiverId: receiverId,
        currentUserId: currentUserId,
        text: '',
        type: 'image',
        imageBase64: base64String,
        receiverName: receiverName,
      );
    }
  }

  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String currentUserId,
    required bool forEveryone,
  }) async {
     await _chatService.deleteMessage(
       chatId: chatId, 
       messageId: messageId, 
       currentUserId: currentUserId, 
       forEveryone: forEveryone
     );
  }
}
