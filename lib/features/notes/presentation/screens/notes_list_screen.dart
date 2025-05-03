import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sync_pad/features/notes/data/models/note_model.dart';
import 'package:sync_pad/features/notes/domain/entities/note_entity.dart';
import 'package:sync_pad/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:sync_pad/features/notes/presentation/screens/add_edit_note_screen.dart';
import 'dart:developer';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.redAccent.shade100 : Colors.green.shade100,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: isError ? 3 : 2),

        action:
            isError ? SnackBarAction(label: 'Dismiss', onPressed: () {}) : null,
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, NoteEntity note) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            title: const Text('Confirm Deletion'),
            content: Text(
              'Are you sure you want to delete "${note.title.isEmpty ? 'this note' : note.title}"?\n\nIt will be removed permanently after the next sync.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.read<NotesBloc>().add(DeleteNoteEvent(note.id));

                  _showSnackbar(
                    context,
                    "'${note.title.isEmpty ? 'Note' : note.title}' marked for deletion.",
                  );
                },
                child: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state.status == NotesStatus.failure && state.errorMessage != null) {
          if (!state.errorMessage!.toLowerCase().contains('offline')) {
            _showSnackbar(
              context,
              "Error: ${state.errorMessage}",
              isError: true,
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sync Pad'),
            elevation: 1.0,
            shadowColor: Colors.black26,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.inversePrimary.withOpacity(0.1),

            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(24.0),
              child: _buildStatusIndicator(context, state),
            ),
            actions: [
              Tooltip(
                message: state.isConnected ? "Online" : "Offline",
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    state.isConnected ? Icons.wifi : Icons.wifi_off,
                    color:
                        state.isConnected
                            ? Colors.green.shade600
                            : Colors.grey.shade500,
                  ),
                ),
              ),

              _buildSyncButton(context, state),
              const SizedBox(width: 8),
            ],
          ),

          body: RefreshIndicator(
            onRefresh: () async {
              if (context.read<NotesBloc>().state.isConnected) {
                context.read<NotesBloc>().add(TriggerRefreshEvent());
              } else {
                _showSnackbar(
                  context,
                  "Cannot refresh while offline.",
                  isError: true,
                );
              }
            },

            child: _buildBodyContent(context, state),
          ),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditNoteScreen(note: null),
                ),
              );
            },
            tooltip: 'Add New Note',
            icon: const Icon(Icons.add),
            label: const Text("Add Note"),
            elevation: 4.0,
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(BuildContext context, NotesState state) {
    String statusText = "";
    Color bgColor = Colors.transparent;
    Color textColor = Colors.black87;
    IconData? leadingIconData;
    Color? iconColor;
    bool showIndicator = true;

    switch (state.status) {
      case NotesStatus.syncing:
        statusText = "Syncing local changes...";
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        leadingIconData = Icons.cloud_sync_outlined;
        iconColor = Colors.orange.shade700;
        break;
      case NotesStatus.refreshing:
        statusText = "Fetching latest notes...";
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade900;
        leadingIconData = Icons.cloud_download_outlined;
        iconColor = Colors.blue.shade700;
        break;
      case NotesStatus.failure:
        if (state.errorMessage != null &&
            !state.errorMessage!.contains("offline")) {
          statusText = "Last operation failed";
          bgColor = Colors.red.shade50;
          textColor = Colors.red.shade900;
          leadingIconData = Icons.error_outline;
          iconColor = Colors.red.shade700;
        } else {
          showIndicator = false;
        }
        break;
      case NotesStatus.loaded:
        showIndicator = false;
        break;
      default:
        showIndicator = false;
        break;
    }

    if (!state.isConnected && statusText.isEmpty) {
      statusText = "Offline Mode";
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey.shade800;
      leadingIconData = Icons.cloud_off_outlined;
      iconColor = Colors.grey.shade700;
      showIndicator = true;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: showIndicator ? 24.0 : 0.0,
      color: bgColor,
      width: double.infinity,

      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: showIndicator ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leadingIconData != null) ...[
                Icon(leadingIconData, size: 14, color: iconColor ?? textColor),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  statusText,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: textColor),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              if (leadingIconData != null) const SizedBox(width: 14 + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context, NotesState state) {
    bool isBusy =
        state.status == NotesStatus.syncing ||
        state.status == NotesStatus.refreshing;
    String tooltip =
        isBusy
            ? (state.status == NotesStatus.syncing
                ? "Syncing..."
                : "Refreshing...")
            : 'Sync Now';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Tooltip(
        message: tooltip,
        child:
            isBusy
                ? Container(
                  padding: const EdgeInsets.all(12.0),
                  width: 48.0,
                  height: 48.0,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                )
                : IconButton(
                  tooltip: tooltip,

                  onPressed:
                      state.isConnected
                          ? () =>
                              context.read<NotesBloc>().add(TriggerSyncEvent())
                          : null,
                  icon: const Icon(Icons.sync_outlined),
                ),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, NotesState state) {
    if (state.status == NotesStatus.initial ||
        (state.status == NotesStatus.loading && state.notes.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == NotesStatus.failure &&
        state.notes.isEmpty &&
        state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load notes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),

                onPressed:
                    () => context.read<NotesBloc>().add(LoadNotesEvent()),
              ),
            ],
          ),
        ),
      );
    }

    if (state.notes.isEmpty &&
        state.status != NotesStatus.loading &&
        state.status != NotesStatus.initial) {
      return _buildEmptyStateWidget();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 96.0),
      itemCount: state.notes.length,
      itemBuilder: (context, index) {
        final noteEntity = state.notes[index];

        bool isSynced = true;
        bool isDeletedLocally = false;
        if (noteEntity is NoteModel) {
          isSynced = noteEntity.isSynced;
          isDeletedLocally = noteEntity.isDeleted;
        } else {
          log(
            "Warning: Note item in list is NoteEntity type at index $index, cannot show exact sync/delete status.",
          );
        }

        return _buildNoteItemCard(
          context: context,
          note: noteEntity,
          isSynced: isSynced,
          isDeletedLocally: isDeletedLocally,
        );
      },
    );
  }

  Widget _buildEmptyStateWidget() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Your Sync Pad is Empty!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the "Add Note" button below to create your first synchronized note.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItemCard({
    required BuildContext context,
    required NoteEntity note,
    required bool isSynced,
    required bool isDeletedLocally,
  }) {
    final theme = Theme.of(context);
    final bool isUntitled = note.title.trim().isEmpty;

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      decoration: isDeletedLocally ? TextDecoration.lineThrough : null,
      color: isDeletedLocally ? theme.disabledColor : null,
      decorationColor: isDeletedLocally ? theme.disabledColor : null,
    );
    final contentStyle = theme.textTheme.bodyMedium?.copyWith(
      color:
          isDeletedLocally
              ? theme.disabledColor
              : theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
      decoration: isDeletedLocally ? TextDecoration.lineThrough : null,
      decorationColor: isDeletedLocally ? theme.disabledColor : null,
      height: 1.4,
    );
    final dateStyle = theme.textTheme.bodySmall?.copyWith(
      color:
          isDeletedLocally
              ? theme.disabledColor
              : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
      fontSize: 11,
    );
    final iconColor =
        isDeletedLocally
            ? theme.disabledColor
            : theme.iconTheme.color?.withOpacity(0.7);

    return Opacity(
      opacity: isDeletedLocally ? 0.55 : 1.0,
      child: Card(
        elevation: isDeletedLocally ? 0.5 : 1.5,
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap:
              isDeletedLocally
                  ? null
                  : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditNoteScreen(note: note),
                      ),
                    );
                  },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  child: Tooltip(
                    message:
                        isDeletedLocally
                            ? "Marked for deletion"
                            : (isSynced ? "Synced" : "Changes not synced"),
                    child: Icon(
                      isDeletedLocally
                          ? Icons.delete_sweep_outlined
                          : (isSynced
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_upload_outlined),
                      size: 20,
                      color:
                          isDeletedLocally
                              ? Colors.red.shade200
                              : (isSynced
                                  ? Colors.green.shade400
                                  : Colors.orange.shade400),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUntitled ? "(Untitled Note)" : note.title,
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (note.content.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          note.content,
                          style: contentStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),

                      Text(
                        "Updated: ${DateFormat('MMM d, HH:mm').format(note.updatedAt)}",
                        style: dateStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                if (!isDeletedLocally)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        icon: Icons.edit_outlined,
                        color: theme.primaryColor.withOpacity(0.8),
                        tooltip: "Edit Note",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditNoteScreen(note: note),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        icon: Icons.delete_outline,
                        color: theme.colorScheme.error.withOpacity(0.7),
                        tooltip: "Delete Note",
                        onPressed:
                            () => _showDeleteConfirmationDialog(context, note),
                      ),
                    ],
                  )
                else
                  const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      width: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 20),
        color: color ?? Theme.of(context).iconTheme.color,
        tooltip: tooltip,
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }
}
