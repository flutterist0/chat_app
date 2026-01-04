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
import 'package:test_app/feature/chat/presentation/widgets/message_bubble.dart';
import 'package:test_app/shared/injection_container.dart';

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
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context)),
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                        child: Center(
                            child: Text(
                                widget.chat.name.isNotEmpty
                                    ? widget.chat.name.substring(0, 1).toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.chat.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis),
                            Text(widget.chat.isOnline ? 'Onlayn' : 'Oflayn',
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                color: Colors.grey[100],
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state.status == ChatStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.status == ChatStatus.failure) {
                      return Center(child: Text('Xəta: ${state.errorMessage}'));
                    } else if (state.messages.isEmpty) {
                      return const Center(
                          child: Text('Hələ mesaj yoxdur.',
                              style: TextStyle(color: Colors.grey)));
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
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    BlocBuilder<ChatBloc, ChatState>(
                      buildWhen: (previous, current) => previous.replyMessage != current.replyMessage,
                      builder: (context, state) {
                        if (state.replyMessage == null) return const SizedBox.shrink();

                        return Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[200],
                          child: Row(
                            children: [
                              const Icon(Icons.reply, color: Color(0xFF2563EB)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Replying to ${state.replyMessage!.isSentByMe ? 'Özünə' : widget.chat.name}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                    ),
                                    Text(
                                      state.replyMessage!.text.length > 50 &&
                                              !state.replyMessage!.text.contains(' ')
                                          ? "📷 Şəkil"
                                          : state.replyMessage!.text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  context.read<ChatBloc>().add(CancelReply());
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                                _isEmojiVisible
                                    ? Icons.keyboard
                                    : Icons.emoji_emotions_outlined,
                                color: Colors.grey[600]),
                            onPressed: _toggleEmojiKeyboard,
                          ),
                          IconButton(
                            icon: Icon(Icons.image_outlined, color: Colors.grey[600]),
                            onPressed: () => context.read<ChatBloc>().add(SendImage(ImageSource.gallery)),
                          ),
                          IconButton(
                            icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[600]),
                            onPressed: () => context.read<ChatBloc>().add(SendImage(ImageSource.camera)),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _messageController,
                                decoration: const InputDecoration(
                                    hintText: 'Mesaj yazın...',
                                    border: InputBorder.none,
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: const BoxDecoration(
                                color: Color(0xFF2563EB), shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white, size: 20),
                              onPressed: () {
                                context.read<ChatBloc>().add(SendMessage(_messageController.text.trim()));
                                _messageController.clear();
                                _scrollToBottom();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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