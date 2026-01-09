import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/domain/repositories/chat_repository.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository _chatRepository;
  final FirebaseAuth _auth;
  StreamSubscription? _chatsSubscription;
  StreamSubscription? _authSubscription;

  ChatListBloc(this._chatRepository, this._auth) : super(ChatListInitial()) {
    on<LoadChats>(_onLoadChats);
    on<UpdateChats>((event, emit) => emit(ChatListLoaded(event.chats)));
    on<ChatListError>((event, emit) => emit(ChatListFailure(event.message)));

    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        add(LoadChats());
      }
    });
  }

  void _onLoadChats(LoadChats event, Emitter<ChatListState> emit) {
    emit(ChatListLoading());

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      emit(ChatListFailure("İstifadəçi tapılmadı"));
      return;
    }

    _chatsSubscription?.cancel();
    _chatsSubscription = _chatRepository.getChats(currentUser.uid).listen(
      (chats) {
        add(UpdateChats(chats));
      },
      onError: (error) {
        add(ChatListError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
