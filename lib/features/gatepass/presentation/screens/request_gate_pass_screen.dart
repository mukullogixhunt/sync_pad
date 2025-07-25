import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';
import 'package:sync_pad/features/auth/presentation/bloc/users/users_bloc.dart';
import 'package:sync_pad/features/gatepass/domain/usecases/request_gate_pass_usecase.dart';
import 'package:sync_pad/injection_container.dart';

import '../../../chat/domain/entities/chats_entity.dart';
import '../../../chat/presentation/bloc/chat_details/chat_details_bloc.dart';
import '../../../chat/presentation/bloc/send_message/send_message_bloc.dart';
import '../bloc/request/request_gate_pass_bloc.dart';

class RequestGatePassScreen extends StatelessWidget {
  const RequestGatePassScreen({super.key, required this.user});

  final AuthUserEntity user;

  @override
  Widget build(BuildContext context) {
    // This provides the bloc for this screen only, which is correct
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<RequestGatePassBloc>()),
        // We also need the UsersBloc to be available
        BlocProvider(
          create: (context) => sl<UsersBloc>()..add(GetAllUsersEvent()),
        ),
      ],
      child: RequestGatePassView(user: user),
    );
  }
}

class RequestGatePassView extends StatefulWidget {
  const RequestGatePassView({super.key, required this.user});

  final AuthUserEntity user;

  @override
  State<RequestGatePassView> createState() => _RequestGatePassViewState();
}

class _RequestGatePassViewState extends State<RequestGatePassView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _lotNoController = TextEditingController();
  final TextEditingController _doNoController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _centreController = TextEditingController();
  final TextEditingController _partyNameController = TextEditingController();

  final TextEditingController _userSelectorController = TextEditingController();

  AuthUserEntity? _selectedUser;

  @override
  void dispose() {
    _lotNoController.dispose();
    _doNoController.dispose();
    _vehicleNoController.dispose();
    _weightController.dispose();
    _centreController.dispose();
    _partyNameController.dispose();
    _userSelectorController.dispose();

    super.dispose();
  }

  void _showUserSelectionDialog(List<AuthUserEntity> users) {
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Allows the modal to take up more screen height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // Use a StatefulWidget here to manage the search query state locally
        return Padding(
          padding:  EdgeInsets.only(

            bottom: MediaQuery.of(context).viewInsets.bottom,

          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              final filteredUsers =
                  users
                      .where(
                        (user) =>
                            user.displayName.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ) ||
                            user.email.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ),
                      )
                      .toList();
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.6, // Start at 60% of screen height
                maxChildSize: 0.9, // Can be dragged up to 90%
                builder: (_, scrollController) {
                  return Column(
                    mainAxisSize: MainAxisSize.min, // Important for Column sizing

                    children: [
                      // --- Modal Header ---
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Select  Approver',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      // --- Search Bar ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          onChanged: (value) {
                            setModalState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by name or email...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 20),
                      // --- User List ---
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  user.displayName.isNotEmpty
                                      ? user.displayName[0]
                                      : '?',
                                ),
                              ),
                              title: Text(user.displayName),
                              subtitle: Text(user.email),
                              onTap: () {
                                // --- This is where the selection happens ---
                                setState(() {
                                  _selectedUser = user;
                                  _userSelectorController.text =
                                      user.displayName; // Update the form field text
                                });
                                Navigator.of(context).pop(); // Close the modal
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _submitRequest() {
    // Custom validation for DO No. or Lot No.
    if (_doNoController.text.trim().isEmpty &&
        _lotNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter either a D.O. Number or a Lot Number.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop the submission if both are empty
    }

    if (_formKey.currentState!.validate()) {
      final currentUser = widget.user;
      if (_selectedUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a user to send the request to.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final params = RequestGatePassParams(
        lotNumber: _lotNoController.text.trim(),
        doNumber: _doNoController.text.trim(),
        partyName: _partyNameController.text.trim(),
        vehicleNumber: _vehicleNoController.text.trim(),
        weight:
            _weightController.text.trim().isEmpty
                ? null
                : _weightController.text.trim(),
        centre:
            _centreController.text.trim().isEmpty
                ? null
                : _centreController.text.trim(),
        requesterId: currentUser.uid,
        requesterName: currentUser.displayName,
        approverId: _selectedUser!.uid,
        approverName: _selectedUser!.displayName,
      );
      context.read<RequestGatePassBloc>().add(SubmitNewRequest(params: params));
    }
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

  String gatePassId = "";

  void _sendGatePassMessage(String chatId, String recipientId) {
    final partyName = _partyNameController.text.trim();
    final doValue = _doNoController.text.trim();
    final lotValue = _lotNoController.text.trim();

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
        referenceId: gatePassId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Gate Pass Request')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<RequestGatePassBloc, RequestGatePassState>(
            listener: (context, state) {
              if (state is RequestGatePassSuccess) {
                gatePassId = state.gatePassId;

                _findOrCreateChat(_selectedUser!, true);
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
                    const SnackBar(
                      content: Text('Request sent successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                Navigator.of(
                  context,
                ).pop(true); // Pop with true to trigger refresh
              } else if (state is ChatDetailsFailure) {
                Navigator.of(context, rootNavigator: true).pop();

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(context, "Request Details"),
                  const SizedBox(height: 16),

                  // BlocBuilder<UsersBloc, UsersState>(
                  //   builder: (context, usersState) {
                  //     if (usersState is UsersLoading) {
                  //       return const Center(child: CircularProgressIndicator());
                  //     }
                  //     if (usersState is UsersFailure) {
                  //       return Center(
                  //         child: Text(
                  //           'Failed to load users: ${usersState.message}',
                  //         ),
                  //       );
                  //     }
                  //     if (usersState is UsersLoaded) {
                  //       // Filter out the current user from the list of approvers
                  //       final availableUsers =
                  //           usersState.users
                  //               .where((user) => user.uid != widget.user.uid)
                  //               .toList();
                  //       return DropdownButtonFormField<AuthUserEntity>(
                  //         value: _selectedUser,
                  //         decoration: const InputDecoration(
                  //           labelText: 'Request To',
                  //           border: OutlineInputBorder(),
                  //           prefixIcon: Icon(Icons.person_outline),
                  //         ),
                  //         hint: const Text('Select an approver'),
                  //         items:
                  //             availableUsers
                  //                 .map(
                  //                   (user) => DropdownMenuItem<AuthUserEntity>(
                  //                     value: user,
                  //                     child: Text(user.displayName),
                  //                   ),
                  //                 )
                  //                 .toList(),
                  //         onChanged:
                  //             (user) => setState(() => _selectedUser = user),
                  //         validator:
                  //             (value) =>
                  //                 value == null
                  //                     ? 'Please select an approver'
                  //                     : null,
                  //       );
                  //     }
                  //     return const Center(
                  //       child: Text("Initializing user list..."),
                  //     );
                  //   },
                  // ),
                  BlocBuilder<UsersBloc, UsersState>(
                    builder: (context, usersState) {
                      if (usersState is UsersLoaded) {
                        final availableUsers =
                            usersState.users
                                .where((user) => user.uid != widget.user.uid)
                                .toList();
                        return TextFormField(
                          controller: _userSelectorController,
                          readOnly: true,
                          // Makes the field not editable directly
                          decoration: InputDecoration(
                            labelText: 'Request To',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person_outline),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            hintText: 'Select an approver',
                          ),
                          onTap: () {
                            // Open our custom selection modal on tap
                            _showUserSelectionDialog(availableUsers);
                          },
                          validator: (value) {
                            if (_selectedUser == null) {
                              return 'Please select an approver';
                            }
                            return null;
                          },
                        );
                      }
                      // Show a disabled field while loading/error
                      return TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Request To',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person_outline),
                          hintText:
                              usersState is UsersLoading
                                  ? 'Loading users...'
                                  : 'Could not load users',
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Required Information"),
                  const SizedBox(height: 16),

                  _buildTextFormField(
                    controller: _partyNameController,
                    labelText: 'Party Name',
                    icon: Icons.business_center_outlined,
                  ),
                  const SizedBox(height: 16.0),

                  _buildTextFormField(
                    controller: _doNoController,
                    labelText: 'D.O. No.',
                    icon: Icons.receipt_long_outlined,
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _lotNoController,
                    labelText: 'Lot No.',
                    icon: Icons.pin_outlined,
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _vehicleNoController,
                    labelText: 'Vehicle No.',
                    icon: Icons.directions_car_outlined,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Optional Information"),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _weightController,
                    labelText: 'Weight',
                    icon: Icons.scale_outlined,
                    isOptional: true,
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _centreController,
                    labelText: 'Centre',
                    icon: Icons.location_city_outlined,
                    isOptional: true,
                  ),
                  const SizedBox(height: 32.0),
                  BlocBuilder<RequestGatePassBloc, RequestGatePassState>(
                    builder: (context, formState) {
                      if (formState is RequestGatePassLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton.icon(
                        onPressed: _submitRequest,
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Submit Request'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
      ),
      validator: (value) {
        if (!isOptional && (value == null || value.trim().isEmpty)) {
          // We need to exclude the DO and Lot fields from this standard validation
          if (labelText != 'D.O. No.' && labelText != 'Lot No.') {
            return 'This field cannot be empty';
          }
        }
        return null;
      },
    );
  }
}
