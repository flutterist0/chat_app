import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_Screen.dart';
import 'package:test_app/feature/chat/presentation/screens/search_users_screen.dart';
import 'package:test_app/feature/chat/presentation/widgets/chat_list_item.dart';
import 'package:test_app/shared/routers/app_router.dart';

@RoutePage()
class ChatsListScreen extends StatelessWidget {
  final List<Chat> chats = [
    Chat(
      id: '1',
      name: 'Aysel Məmmədova',
      lastMessage: 'Salam, necəsən?',
      time: '14:23',
      unreadCount: 2,
      isOnline: true,
    ),
    Chat(
      id: '2',
      name: 'Rəşad Əliyev',
      lastMessage: 'Sabah görüşək',
      time: '13:45',
      unreadCount: 0,
      isOnline: false,
    ),
    Chat(
      id: '3',
      name: 'Günay Həsənova',
      lastMessage: 'Təşəkkürlər! 👍',
      time: '12:30',
      unreadCount: 5,
      isOnline: true,
    ),
    Chat(
      id: '4',
      name: 'Elvin Quliyev',
      lastMessage: 'Layihə hazırdır',
      time: 'Dünən',
      unreadCount: 0,
      isOnline: false,
    ),
  ];

  ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
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
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Axtarış
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Axtar...',
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.search, color: Colors.white70),
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
          // Mesajlar Siyahısı
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return ChatListItem(
                  chat: chats[index],
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ChatScreen(chat: chats[index]),
                    //   ),
                    // );
                    context.router.push(ChatRoute(chat: chats[index]));
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
        backgroundColor: Color(0xFF2563EB),
        elevation: 4.sp,
        child: Icon(Icons.add),
      ),
    );
  }
}
