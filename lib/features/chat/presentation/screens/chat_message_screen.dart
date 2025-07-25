import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_pad/core/utils/media_picker_service.dart'; // Import services
import 'package:sync_pad/core/utils/permission_service.dart'; // Import services

import '../../../auth/domain/entities/auth_user_entity.dart';
import '../../domain/entities/chats_entity.dart';
import '../bloc/messages/messages_bloc.dart';
import '../bloc/read_message/read_message_bloc.dart';
import '../bloc/send_message/send_message_bloc.dart';
import '../widgets/message_bubble.dart';

class ChatMessageScreen extends StatefulWidget {
  const ChatMessageScreen({super.key, required this.chat, required this.user});

  final ChatsEntity chat;
  final AuthUserEntity user;

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  late final ChatUserEntity otherUser;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSendButtonVisible = false;
  bool _showEmojiPicker = false;

  // Instantiate our new services
  final PermissionService _permissionService = PermissionService();
  final MediaPickerService _mediaPickerService = MediaPickerService();

  @override
  void initState() {
    // Find the other user in the chat
    otherUser = widget.chat.participants.firstWhere(
      (participant) => participant.userId != widget.user.uid,
    );

    // Fetch the messages for this chat
    context.read<MessagesBloc>().add(
      GetMessagesEvent(chatId: widget.chat.chatId),
    );

    _messageController.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
    readChatMessages();
    super.initState();
  }

  void _onTextChanged() {
    setState(() {
      _isSendButtonVisible = _messageController.text.isNotEmpty;
    });
  }

  void readChatMessages() {
    context.read<ReadMessageBloc>().add(
      ReadTextMessageEvent(
        userId: otherUser.userId,
        chatId: widget.chat.chatId,
      ),
    );
  }

  void _sendTextMessage() {
    context.read<SendMessageBloc>().add(
      SendTextMessageEvent(
        chatId: widget.chat.chatId,
        sentBy: widget.user.uid,
        recipientId: otherUser.userId,
        message: _messageController.text,
      ),
    );
    _messageController.clear();
  }

  void _sendImageMessage(File imageFile) {
    context.read<SendMessageBloc>().add(
      SendImageMessageEvent(
        chatId: widget.chat.chatId,
        sentBy: widget.user.uid,
        recipientId: otherUser.userId,
        imageFile: imageFile,
      ),
    );
  }

  void _sendDocumentMessage(File docFile) {
    context.read<SendMessageBloc>().add(
      SendDocumentMessageEvent(
        chatId: widget.chat.chatId,
        sentBy: widget.user.uid,
        recipientId: otherUser.userId,
        docFile: docFile,
      ),
    );
  }

  // --- NEW METHODS FOR ATTACHMENTS ---

  // REPLACE your old _onEmojiIconPressed method with this one.
  void _onEmojiIconPressed() {
    // If the emoji picker is already visible, tapping the icon should open the keyboard.
    if (_showEmojiPicker) {
      _focusNode.requestFocus();
      setState(() {
        _showEmojiPicker = false;
      });
    }
    // If the keyboard is visible, tapping the icon should hide it and show the picker.
    else if (_focusNode.hasFocus) {
      FocusScope.of(context).unfocus(); // Hide keyboard first
      // Use a small delay to allow the keyboard to hide before showing the picker
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _showEmojiPicker = true;
          });
        }
      });
    }
    // If neither is visible, just show the picker.
    else {
      setState(() {
        _showEmojiPicker = true;
      });
    }
  }

  void _onAttachmentPressed() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final hasPermission = await _permissionService
                        .requestPhotosPermission(context);
                    if (hasPermission) {
                      final imageFile =
                          await _mediaPickerService.pickImageFromGallery();
                      if (imageFile != null) {
                        _sendImageMessage(imageFile);
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Document'),
                  onTap: () async {
                    Navigator.pop(context);
                    final docFile = await _mediaPickerService.pickDocument();
                    if (docFile != null) {
                      _sendDocumentMessage(docFile);
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _onCameraPressed() async {
    final hasPermission = await _permissionService.requestCameraPermission(
      context,
    );
    if (hasPermission) {
      final imageFile = await _mediaPickerService.pickImageFromCamera();
      if (imageFile != null) {
        context.read<SendMessageBloc>().add(
          SendImageMessageEvent(
            chatId: widget.chat.chatId,
            sentBy: widget.user.uid,
            recipientId: otherUser.userId,
            imageFile: imageFile,
          ),
        );
      }
    }
  }

  // --- END OF NEW METHODS ---

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showEmojiPicker,
      onPopInvokedWithResult: (didPop, __) {
        if (!didPop && _showEmojiPicker) {
          setState(() {
            _showEmojiPicker = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: _buildAppBar(context),
        body: BlocListener<SendMessageBloc, SendMessageState>(
          listener: (context, state) {
            if (state is MessageSent) {
              FocusScope.of(context).unfocus();
              if (_showEmojiPicker) {
                setState(() {
                  _showEmojiPicker = false;
                });
              }
            }
          },
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<MessagesBloc, MessagesState>(
                  builder: (context, state) {
                    if (state is MessagesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is MessagesFailure) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    if (state is MessagesLoaded) {
                      if (state.messages.isEmpty) {
                        return const Center(
                          child: Text('No messages yet. Say hello!'),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          final isMe = message.sentBy == widget.user.uid;
                          return MessageBubble(message: message, isMe: isMe, currentUser: widget.user,);
                          // return _MessageBubble(message: message, isMe: isMe);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              _buildMessageInput(context),

              // --- THIS IS THE CORRECT EMOJI PICKER IMPLEMENTATION ---
              Offstage(
                offstage: !_showEmojiPicker,
                child: SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _messageController.text += emoji.emoji;
                    },
                    onBackspacePressed: () {
                      _messageController.text = _messageController.text.characters.skipLast(1).toString();
                    },
                    config: Config(
                      height: 250,
                      checkPlatformCompatibility: true,
                      emojiViewConfig: EmojiViewConfig(
                        emojiSizeMax: 28 * (Platform.isIOS ? 1.1 : 1.0),
                        backgroundColor: const Color(0xFFF2F2F2),
                      ),
                      skinToneConfig: const SkinToneConfig(),
                      categoryViewConfig: const CategoryViewConfig(
                        backgroundColor: Color(0xFFEBEFF2),
                        indicatorColor: Colors.blue,
                        iconColorSelected: Colors.blue,
                      ),
                      bottomActionBarConfig: const BottomActionBarConfig(
                        enabled: true,
                        backgroundColor: Color(0xFFEBEFF2),
                        buttonColor: Colors.blue,
                      ),
                      searchViewConfig: const SearchViewConfig(),
                    ),
                  ),
                ),
              ),
              // --- END OF EMOJI PICKER IMPLEMENTATION ---
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 1,
      scrolledUnderElevation: 1,
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Text(
              otherUser.name.isNotEmpty ? otherUser.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                otherUser.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                otherUser.email,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.videocam_outlined)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _showEmojiPicker
                            ? Icons.keyboard_alt_outlined
                            : Icons.emoji_emotions_outlined,
                      ),
                      onPressed: _onEmojiIconPressed,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Type a message...',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: _onAttachmentPressed,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined),
                      onPressed: _onCameraPressed,
                    ),
                  ],
                ),
              ),
            ),

            if (_isSendButtonVisible) ...[
              const SizedBox(width: 8.0),
              FloatingActionButton(
                shape: CircleBorder(),
                onPressed: () {
                  _sendTextMessage();
                },
                elevation: 1,
                child: const Icon(Icons.send),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
