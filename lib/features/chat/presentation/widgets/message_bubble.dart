import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sync_pad/features/chat/domain/entities/messages_entity.dart';
import 'package:sync_pad/features/chat/presentation/widgets/fullscreen_image_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../injection_container.dart';
import '../../../auth/domain/entities/auth_user_entity.dart';
import '../../../gatepass/data/models/gate_pass_model.dart';
import '../../../gatepass/presentation/screens/gate_pass_details_screen.dart'; // <-- Add this import

// You would typically place this widget in its own file, e.g., message_bubble.dart
class MessageBubble extends StatelessWidget {
  final MessagesEntity message;
  final bool isMe;

  final AuthUserEntity currentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.currentUser,
  });

  Future<void> _openFile(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    try {
      // Show a loading indicator
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Downloading $fileName...')));

      final dio = Dio();
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';

      // Download the file
      await dio.download(url, filePath);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Create a Uri from the local file path
      final fileUri = Uri.file(filePath);

      // Use url_launcher to open the file
      if (await canLaunchUrl(fileUri)) {
        await launchUrl(fileUri);
      } else {
        throw Exception('Could not launch $fileUri');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error opening file: Could not find an app to open it.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignment = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    final bubbleColor =
        isMe
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.secondaryContainer;
    final textColor =
        isMe
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSecondaryContainer;
    final borderRadius =
        isMe
            ? const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            )
            : const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            // Remove padding here, as the content itself will have padding or be clipped
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
            ),
            // Clip the content (like images) to the bubble's border radius
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageContent(context, message, textColor),
                // Pass context here
                Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                    left: 12.0,
                    bottom: 5.0,
                    top: 2.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4.0),
                        _MessageStatusIcon(
                          status: message.status,
                          color: textColor.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FULLY IMPLEMENTED MESSAGE CONTENT WIDGET ---
  Widget _buildMessageContent(
    BuildContext context,
    MessagesEntity message,
    Color textColor,
  ) {
    switch (message.type) {
      case 'image':
        // The unique message ID is perfect for a Hero tag
        final heroTag = message.messageId;
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => FullscreenImageViewer(
                      imageUrl: message.url,
                      heroTag: heroTag,
                    ),
              ),
            );
          },
          child: Hero(
            tag: heroTag,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: CachedNetworkImage(
                imageUrl: message.url,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
              ),
            ),
          ),
        );

      case 'file': // Assuming 'file' or 'pdf' as the type
        return InkWell(
          onTap: () => _openFile(context, message.url, message.message),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.description_rounded,
                  color: Colors.blueGrey,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message.isNotEmpty
                            ? message.message
                            : 'Document',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Tap to open',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      case 'gatepass':
        if (message.referenceId == null) {
          return const Text('Invalid Gate Pass Reference');
        }
        return _GatePassMessageContent(
          gatePassId: message.referenceId!,
          initialMessage: message.message,
          textColor: textColor,
          currentUser: currentUser,
        );

      case 'text':
      default:
        // Add padding only for text messages
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Text(
            message.message,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
        );
    }
  }
}

// _MessageStatusIcon widget remains unchanged and is perfect.
class _MessageStatusIcon extends StatelessWidget {
  final String status;
  final Color color;

  const _MessageStatusIcon({
    super.key,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor = color;
    switch (status) {
      case 'sent':
        iconData = Icons.done;
        break;
      case 'delivered':
        iconData = Icons.done_all;
        break;
      case 'read':
        iconData = Icons.done_all;
        iconColor = Colors.lightBlueAccent;
        break;
      default:
        iconData = Icons.watch_later_outlined;
    }
    return Icon(iconData, size: 16, color: iconColor);
  }
}

class _GatePassMessageContent extends StatelessWidget {
  const _GatePassMessageContent({
    super.key,
    required this.gatePassId,
    required this.initialMessage,
    required this.textColor,
    required this.currentUser,
  });

  final String gatePassId;
  final String initialMessage;
  final Color textColor;
  final AuthUserEntity currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // The stream points directly to the gate pass document using its ID.
      stream:
          sl<FirebaseFirestore>()
              .collection('gatepasses')
              .doc(gatePassId)
              .snapshots(),
      builder: (context, snapshot) {
        // --- DATA HANDLING ---
        String status =
            'requested'; // Default status if data is loading or missing


        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData &&
            snapshot.data!.exists) {
          // If we have live data, parse it using your GatePassModel.
          final gatePass = GatePassModel.fromFirestore(snapshot.data!);
          status = gatePass.status;
        } else if (snapshot.hasError) {
          // Handle a stream error gracefully.
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Error loading status.",
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        // While ConnectionState is 'waiting', it will show the default 'requested' UI below.

        // --- DYNAMIC UI VARIABLES ---
        final Color color = _getStatusColor(status);
        final IconData icon = _getStatusIcon(status);
        final String titleText = _getStatusText(status);
        final String subtitleText = initialMessage;

        // --- THE UI RENDERED BY THE STREAMBUILDER ---
        return GestureDetector(
          onTap: () {

            final gatePass = GatePassModel.fromFirestore(snapshot.data!);



            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (_) => GatePassDetailScreen(
                      gatePass: gatePass,
                      currentUser: currentUser,
                    ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The main icon on the left.
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: color,
                  size: 40,
                ),
                const SizedBox(width: 12),
                // The text content.
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText, // "Request ACCEPTED" etc.
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleText, // "DO: 123 | Lot: 456"
                        style: TextStyle(
                          color: textColor.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // This is the LIVE STATUS CHIP that you wanted.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: color, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green.shade700;
      case 'declined':
        return Colors.red.shade700;
      case 'completed': return Colors.blue.shade600;

      default: // 'requested'
        return Colors.orange.shade800;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle;
      case 'declined':
        return Icons.cancel;
      case 'completed': return Icons.task_alt_rounded;

      default: // 'requested'
        return Icons.hourglass_top_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return "Request ACCEPTED";
      case 'declined':
        return "Request DECLINED";
        case 'completed':
        return "Request COMPLETED";
      default: // 'requested'
        return "Request SENT";
    }
  }
}
