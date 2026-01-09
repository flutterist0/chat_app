import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/data/models/message.dart';
import 'package:test_app/feature/chat/domain/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final FirebaseAuth _auth;

  StreamSubscription? _messagesSubscription;
  late String currentUserId;
  late String chatId;
  late String receiverId;
  late String receiverName;

  ChatBloc(this._chatRepository, this._auth) : super(const ChatState()) {
    on<ChatStarted>(_onChatStarted);
    on<ChatUpdated>(_onChatUpdated);
    on<SendMessage>(_onSendMessage);
    on<SendImage>(_onSendImage);
    on<SetReplyMessage>((event, emit) => emit(state.copyWith(replyMessage: event.message)));
    on<CancelReply>((event, emit) => emit(state.copyWith(clearReply: true)));
    on<DeleteMessage>(_onDeleteMessage);
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

    _chatRepository.markMessagesAsRead(chatId, currentUserId);

    _messagesSubscription?.cancel();
    _messagesSubscription = _chatRepository.getMessages(chatId, currentUserId).listen(
      (messages) {
        _chatRepository.markMessagesAsRead(chatId, currentUserId);
        
        add(ChatUpdated(messages));
      },
      onError: (e) {
        add(ChatErrorOccurred(e.toString()));
      },
    );
  }

  Future<void> _onDeleteMessage(DeleteMessage event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.deleteMessage(
        chatId: chatId,
        messageId: event.message.id,
        currentUserId: currentUserId,
        forEveryone: event.forEveryone,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: "Silinmə xətası: $e"));
    }
  }

  void _onChatUpdated(ChatUpdated event, Emitter<ChatState> emit) {
    emit(state.copyWith(
      status: ChatStatus.success,
      messages: event.messages,
    ));
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    if (event.text.isEmpty) return;
    
    await _chatRepository.sendMessage(
      chatId: chatId,
      receiverId: receiverId,
      currentUserId: currentUserId,
      text: event.text,
      replyMessage: state.replyMessage,
      receiverName: receiverName,
    );
    
    emit(state.copyWith(clearReply: true));
  }

  Future<void> _onSendImage(SendImage event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(isUploading: true));
      
      await _chatRepository.sendImage(
        chatId: chatId,
        receiverId: receiverId,
        currentUserId: currentUserId,
        source: event.source,
        receiverName: receiverName,
      );

      emit(state.copyWith(isUploading: false, clearReply: true));
    } catch (e) {
      emit(state.copyWith(isUploading: false, errorMessage: "Şəkil xətası: $e"));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}