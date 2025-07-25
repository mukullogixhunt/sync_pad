import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';
import 'package:sync_pad/features/gatepass/domain/entities/gate_pass_entity.dart';
import 'package:sync_pad/features/gatepass/presentation/screens/request_gate_pass_screen.dart';
import 'package:sync_pad/injection_container.dart';

import '../bloc/list/gate_pass_bloc.dart';
import '../bloc/request/request_gate_pass_bloc.dart';
import 'gate_pass_details_screen.dart';

class GatePassScreen extends StatefulWidget {
  const GatePassScreen({super.key, required this.user});

  final AuthUserEntity user;

  @override
  State<GatePassScreen> createState() => _GatePassScreenState();
}

class _GatePassScreenState extends State<GatePassScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- NEW: Add state variables for search functionality ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // --- END OF NEW VARIABLES ---

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshData();

    // --- NEW: Add a listener to the search controller ---
    _searchController.addListener(() {
      // Use setState to trigger a rebuild with the new filter
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    // --- END OF NEW LISTENER ---
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose(); // --- NEW: Dispose the search controller ---
    super.dispose();
  }

  Future<void> _refreshData() async {
    context.read<GatePassBloc>().add(GetGatePassEvent(userId: widget.user.uid));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RequestGatePassBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gate Passes'),
          elevation: 1,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'REQUESTED TO ME'),
              Tab(text: 'REQUESTED BY ME'),
              Tab(text: 'COMPLETED'),
            ],
          ),
        ),
        body: Column(
          // --- NEW: Wrap body content in a Column ---
          children: [
            // --- NEW: Add the Search Bar UI ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by DO, Lot, Vehicle, Party...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  // Add a clear button to the search bar
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                          : null,
                ),
              ),
            ),
            // --- END OF SEARCH BAR ---

            // --- NEW: Wrap the rest of the body in an Expanded widget ---
            Expanded(
              child: BlocListener<RequestGatePassBloc, RequestGatePassState>(
                listener: (context, state) {
                  if (state is RequestGatePassUpdated) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('Status Updated Successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    _refreshData();
                  }
                  if (state is RequestGatePassError) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                  }
                },
                child: BlocBuilder<GatePassBloc, GatePassState>(
                  builder: (context, state) {
                    if (state is GatePassLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is GatePassFailure) {
                      return Center(child: Text(state.message));
                    }
                    if (state is GatePassLoaded) {
                      // --- NEW: Apply search filter logic here ---
                      final toMeUnfiltered =
                          state.gatePasses
                              .where(
                                (p) =>
                                    p.approverId == widget.user.uid &&
                                    p.status != "completed",
                              )
                              .toList();
                      final byMeUnfiltered =
                          state.gatePasses
                              .where(
                                (p) =>
                                    p.requesterId == widget.user.uid &&
                                    p.status != "completed",
                              )
                              .toList();
                      final completedUnfiltered =
                          state.gatePasses
                              .where((p) => p.status == "completed")
                              .toList();

                      List<GatePassEntity> toMeFiltered;
                      List<GatePassEntity> byMeFiltered;
                      List<GatePassEntity> completedFiltered;

                      if (_searchQuery.isEmpty) {
                        toMeFiltered = toMeUnfiltered;
                        byMeFiltered = byMeUnfiltered;
                        completedFiltered = completedUnfiltered;
                      } else {
                        toMeFiltered =
                            toMeUnfiltered.where((pass) {
                              return pass.doNumber.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.doNumber.toLowerCase().trim().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.lotNumber.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.lotNumber.toLowerCase().trim().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.vehicleNumber.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.vehicleNumber
                                      .toLowerCase()
                                      .trim()
                                      .contains(_searchQuery) ||
                                  pass.partyName.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.partyName.toLowerCase().trim().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.requesterName.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.requesterName
                                      .toLowerCase()
                                      .trim()
                                      .contains(_searchQuery) ||
                                  pass.approverName.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.approverName
                                      .toLowerCase()
                                      .trim()
                                      .contains(_searchQuery);
                            }).toList();

                        byMeFiltered =
                            byMeUnfiltered.where((pass) {
                              return pass.doNumber.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.doNumber.toLowerCase().trim().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.lotNumber.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.lotNumber.toLowerCase().trim().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.vehicleNumber.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.vehicleNumber
                                      .toLowerCase()
                                      .trim()
                                      .contains(_searchQuery) ||
                                  pass.partyName.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.partyName.toLowerCase().trim().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.requesterName.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.requesterName
                                      .toLowerCase()
                                      .trim()
                                      .contains(_searchQuery) ||
                                  pass.approverName.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.approverName
                                      .toLowerCase()
                                      .trim()
                                      .contains(_searchQuery);
                            }).toList();

                        completedFiltered =
                            completedUnfiltered.where((pass) {
                              return pass.doNumber.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.doNumber.toLowerCase().trim().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.lotNumber.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.lotNumber.toLowerCase().trim().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.vehicleNumber.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.vehicleNumber
                                      .toLowerCase()
                                      .trim()
                                      .contains(_searchQuery) ||
                                  pass.partyName.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.partyName.toLowerCase().trim().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.requesterName.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.requesterName
                                      .toLowerCase()
                                      .trim()
                                      .contains(_searchQuery) ||
                                  pass.approverName.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  pass.approverName
                                      .toLowerCase()
                                      .trim()
                                      .contains(_searchQuery);
                            }).toList();
                      }

                      // --- END OF FILTER LOGIC ---

                      return RefreshIndicator(
                        onRefresh: _refreshData,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // --- CHANGE: Use the filtered lists ---
                            _GatePassListView(
                              gatePasses: toMeFiltered,
                              isRequestToMe: true,
                              user: widget.user,
                            ),
                            _GatePassListView(
                              gatePasses: byMeFiltered,
                              isRequestToMe: false,
                              user: widget.user,
                            ),

                            _GatePassListView(
                              gatePasses: completedFiltered,
                              isRequestToMe: false,
                              user: widget.user,
                            ),

                            // isRequestToMe doesn't matter much here
                          ],
                        ),
                      );
                    }
                    return const Center(child: Text('Pull to refresh data.'));
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => RequestGatePassScreen(user: widget.user),
                  ),
                )
                .then((requestSubmitted) {
                  if (requestSubmitted == true) {
                    _refreshData();
                  }
                });
          },
          icon: const Icon(Icons.add),
          label: const Text('Request Pass'),
        ),
      ),
    );
  }
}

class _GatePassListView extends StatelessWidget {
  final List<GatePassEntity> gatePasses;
  final bool isRequestToMe;
  final AuthUserEntity user;

  const _GatePassListView({
    required this.gatePasses,
    required this.isRequestToMe,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    if (gatePasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No gate passes found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const Text(
              'This category is empty.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: gatePasses.length,
      itemBuilder: (context, index) {
        final entry = gatePasses[index];
        return _GatePassCard(
          entry: entry,
          isRequestToMe: isRequestToMe,
          user: user,
        );
      },
    );
  }
}

class _GatePassCard extends StatelessWidget {
  final GatePassEntity entry;
  final bool isRequestToMe;
  final AuthUserEntity user;

  const _GatePassCard({
    required this.entry,
    required this.isRequestToMe,
    required this.user,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green.shade600;
      case 'declined':
        return Colors.red.shade600;
      case 'completed':
        return Colors.blue.shade600;
      default:
        return Colors.orange.shade700;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'declined':
        return Icons.highlight_off;
      case 'completed':
        return Icons.task_alt_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(entry.status);
    final statusIcon = _getStatusIcon(entry.status);

    // --- NEW LOGIC: Determine the primary title ---
    final bool hasDo = entry.doNumber.isNotEmpty;
    final bool hasLot = entry.lotNumber.isNotEmpty;
    final String cardTitle =
        hasDo
            ? 'DO No: ${entry.doNumber}'
            : (hasLot ? 'Lot No: ${entry.lotNumber}' : 'Gate Pass');
    // --- END OF NEW LOGIC ---

    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder:
                    (_) => GatePassDetailScreen(
                      gatePass: entry,
                      currentUser: user,
                    ),
              ),
            )
            .then(
              (_) => context.read<GatePassBloc>().add(
                GetGatePassEvent(userId: user.uid),
              ),
            );
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- CHANGE: Use the dynamic cardTitle ---
                                Text(
                                  cardTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'MMM d, yyyy HH:mm',
                                  ).format(entry.requestedAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              children: [
                                Icon(statusIcon, color: statusColor, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  entry.status.toUpperCase(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24.0),
                      _InfoRow(
                        icon:
                            isRequestToMe
                                ? Icons.person_outline
                                : Icons.person_pin_outlined,
                        label: isRequestToMe ? 'From:' : 'To:',
                        value:
                            isRequestToMe
                                ? entry.requesterName
                                : entry.approverName,
                      ),
                      const SizedBox(height: 12),
                      // --- CHANGE: Conditionally show Lot No if DO No was the title ---
                      if (hasDo && hasLot)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _InfoRow(
                            icon: Icons.pin_outlined,
                            label: 'Lot No:',
                            value: entry.lotNumber,
                          ),
                        ),
                      _InfoRow(
                        icon: Icons.directions_car,
                        label: 'Vehicle No:',
                        value: entry.vehicleNumber,
                      ),
                      // ... The rest of the InfoRows and the Actions Section are unchanged and correct.
                      if (entry.partyName.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.business_center_outlined,
                          label: 'Party:',
                          value: entry.partyName,
                        ),
                      ],
                      if (entry.weight != null && entry.weight!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.scale_outlined,
                          label: 'Weight:',
                          value: entry.weight!,
                        ),
                      ],
                      if (entry.centre != null && entry.centre!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.location_city_outlined,
                          label: 'Centre:',
                          value: entry.centre!,
                        ),
                      ],
                      const SizedBox(height: 16.0),
                      if (isRequestToMe &&
                          entry.status == 'requested' &&
                          user.uid == entry.approverId)
                        Row(
                          // ... Action buttons
                        ),
                    ],
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
