import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription? _chatsSubscription;

  ChatListBloc(this._firestore, this._auth) : super(ChatListInitial()) {
    on<LoadChats>(_onLoadChats);
    on<UpdateChats>((event, emit) => emit(ChatListLoaded(event.chats)));
    on<ChatListError>((event, emit) => emit(ChatListFailure(event.message)));
  }

  void _onLoadChats(LoadChats event, Emitter<ChatListState> emit) {
    emit(ChatListLoading());

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      emit(ChatListFailure("İstifadəçi tapılmadı"));
      return;
    }

    _chatsSubscription?.cancel();
    _chatsSubscription = _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen(
      (snapshot) async {
        try {
          final List<Chat> chats = await _mapQuerySnapshotToChats(snapshot, currentUser.uid);
          add(UpdateChats(chats));
        } catch (e) {
          add(ChatListError(e.toString()));
        }
      },
      onError: (error) {
        add(ChatListError(error.toString()));
      },
    );
  }

  Future<List<Chat>> _mapQuerySnapshotToChats(QuerySnapshot snapshot, String currentUserId) async {
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

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day}/${date.month}";
    }
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}