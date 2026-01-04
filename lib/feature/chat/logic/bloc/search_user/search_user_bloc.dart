import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:test_app/feature/chat/data/models/user_profile.dart';

part 'search_user_event.dart';
part 'search_user_state.dart';

class SearchUserBloc extends Bloc<SearchUserEvent, SearchUserState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription? _usersSubscription;
  
  String _currentQuery = ''; 

  SearchUserBloc(this._firestore, this._auth) : super(const SearchUserState()) {
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
        final users = snapshot.docs.map((doc) {
          final data = doc.data();
          return UserProfile(
            id: doc.id,
            name: data['name'] ?? 'Adsız',
            email: data['email'] ?? '',
            isOnline: data['isOnline'] ?? false,
          );
        }).where((user) => user.id != currentUserId).toList(); 

        add(UpdateUsersList(users));
      },
      onError: (error) {
        add(SearchErrorOccurred(error.toString()));
      },
    );
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
    if (query.isEmpty) return users;
    final lowercaseQuery = query.toLowerCase();
    
    return users.where((user) {
      return user.name.toLowerCase().contains(lowercaseQuery) || 
             user.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }
}