import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/data/models/message.dart';
import 'package:test_app/feature/chat/logic/bloc/chat/chat_bloc.dart';
import 'package:test_app/feature/chat/presentation/widgets/chat_header.dart';
import 'package:test_app/feature/chat/presentation/widgets/chat_input_area.dart';
import 'package:test_app/feature/chat/presentation/widgets/message_bubble.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/themes/app_styles.dart';

@RoutePage()
class ChatScreen extends StatelessWidget {
  final Chat chat;

  const ChatScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatBloc>()..add(ChatStarted(chat)),
      child: _ChatView(chat: chat),
    );
  }
}

class _ChatView extends StatefulWidget {
  final Chat chat;
  const _ChatView({required this.chat});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isEmojiVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) setState(() => _isEmojiVisible = false);
    });
  }
  void _showDeleteOptions(BuildContext context, Message message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text(
                AppLocalizations.of(context)!.deleteMessageTitle,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              const SizedBox(height: 20),

              ListTile(
                leading: Icon(Icons.delete_outline, color: AppStyles.primaryBlue),
                title: Text(AppLocalizations.of(context)!.deleteForMe),
                onTap: () {
                  context.read<ChatBloc>().add(DeleteMessage(message, forEveryone: false));
                  Navigator.pop(bottomSheetContext);
                },
              ),

              if (message.isSentByMe)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(AppLocalizations.of(context)!.deleteForEveryone, style: TextStyle(color: AppStyles.red)),
                  onTap: () {
                    context.read<ChatBloc>().add(DeleteMessage(message, forEveryone: true));
                    Navigator.pop(bottomSheetContext);
                  },
                ),

              ListTile(
                leading: const Icon(Icons.close),
                title: Text(AppLocalizations.of(context)!.cancel),
                onTap: () => Navigator.pop(bottomSheetContext),
              ),
            ],
          ),
        );
      },
    );
  }
  void _toggleEmojiKeyboard() {
    if (_isEmojiVisible) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
    setState(() => _isEmojiVisible = !_isEmojiVisible);
  }

  Future<bool> _onWillPop() async {
    if (_isEmojiVisible) {
      setState(() => _isEmojiVisible = false);
      return false;
    }
    final currentBlocState = context.read<ChatBloc>().state;
    if (currentBlocState.replyMessage != null) {
      context.read<ChatBloc>().add(CancelReply());
      return false;
    }
    return true;
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    _messageController.text = _messageController.text + emoji.emoji;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Column(
          children: [
            ChatHeader(
              chat: widget.chat,
              onBackPressed: () => Navigator.pop(context),
            ),

            BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (previous, current) => previous.isUploading != current.isUploading,
              builder: (context, state) {
                 if (state.isUploading) {
                   return LinearProgressIndicator(backgroundColor: Colors.blue[100]);
                 }
                 return const SizedBox.shrink();
              },
            ),

            Expanded(
              child: Container(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.black 
                    : AppStyles.grey100,
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state.status == ChatStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.status == ChatStatus.failure) {
                      return Center(child: Text('Xəta: ${state.errorMessage}'));
                    } else if (state.messages.isEmpty) {
                      return  Center(
                          child: Text(AppLocalizations.of(context)!.noMessages,
                              style: AppStyles.emptyText));
                    }

                    return ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {

                        final message = state.messages[index];

                        return MessageBubble(
                          message: message,
                          onSwipe: (msg) {
                             context.read<ChatBloc>().add(SetReplyMessage(msg));
                             _focusNode.requestFocus();
                          },
                          onLongPress: (msg) {
                            _showDeleteOptions(context, msg);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            ChatInputArea(
              chat: widget.chat,
              controller: _messageController,
              focusNode: _focusNode,
              isEmojiVisible: _isEmojiVisible,
              onEmojiToggle: _toggleEmojiKeyboard,
              onSendPressed: () {
                context.read<ChatBloc>().add(SendMessage(_messageController.text.trim()));
                _messageController.clear();
                _scrollToBottom();
              },
              onImageSelected: (source) {
                context.read<ChatBloc>().add(SendImage(source));
              },
            ),

            if (_isEmojiVisible)
              SizedBox(
                height: 250.h,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) => _onEmojiSelected(category, emoji),
                  config: const Config(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}