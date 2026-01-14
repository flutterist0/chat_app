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

  List<Chat> _allChats = [];
  ChatFilter _currentFilter = ChatFilter.all;
  ChatSort _currentSort = ChatSort.date;

  ChatListBloc(this._chatRepository, this._auth) : super(ChatListInitial()) {
    on<LoadChats>(_onLoadChats);
    on<UpdateChats>(_onUpdateChats);
    on<ChangeFilter>(_onChangeFilter);
    on<ChangeSort>(_onChangeSort);
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

  void _onUpdateChats(UpdateChats event, Emitter<ChatListState> emit) {
    _allChats = event.chats;
    _applyFilterAndSort(emit);
  }

  void _onChangeFilter(ChangeFilter event, Emitter<ChatListState> emit) {
    _currentFilter = event.filter;
    _applyFilterAndSort(emit);
  }

  void _onChangeSort(ChangeSort event, Emitter<ChatListState> emit) {
    _currentSort = event.sort;
    _applyFilterAndSort(emit);
  }

  void _applyFilterAndSort(Emitter<ChatListState> emit) {
    List<Chat> filteredChats = _allChats.where((chat) {
      if (_currentFilter == ChatFilter.read) {
        return chat.unreadCount == 0;
      } else if (_currentFilter == ChatFilter.unread) {
        return chat.unreadCount > 0;
      }
      return true;
    }).toList();

    filteredChats.sort((a, b) {
      if (_currentSort == ChatSort.name) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      } else {
         if (a.lastMessageTime == null || b.lastMessageTime == null) return 0;
         return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      }
    });

    emit(ChatListLoaded(filteredChats, filter: _currentFilter, sort: _currentSort));
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
