import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';
import 'package:sync_pad/features/auth/presentation/bloc/users/users_bloc.dart';
import 'package:sync_pad/injection_container.dart';

class ForwardTargetScreen extends StatelessWidget {
  // The current user, to exclude them from the list of targets
  final AuthUserEntity currentUser;

  const ForwardTargetScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    // Provide the UsersBloc for this screen
    return BlocProvider(
      create: (context) => sl<UsersBloc>()..add(GetAllUsersEvent()),
      child: ForwardTargetView(currentUser: currentUser),
    );
  }
}

class ForwardTargetView extends StatefulWidget {
  final AuthUserEntity currentUser;
  const ForwardTargetView({super.key, required this.currentUser});

  @override
  State<ForwardTargetView> createState() => _ForwardTargetViewState();
}

class _ForwardTargetViewState extends State<ForwardTargetView> {
  List<AuthUserEntity> _filteredUsers = [];

  void _filterUsers(String query, List<AuthUserEntity> allUsers) {
    if (query.isEmpty) {
      setState(() {
        // Exclude the current user from the list
        _filteredUsers = allUsers.where((user) => user.uid != widget.currentUser.uid).toList();
      });
    } else {
      setState(() {
        _filteredUsers = allUsers
            .where((user) =>
        user.uid != widget.currentUser.uid &&
            user.displayName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forward To...'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<UsersBloc, UsersState>(
              builder: (context, state) {
                if (state is UsersLoaded) {
                  return TextField(
                    onChanged: (query) => _filterUsers(query, state.users),
                    decoration: const InputDecoration(
                      hintText: 'Search for a user...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink(); // Hide search bar while loading
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<UsersBloc, UsersState>(
              listener: (context, state) {
                if (state is UsersLoaded) {
                  // Initialize the list when users are first loaded
                  _filterUsers('', state.users);
                }
              },
              builder: (context, state) {
                if (state is UsersLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is UsersFailure) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                if (state is UsersLoaded) {
                  if (_filteredUsers.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }
                  return ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(user.displayName.isNotEmpty ? user.displayName[0] : '?'),
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(user.email),
                        onTap: () {
                          // When a user is tapped, pop the screen and return the selected user object
                          Navigator.of(context).pop(user);
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}