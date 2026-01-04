part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState {
  final ChatStatus status;
  final List<Message> messages;
  final Message? replyMessage;
  final bool isUploading;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.replyMessage,
    this.isUploading = false,
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<Message>? messages,
    Message? replyMessage,
    bool? isUploading,
    bool clearReply = false, 
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      replyMessage: clearReply ? null : (replyMessage ?? this.replyMessage),
      isUploading: isUploading ?? this.isUploading,
      errorMessage: errorMessage,
    );
  }
}