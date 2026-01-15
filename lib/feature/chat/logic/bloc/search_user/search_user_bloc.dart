import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:test_app/feature/chat/data/models/user_profile.dart';
import 'package:test_app/feature/chat/service/friendship_service.dart';

part 'search_user_event.dart';
part 'search_user_state.dart';

class SearchUserBloc extends Bloc<SearchUserEvent, SearchUserState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FriendshipService? _friendshipService; 

  StreamSubscription? _usersSubscription;
  StreamSubscription? _followingSubscription;
  StreamSubscription? _followersSubscription;
  StreamSubscription? _requestsSubscription;
  
  String _currentQuery = ''; 
  List<UserProfile> _rawUsers = [];
  Set<String> _followingIds = {};
  Set<String> _followerIds = {};
  Map<String, FriendshipStatus> _requestStatuses = {};

  SearchUserBloc(this._firestore, this._auth, [this._friendshipService]) : super(const SearchUserState()) {
    on<LoadUsers>(_onLoadUsers);
    on<UpdateUsersList>(_onUpdateUsersList);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchErrorOccurred>((event, emit) => emit(state.copyWith(status: SearchStatus.failure, errorMessage: event.error)));
  }

  void _onLoadUsers(LoadUsers event, Emitter<SearchUserState> emit) {
    emit(state.copyWith(status: SearchStatus.loading));
    
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      emit(state.copyWith(status: SearchStatus.failure, errorMessage: "İstifadəçi tapılmadı"));
      return;
    }

    _usersSubscription?.cancel();
    _usersSubscription = _firestore.collection('users').snapshots().listen(
      (snapshot) {
        _rawUsers = snapshot.docs.map((doc) {
          final data = doc.data();
          return UserProfile(
            id: doc.id,
            name: data['name'] ?? 'Adsız',
            email: data['email'] ?? '',
            isOnline: data['isOnline'] ?? false,
            photoUrl: data['photoUrl'],
            followersCount: data['followersCount'] ?? 0,
            followingCount: data['followingCount'] ?? 0,
          );
        }).where((user) => user.id != currentUserId).toList(); 

        add(UpdateUsersList(_mergeUsers()));
      },
      onError: (error) => add(SearchErrorOccurred(error.toString())),
    );

    _followingSubscription?.cancel();
    _followingSubscription = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .snapshots()
        .listen(
      (snapshot) {
        _followingIds = snapshot.docs.map((doc) => doc.id).toSet();
        add(UpdateUsersList(_mergeUsers()));
      },
       onError: (error) => print("Following error: $error"),
    );

    _followersSubscription?.cancel();
    _followersSubscription = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('followers')
        .snapshots()
        .listen(
      (snapshot) {
        _followerIds = snapshot.docs.map((doc) => doc.id).toSet();
        add(UpdateUsersList(_mergeUsers()));
      },
       onError: (error) => print("Followers error: $error"),
    );

    _requestsSubscription?.cancel();
    _requestsSubscription = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('requests')
        .snapshots()
        .listen(
      (snapshot) {
        _requestStatuses.clear();
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final type = data['type'];
          if (type == 'outgoing') {
            _requestStatuses[doc.id] = FriendshipStatus.pendingSent;
          } else if (type == 'incoming') {
            _requestStatuses[doc.id] = FriendshipStatus.pendingReceived;
          }
        }
        add(UpdateUsersList(_mergeUsers()));
      },
       onError: (error) => print("Requests error: $error"),
    );
  }

  List<UserProfile> _mergeUsers() {
    return _rawUsers.map((user) {
      FriendshipStatus status = FriendshipStatus.none;
      
      bool iFollowThem = _followingIds.contains(user.id);
      bool theyFollowMe = _followerIds.contains(user.id);

      if (iFollowThem && theyFollowMe) {
        status = FriendshipStatus.mutual;
      } else if (iFollowThem) {
        status = FriendshipStatus.following;
      } else if (theyFollowMe) {
        status = FriendshipStatus.followedBy;
      } else if (_requestStatuses.containsKey(user.id)) {
        status = _requestStatuses[user.id]!;
      }

      return UserProfile(
        id: user.id,
        name: user.name,
        email: user.email,
        isOnline: user.isOnline,
        photoUrl: user.photoUrl,
        followersCount: user.followersCount,
        followingCount: user.followingCount,
        friendshipStatus: status,
      );
    }).toList();
  }

  void _onUpdateUsersList(UpdateUsersList event, Emitter<SearchUserState> emit) {
    final filtered = _filterUsers(event.users, _currentQuery);
    
    emit(state.copyWith(
      status: SearchStatus.success,
      allUsers: event.users,
      filteredUsers: filtered,
    ));
  }

  void _onSearchQueryChanged(SearchQueryChanged event, Emitter<SearchUserState> emit) {
    _currentQuery = event.query;
    final filtered = _filterUsers(state.allUsers, _currentQuery);
    emit(state.copyWith(filteredUsers: filtered));
  }

  List<UserProfile> _filterUsers(List<UserProfile> users, String query) {
    if (query.isEmpty) {
  
        return users.where((u) => u.friendshipStatus == FriendshipStatus.mutual).toList();
    }
    
    final lowercaseQuery = query.toLowerCase();
    return users.where((user) {
      return user.name.toLowerCase().contains(lowercaseQuery) || 
             user.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    _followingSubscription?.cancel();
    _followersSubscription?.cancel();
    _requestsSubscription?.cancel();
    return super.close();
  }
}