import 'package:image_picker/image_picker.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/data/models/message.dart';

abstract class ChatRepository {
  Stream<List<Chat>> getChats(String currentUserId);
  Stream<List<Message>> getMessages(String chatId, String currentUserId);
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String currentUserId,
    required String text,
    String? type,
    String? imageBase64,
    Message? replyMessage,
    String? receiverName,
  });
  Future<void> sendImage({
    required String chatId,
    required String receiverId,
    required String currentUserId,
    required ImageSource source,
    String? receiverName,
  });
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String currentUserId,
    required bool forEveryone,
  });
  Future<void> markMessagesAsRead(String chatId, String currentUserId);
}
