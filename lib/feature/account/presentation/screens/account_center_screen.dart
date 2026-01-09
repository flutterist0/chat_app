import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/feature/account/logic/bloc/account_bloc.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/routers/app_router.dart';
import 'package:test_app/shared/themes/app_styles.dart';

@RoutePage()
class AccountCenterScreen extends StatefulWidget {
  const AccountCenterScreen({super.key});

  @override
  State<AccountCenterScreen> createState() => _AccountCenterScreenState();
}

class _AccountCenterScreenState extends State<AccountCenterScreen> {
  String? _initialUserId;

  @override
  void initState() {
    super.initState();
    _initialUserId = getIt<FirebaseAuth>().currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AccountBloc>()..add(LoadAccounts()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Hesab Mərkəzi",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is AccountLoaded) {
              if (state.currentUserId != _initialUserId) {
                context.router.replaceAll([const ChatsListRoute()]);
              }
            }
          },
          builder: (context, state) {
            if (state is AccountLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is AccountError) {
              return Center(child: Text("Xəta: ${state.message}"));
            } else if (state is AccountLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.accounts.length,
                      padding: EdgeInsets.all(16.sp),
                      itemBuilder: (context, index) {
                        final account = state.accounts[index];
                        final isCurrent = account.uid == state.currentUserId;

                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: isCurrent
                                ? BorderSide(color: AppStyles.primaryBlue, width: 2)
                                : BorderSide.none,
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12.sp),
                            leading: CircleAvatar(
                              radius: 25.r,
                              backgroundImage: account.photoUrl != null
                                  ? NetworkImage(account.photoUrl!)
                                  : null,
                              child: account.photoUrl == null
                                  ? Icon(Icons.person, color: Colors.white)
                                  : null,
                              backgroundColor: AppStyles.primaryBlue.withOpacity(0.7),
                            ),
                            title: Text(
                              account.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            subtitle: Text(account.email),
                            trailing: isCurrent
                                ? Icon(Icons.check_circle, color: AppStyles.primaryBlue)
                                : IconButton(
                                    icon: Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () {
                                      _showRemoveDialog(context, account);
                                    },
                                  ),
                            onTap: () {
                              if (!isCurrent) {
                                _showSwitchDialog(context, account);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_initialUserId == null) {
                            Navigator.pop(context);
                          } else {
                            context.router.push(LoginRoute());
                          }
                        },
                        icon: Icon(Icons.add),
                        label: Text(_initialUserId == null ? "Yeni hesab ilə giriş" : "Hesab əlavə et"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          backgroundColor: AppStyles.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, dynamic account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hesabı sil"),
        content: Text("${account.email} hesabını siyahıdan silmək istədiyinizə əminsiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Xeyr"),
          ),
          TextButton(
            onPressed: () {
              context.read<AccountBloc>().add(RemoveAccount(account.uid));
              Navigator.pop(ctx);
            },
            child: Text("Bəli", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSwitchDialog(BuildContext context, dynamic account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hesabı dəyiş"),
        content: Text("${account.email} hesabına keçmək istəyirsiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Xeyr"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AccountBloc>().add(SwitchAccount(account));
            },
            child: Text("Bəli"),
          ),
        ],
      ),
    );
  }
}
