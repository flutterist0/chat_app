import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/chat/data/models/user_profile.dart';
import 'package:test_app/feature/chat/presentation/widgets/user_list_item.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/shared/routers/app_router.dart';

@RoutePage()
class FollowersScreen extends StatelessWidget {
  final String userId;
  const FollowersScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return _RelationshipView(userId: userId, type: 'followers', title: 'Followers'); // Localize later
  }
}

@RoutePage()
class FollowingScreen extends StatelessWidget {
  final String userId;
  const FollowingScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return _RelationshipView(userId: userId, type: 'following', title: 'Following'); // Localize later
  }
}

class _RelationshipView extends StatelessWidget {
  final String userId;
  final String type; // 'followers' or 'following'
  final String title;

  const _RelationshipView({required this.userId, required this.type, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).collection(type).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noUsersFound));
          }

          final docs = snapshot.data!.docs;
          
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docData = docs[index].data() as Map<String, dynamic>;
              final targetUid = docData['uid'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(targetUid).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox.shrink(); // Loading or error
                  
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (userData == null) return const SizedBox.shrink();

                  final user = UserProfile(
                    id: targetUid,
                    name: userData['name'] ?? 'Unknown',
                    email: userData['email'] ?? '',
                    isOnline: userData['isOnline'] ?? false,
                    photoUrl: userData['photoUrl'],
                  );

                  return UserListItem(
                    user: user,
                    onTap: () async {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser == null) return;
                      
                      // Check for mutual connection
                      bool isMutual = false;
                      
                      if (type == 'followers') {
                        // They follow me. Do I follow them?
                        final doc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .collection('following')
                            .doc(targetUid)
                            .get();
                        isMutual = doc.exists;
                      } else {
                         // I follow them. Do they follow me?
                        final doc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .collection('followers')
                            .doc(targetUid)
                            .get();
                        isMutual = doc.exists;
                      }

                      if (isMutual) {
                        final chat = Chat(
                          id: user.id,
                          name: user.name,
                          lastMessage: AppLocalizations.of(context)!.newChat,
                          time: AppLocalizations.of(context)!.now,
                          unreadCount: 0,
                          isOnline: user.isOnline,
                          photoUrl: user.photoUrl,
                        );
                        context.router.push(ChatRoute(chat: chat));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Söhbət etmək üçün dost olmalısınız (qarşılıqlı takib)"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
