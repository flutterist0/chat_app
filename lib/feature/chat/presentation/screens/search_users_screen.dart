import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/data/models/user_profile.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_screen.dart';
import 'package:test_app/feature/chat/presentation/widgets/user_list_item.dart';

@RoutePage()
class SearchUsersScreen extends StatefulWidget {
  @override
  _SearchUsersScreenState createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserProfile> allUsers = [
    UserProfile(id: '5', name: 'Leyla Mahmudova', email: 'leyla@gmail.com', isOnline: true),
    UserProfile(id: '6', name: 'Kamran Əsgərov', email: 'kamran@gmail.com', isOnline: false),
    UserProfile(id: '7', name: 'Nigar Səfərova', email: 'nigar@gmail.com', isOnline: true),
    UserProfile(id: '8', name: 'Elçin Bayramov', email: 'elcin@gmail.com', isOnline: false),
    UserProfile(id: '9', name: 'Səbinə Qasımova', email: 'sabina@gmail.com', isOnline: true),
    UserProfile(id: '10', name: 'Tural Abdullayev', email: 'tural@gmail.com', isOnline: false),
    UserProfile(id: '11', name: 'Aynur Hüseynova', email: 'aynur@gmail.com', isOnline: true),
    UserProfile(id: '12', name: 'Farid Məmmədov', email: 'farid@gmail.com', isOnline: false),
  ];
  
  List<UserProfile> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = allUsers;
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = allUsers;
      } else {
        filteredUsers = allUsers.where((user) {
          return user.name.toLowerCase().contains(query.toLowerCase()) ||
                 user.email.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _startChat(UserProfile user) {
    // Yeni chat yaradılır
    Chat newChat = Chat(
      id: user.id,
      name: user.name,
      lastMessage: 'Yeni söhbət başladın',
      time: 'İndi',
      unreadCount: 0,
      isOnline: user.isOnline,
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chat: newChat),
      ),
    );
  }

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
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Yeni Mesaj',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Axtarış
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.sp, 0.sp, 16.sp, 16.sp),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterUsers,
                        decoration: InputDecoration(
                          hintText: 'İstifadəçi axtar...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterUsers('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.sp,
                            vertical: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // İstifadəçilər Siyahısı
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 80.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'İstifadəçi tapılmadı',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Başqa bir ad yoxlayın',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      return UserListItem(
                        user: filteredUsers[index],
                        onTap: () => _startChat(filteredUsers[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
