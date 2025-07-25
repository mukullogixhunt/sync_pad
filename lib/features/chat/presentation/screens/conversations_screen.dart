import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_pad/features/auth/presentation/bloc/users/users_bloc.dart';
import 'package:sync_pad/features/chat/domain/entities/chats_entity.dart';
import 'package:sync_pad/features/chat/presentation/bloc/chats/chats_bloc.dart';

import '../../../auth/domain/entities/auth_user_entity.dart';
import '../../../gatepass/presentation/screens/gate_pass_screen.dart';
import '../bloc/chat_details/chat_details_bloc.dart';
import 'chat_message_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key, required this.user});

  final AuthUserEntity user;

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    context.read<ChatsBloc>().add(
      GetChatsForUserEvent(userId: widget.user.uid),
    );
    super.initState();
  }

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

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Just now'; // Special case for less than a minute ago
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(onPressed: () {


            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => GatePassScreen( user: widget.user),
              ),
            );

          }, icon: const Icon(Icons.assignment)),
        ],
      ),
      body: BlocListener<ChatDetailsBloc, ChatDetailsState>(
        listener: (context, state) {
          if (state is ChatDetailsLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is ChatDetailsLoaded) {
            Navigator.of(context, rootNavigator: true).pop();

            final chat = state.chat;

            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => ChatMessageScreen(chat: chat, user: widget.user),
              ),
            );
          } else if (state is ChatDetailsFailure) {
            Navigator.of(context, rootNavigator: true).pop();

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (query) {},
                  decoration: const InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                ),
              ),
            ),

            _buildSectionHeader(context, "Chats"),

            BlocBuilder<ChatsBloc, ChatsState>(
              builder: (context, state) {
                if (state is ChatsLoading) {
                  return _buildLoader(context);
                }
                if (state is ChatsLoaded) {
                  if (state.chats.isEmpty) {
                    return _buildEmptySection(
                      context,
                      "You have no active chats.",
                    );
                  }

                  return _buildChatRoomsList(context, state.chats);
                }

                return _buildEmptySection(context, "You have no active chats.");
              },
            ),

            _buildSectionHeader(context, "Discover Users"),

            BlocBuilder<UsersBloc, UsersState>(
              builder: (context, state) {
                if (state is UsersLoading) {
                  return _buildLoader(context);
                }
                if (state is UsersLoaded) {
                  return _buildUsersList(context, state.users);
                }

                return _buildEmptySection(context, "No other users found.");
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEmptySection(BuildContext context, String text) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildLoader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(child: CircularProgressIndicator()),
    );
  }

  SliverList _buildChatRoomsList(
    BuildContext context,
    List<ChatsEntity> chatList,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final chat = chatList[index];
        final chatUser = chat.participants.firstWhere(
          (participant) => participant.userId != widget.user.uid,
        );

        return ListTile(
          leading: CircleAvatar(
            child: Text(chatUser.name.isNotEmpty ? chatUser.name[0] : '?'),
          ),
          title: Text(
            chatUser.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${chat.lastMessageSenderId == widget.user.uid ? 'You: ' : ''}${chat.lastMessage}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                timeAgo(chat.lastMessageTimestamp),
                style: Theme.of(context).textTheme.bodySmall,
              ),

              if (chatUser.unreadCount > 0)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${chatUser.unreadCount}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),

          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => ChatMessageScreen(chat: chat, user: widget.user),
              ),
            );
          },
        );
      }, childCount: chatList.length),
    );
  }

  SliverList _buildUsersList(BuildContext context, List<AuthUserEntity> users) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              user.displayName.isNotEmpty ? user.displayName[0] : '?',
            ),
          ),
          title: Text(user.displayName),
          subtitle: Text(user.email),
          onTap: () {
            _findOrCreateChat(user, true);
          },
        );
      }, childCount: users.length),
    );
  }
}
