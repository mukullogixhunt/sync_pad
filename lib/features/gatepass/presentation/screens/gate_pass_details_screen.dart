import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sync_pad/features/auth/domain/entities/auth_user_entity.dart';
import 'package:sync_pad/features/gatepass/domain/entities/gate_pass_entity.dart';
import 'package:sync_pad/features/gatepass/presentation/bloc/request/request_gate_pass_bloc.dart';
import 'package:sync_pad/injection_container.dart';

class GatePassDetailScreen extends StatelessWidget {
  final GatePassEntity gatePass;
  final AuthUserEntity currentUser;

  const GatePassDetailScreen({
    super.key,
    required this.gatePass,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RequestGatePassBloc>(),
      child: GatePassDetailView(gatePass: gatePass, currentUser: currentUser),
    );
  }
}

class GatePassDetailView extends StatelessWidget {
  final GatePassEntity gatePass;
  final AuthUserEntity currentUser;

  const GatePassDetailView({
    super.key,
    required this.gatePass,
    required this.currentUser,
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
        return Icons.check_circle;
      case 'declined':
        return Icons.cancel;
      case 'completed':
        return Icons.task_alt;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(gatePass.status);
    final statusIcon = _getStatusIcon(gatePass.status);

    final isApprover = currentUser.uid == gatePass.approverId;

    final canTakeAction = isApprover && gatePass.status == 'requested';
    final canMarkAsComplete = isApprover && gatePass.status == 'accepted';

    final bool hasDo = gatePass.doNumber.isNotEmpty;
    final bool hasLot = gatePass.lotNumber.isNotEmpty;
    final String appBarTitle = 'Gate Pass Details';

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle), elevation: 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Status Header ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: statusColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(statusIcon, color: statusColor, size: 32),
                  const SizedBox(width: 16),
                  Text(
                    gatePass.status.toUpperCase(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Request Details Section ---
                  _buildSectionHeader(context, "Request Details"),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Requester:',
                    value: gatePass.requesterName,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.person_pin_outlined,
                    label: 'Approver:',
                    value: gatePass.approverName,
                  ),
                  const SizedBox(height: 12),
                  // CHANGE: Using requestedAt from your entity
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date:',
                    value: DateFormat(
                      'MMMM d, yyyy',
                    ).format(gatePass.requestedAt),
                  ),
                  const SizedBox(height: 12),
                  // CHANGE: Using requestedAt from your entity
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time:',
                    value: DateFormat('HH:mm a').format(gatePass.requestedAt),
                  ),

                  const Divider(height: 40),

                  // --- Vehicle & Load Information Section ---
                  _buildSectionHeader(context, "Vehicle & Load Information"),
                  const SizedBox(height: 16),

                  _InfoRow(
                    icon: Icons.business_center_outlined,
                    label: 'Party Name:',
                    value: gatePass.partyName,
                  ),
                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.directions_car_outlined,
                    label: 'Vehicle No:',
                    value: gatePass.vehicleNumber,
                  ),
                  if (hasDo) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.receipt_long_outlined,
                      label: 'D.O. No:',
                      value: gatePass.doNumber,
                    ),
                  ],
                  if (hasLot) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.pin_outlined,
                      label: 'Lot No:',
                      value: gatePass.lotNumber,
                    ),
                  ],
                  if (gatePass.weight != null &&
                      gatePass.weight!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.scale_outlined,
                      label: 'Weight:',
                      value: gatePass.weight!,
                    ),
                  ],
                  if (gatePass.centre != null &&
                      gatePass.centre!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.location_city_outlined,
                      label: 'Centre:',
                      value: gatePass.centre!,
                    ),
                  ],

                  const Divider(height: 40),

                  // --- Audit Trail Section ---
                  _buildSectionHeader(context, "Audit Trail"),
                  const SizedBox(height: 16),
                  _AuditStep(
                    icon: Icons.upload_file_rounded,
                    title: 'Request SUBMITTED',
                    subtitle: 'By ${gatePass.requesterName}',
                    // CHANGE: Using requestedAt from your entity
                    timestamp: gatePass.requestedAt,
                    isFirst: true,
                  ),

                  if (gatePass.status != 'requested')
                    _AuditStep(
                      icon: statusIcon,
                      title: 'Request ${gatePass.status.toUpperCase()}',
                      subtitle: 'By ${gatePass.approverName}',
                      // Using requestedAt as the best available timestamp for the action
                      timestamp: gatePass.updatedAt,
                      isLast: true,
                      color: statusColor,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          canTakeAction
              ? _buildActionNavBar(context)
              : (canMarkAsComplete ? _buildCompleteNavBar(context) : null),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActionNavBar(BuildContext context) {
    return BlocListener<RequestGatePassBloc, RequestGatePassState>(
      listener: (context, state) {
        if (state is RequestGatePassUpdated ||
            state is RequestGatePassSuccess) {
          Navigator.of(context).pop(true);
        }
      },
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.close),
                  onPressed:
                      () => context.read<RequestGatePassBloc>().add(
                        UpdateStatusRequested(
                          passId: gatePass.id,
                          newStatus: 'declined',
                        ),
                      ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  label: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  onPressed:
                      () => context.read<RequestGatePassBloc>().add(
                        UpdateStatusRequested(
                          passId: gatePass.id,
                          newStatus: 'accepted',
                        ),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  label: const Text('Accept'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteNavBar(BuildContext context) {
    return BlocListener<RequestGatePassBloc, RequestGatePassState>(
      listener: (context, state) {
        if (state is RequestGatePassUpdated || state is RequestGatePassSuccess) {
          // Pop back to the list screen, which will then refresh.
          Navigator.of(context).pop(true);
        }
      },
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.task_alt_rounded),
            label: const Text('Mark as Complete'),
            onPressed: () => context.read<RequestGatePassBloc>().add(
              UpdateStatusRequested(
                passId: gatePass.id,
                newStatus: 'completed',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

}

// InfoRow and AuditStep widgets remain unchanged and are perfect.
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
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 16.0),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _AuditStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isFirst;
  final bool isLast;
  final Color? color;

  const _AuditStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.isFirst = false,
    this.isLast = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              if (!isFirst)
                Expanded(
                  child: Container(width: 2, color: Colors.grey.shade300),
                ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (color ?? Colors.grey.shade600).withOpacity(0.15),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color ?? Colors.grey.shade700,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: Colors.grey.shade300),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isFirst) const SizedBox(height: 16),

                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, yyyy \'at\' HH:mm').format(timestamp),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
