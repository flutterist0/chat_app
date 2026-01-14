import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/shared/themes/app_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/feature/chat/logic/bloc/chat_list/chat_list_bloc.dart';

class ChatListHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final Function(String)? onSearchChanged;

  const ChatListHeader({
    super.key,
    required this.onMenuPressed,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppStyles.blueGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppStyles.paddingSmall),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.messagesTitle,
                    style: AppStyles.headerWhite,
                  ),
                  Row(
                    children: [
                      BlocBuilder<ChatListBloc, ChatListState>(
                        builder: (context, state) {
                          ChatFilter currentFilter = ChatFilter.all;
                          ChatSort currentSort = ChatSort.date;

                          if (state is ChatListLoaded) {
                            currentFilter = state.filter;
                            currentSort = state.sort;
                          }

                          return PopupMenuButton<dynamic>(
                            icon:
                                Icon(Icons.filter_list, color: AppStyles.white),
                            onSelected: (value) {
                              if (value is ChatFilter) {
                                context
                                    .read<ChatListBloc>()
                                    .add(ChangeFilter(value));
                              } else if (value is ChatSort) {
                                context
                                    .read<ChatListBloc>()
                                    .add(ChangeSort(value));
                              }
                            },
                            itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
                              PopupMenuItem(
                                enabled: false,
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .filter
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp)),
                              ),
                              CheckedPopupMenuItem(
                                checked: currentFilter == ChatFilter.all,
                                value: ChatFilter.all,
                                child: Text(AppLocalizations.of(context)!.all),
                              ),
                              CheckedPopupMenuItem(
                                checked: currentFilter == ChatFilter.read,
                                value: ChatFilter.read,
                                child: Text(AppLocalizations.of(context)!.read),
                              ),
                              CheckedPopupMenuItem(
                                checked: currentFilter == ChatFilter.unread,
                                value: ChatFilter.unread,
                                child:
                                    Text(AppLocalizations.of(context)!.unread),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                enabled: false,
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .sortBy
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp)),
                              ),
                              CheckedPopupMenuItem(
                                checked: currentSort == ChatSort.date,
                                value: ChatSort.date,
                                child: Text(AppLocalizations.of(context)!.date),
                              ),
                              CheckedPopupMenuItem(
                                checked: currentSort == ChatSort.name,
                                value: ChatSort.name,
                                child: Text(AppLocalizations.of(context)!.name),
                              ),
                            ],
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert, color: AppStyles.white),
                        onPressed: onMenuPressed,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: AppStyles.searchBoxDecoration,
                child: TextField(
                  style: AppStyles.inputTextWhite,
                  onChanged: onSearchChanged,
                  decoration: AppStyles.searchInputDecoration.copyWith(
                    hintText: AppLocalizations.of(context)!.searchHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
