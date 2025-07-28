import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:sync_pad/core/utils/media_picker_service.dart'; // Import services
import 'package:sync_pad/core/utils/permission_service.dart'; // Import services

import '../../../auth/domain/entities/auth_user_entity.dart';
import '../../../gatepass/domain/entities/gate_pass_entity.dart';
import '../../../gatepass/domain/usecases/request_gate_pass_usecase.dart';
import '../../../gatepass/presentation/bloc/request/request_gate_pass_bloc.dart';
import '../../domain/entities/chats_entity.dart';
import '../../domain/entities/messages_entity.dart';
import '../bloc/chat_details/chat_details_bloc.dart';
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

  final List<MessagesEntity> _sendingMessages = [];

  ///gate pass forward
  String _forwardedGatePassId = "";
  AuthUserEntity? _forwardedToUser;
  GatePassEntity? _forwardedGatePass;

  void _findOrCreateChat(AuthUserEntity participant2, bool isMatched) {
    context.read<ChatDetailsBloc>().add(
      CheckOrCreateChatEvent(
        user: ChatUserEntity(
          userId: widget.user.uid,
          name: widget.user.displayName,
          unreadCount: 0,
          profilePicture: "",
          lastOnline: DateTime.now(),
          email: widget.user.email,
        ),
        targetUser: ChatUserEntity(
          userId: participant2.uid,
          name: participant2.displayName,
          unreadCount: 0,
          profilePicture: "",
          lastOnline: DateTime.now(),
          email: participant2.email,
        ),
        isMatched: isMatched,
      ),
    );
  }


  void _sendGatePassMessage(String chatId, String recipientId) {
    final partyName = _forwardedGatePass!.partyName;
    final doValue = _forwardedGatePass!.doNumber;
    final lotValue = _forwardedGatePass!.lotNumber;

    String formattedMessage;
    if (doValue.isNotEmpty && lotValue.isNotEmpty) {
      formattedMessage =
          'Party Name: $partyName\nDO No: $doValue\nLot No: $lotValue';
    } else if (doValue.isNotEmpty) {
      formattedMessage = 'Party Name: $partyName\nDO No: $doValue';
    } else {
      formattedMessage = 'Party Name: $partyName\nLot No: $lotValue';
    }

    context.read<SendMessageBloc>().add(
      SendSystemMessageEvent(
        chatId: chatId,
        sentBy: widget.user.uid,
        recipientId: recipientId,
        message: formattedMessage,
        type: 'gatepass',
        referenceId: _forwardedGatePassId,
      ),
    );
  }

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
    // 1. Create the temporary message entity
    final tempMessage = MessagesEntity(
      messageId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      // Unique temp ID
      storagePath: imageFile.path,
      // The local path for the thumbnail
      message: '',
      sentBy: widget.user.uid,
      status: 'sending',
      // <-- The crucial status
      type: 'image',
      timestamp: DateTime.now(),
    );

    // 2. Add it to the local list and rebuild the UI
    setState(() {
      _sendingMessages.add(tempMessage);
    });

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
    final tempMessage = MessagesEntity(
      messageId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      storagePath: docFile.path,
      message: path.basename(docFile.path),
      sentBy: widget.user.uid,
      status: 'sending',
      type: 'file',
      // or 'pdf'
      timestamp: DateTime.now(),
    );

    setState(() {
      _sendingMessages.add(tempMessage);
    });

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
        body: MultiBlocListener(
          listeners: [
            BlocListener<SendMessageBloc, SendMessageState>(
              listener: (context, state) {
                if (state is MessageSent || state is SendMessageFailure) {
                  setState(() {
                    _sendingMessages.clear();
                  });
                }
                if (state is MessageSent) {
                  FocusScope.of(context).unfocus();
                  if (_showEmojiPicker) {
                    setState(() {
                      _showEmojiPicker = false;
                    });
                  }
                }
                if (state is SendMessageFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),

            BlocListener<RequestGatePassBloc, RequestGatePassState>(
              listener: (context, state) {
                if (state is RequestGatePassSuccess) {
                  _forwardedGatePassId = state.gatePassId;

                  _findOrCreateChat(_forwardedToUser!, true);
                }
                if (state is RequestGatePassError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            BlocListener<ChatDetailsBloc, ChatDetailsState>(
              listener: (context, state) {
                if (state is ChatDetailsLoaded) {
                  Navigator.of(context, rootNavigator: true).pop();

                  final chat = state.chat;

                  final recipient = chat.participants.firstWhere(
                    (participant) => participant.userId != widget.user.uid,
                  );
                  _sendGatePassMessage(chat.chatId, recipient.userId);

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                       SnackBar(
                        content: Text('Gate pass forwarded to ${_forwardedToUser!.displayName}'),
                        backgroundColor: Colors.blue,
                      ),
                    );

                } else if (state is ChatDetailsFailure) {
                  Navigator.of(context, rootNavigator: true).pop();

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
            ),
          ],
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
                      final allMessages = [
                        ..._sendingMessages.reversed,
                        ...state.messages,
                      ];

                      if (allMessages.isEmpty) {
                        return const Center(
                          child: Text('No messages yet. Say hello!'),
                        );
                      }

                      return ListView.builder(
                        // ... your ListView properties are fine
                        reverse: true,
                        itemCount: allMessages.length,
                        itemBuilder: (context, index) {
                          final message =
                              allMessages[index]; // Now using the combined list
                          final isMe = message.sentBy == widget.user.uid;
                          return MessageBubble(
                            message: message,
                            isMe: isMe,
                            currentUser: widget.user,
                            onGatePassForward: (selectedUser, gatePass) {
                              final newParams = RequestGatePassParams(
                                lotNumber: gatePass.lotNumber,
                                doNumber: gatePass.doNumber,
                                vehicleNumber: gatePass.vehicleNumber,
                                weight: gatePass.weight,
                                centre: gatePass.centre,
                                partyName: gatePass.partyName,
                                requesterId: widget.user.uid,
                                requesterName: widget.user.displayName,
                                approverId: selectedUser.uid,
                                approverName: selectedUser.displayName,
                              );

                              _forwardedToUser = selectedUser;
                              _forwardedGatePass = gatePass;

                              context.read<RequestGatePassBloc>().add(
                                SubmitNewRequest(params: newParams),
                              );
                            },
                          );
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
                      _messageController.text =
                          _messageController.text.characters
                              .skipLast(1)
                              .toString();
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
