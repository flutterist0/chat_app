import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/auth/data/auth_service.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_Screen.dart'; // ChatScreen importu
import 'package:test_app/feature/chat/presentation/screens/search_users_screen.dart'; // Search importu
import 'package:test_app/feature/chat/presentation/widgets/chat_list_item.dart';
import 'package:test_app/feature/chat/presentation/widgets/custom_drawer.dart';
import 'package:test_app/shared/routers/app_router.dart';

import '../../../../shared/services/notification_service.dart';

@RoutePage()
class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final AuthService authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        userName: currentUser?.displayName ?? '',
        userEmail: currentUser?.email ?? '',
        userImageUrl: null,
        logout: () {
          authService.signOut();
          context.router.replace(LoginRoute());
        },
      ),
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mesajlar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () async{

                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Axtar...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.sp,
                            vertical: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('participants', arrayContains: currentUser?.uid)
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Yüklənmə xətası"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64.sp, color: Colors.grey),
                        SizedBox(height: 16.h),
                        const Text("Hələ heç kimlə danışmamısınız"),
                      ],
                    ),
                  );
                }

                var chatDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index) {
                    var chatData = chatDocs[index].data() as Map<String, dynamic>;
                    List<dynamic> participants = chatData['participants'] ?? [];

                    String otherUserId = participants.firstWhere(
                          (id) => id != currentUser?.uid,
                      orElse: () => '',
                    );

                    if (otherUserId.isEmpty) return const SizedBox.shrink();

                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('users').doc(otherUserId).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                        String name = userData?['name'] ?? 'Naməlum';
                        bool isOnline = userData?['isOnline'] ?? false;

                        Map<String, dynamic> unreadCounts = chatData['unreadCounts'] ?? {};
                        int myUnreadCount = unreadCounts[currentUser?.uid] ?? 0;

                        Chat chat = Chat(
                          id: otherUserId,
                          name: name,
                          lastMessage: chatData['lastMessage'] ?? '',
                          time: _formatTimestamp(chatData['lastMessageTime']),
                          unreadCount: myUnreadCount,
                          isOnline: isOnline,
                        );

                        return ChatListItem(
                          chat: chat,
                          onTap: () {
                            context.router.push(ChatRoute(chat: chat));
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(SearchUsersRoute());
        },
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4.sp,
        child: const Icon(Icons.add),
      ),
    );
  }
}