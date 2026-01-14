import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/logic/bloc/chat/chat_bloc.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/shared/themes/app_styles.dart';

class ChatInputArea extends StatelessWidget {
  final Chat chat;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEmojiVisible;
  final VoidCallback onEmojiToggle;
  final VoidCallback onSendPressed;
  final Function(ImageSource) onImageSelected;

  const ChatInputArea({
    super.key,
    required this.chat,
    required this.controller,
    required this.focusNode,
    required this.isEmojiVisible,
    required this.onEmojiToggle,
    required this.onSendPressed,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.chatInputAreaDecorationAdaptive(context),
      child: SafeArea(
        child: Column(
          children: [
            BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (previous, current) =>
                  previous.replyMessage != current.replyMessage,
              builder: (context, state) {
                if (state.replyMessage == null) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: AppStyles.replyPanelDecoration(context),
                  child: Row(
                    children: [
                      Icon(Icons.reply, color: AppStyles.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${AppLocalizations.of(context)!.replyingTo} ${state.replyMessage!.isSentByMe ? AppLocalizations.of(context)!.yourself : chat.name}",
                              style: AppStyles.replyName,
                            ),
                            Text(
                              state.replyMessage!.text.length > 50 &&
                                      !state.replyMessage!.text.contains(' ')
                                  ? AppLocalizations.of(context)!.photo
                                  : state.replyMessage!.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.replyContent,
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
                        isEmojiVisible
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                        color: AppStyles.grey600),
                    onPressed: onEmojiToggle,
                  ),
                  IconButton(
                    icon: Icon(Icons.image_outlined, color: AppStyles.grey600),
                    onPressed: () => onImageSelected(ImageSource.gallery),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined, color: AppStyles.grey600),
                    onPressed: () => onImageSelected(ImageSource.camera),
                  ),
                  Expanded(
                    child: Container(
                      decoration: AppStyles.inputContainerDecoration(context),
                      child: TextField(
                        focusNode: focusNode,
                        controller: controller,
                        decoration:  InputDecoration(
                            hintText: AppLocalizations.of(context)!.typeMessage,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: AppStyles.sendButtonDecoration,
                    child: IconButton(
                      icon: Icon(Icons.send, color: AppStyles.white, size: 20),
                      onPressed: onSendPressed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
