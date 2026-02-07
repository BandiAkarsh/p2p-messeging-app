import 'package:flutter/material.dart'; // Flutter material widgets
import 'package:ecomesh_core/ecomesh_core.dart'; // Core models

class MessageBubble extends StatelessWidget { // Message bubble widget
  final Message message; // Message data
  final bool isMe; // Is sent by current user
  final VoidCallback? onReply; // Reply callback

  const MessageBubble({ // Constructor
    super.key, // Key
    required this.message, // Required message
    required this.isMe, // Required ownership
    this.onReply, // Optional reply callback
  });

  @override
  Widget build(BuildContext context) { // Build widget
    final theme = Theme.of(context); // Get theme

    return Align( // Align widget
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, // Right if sent by me
      child: Container( // Message container
        constraints: BoxConstraints( // Size constraints
          maxWidth: MediaQuery.of(context).size.width * 0.75,         // 75% of screen width
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),              // Vertical margin
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Inner padding
        decoration: BoxDecoration( // Container decoration
          color: isMe                                                 // Background color
              ? theme.colorScheme.primary                             // Primary if sent
              : theme.colorScheme.surfaceContainerHighest,            // Surface if received
          borderRadius: BorderRadius.circular(20),                    // Rounded corners
        ),
        child: Column( // Vertical layout
          crossAxisAlignment: CrossAxisAlignment.start,               // Left align
          mainAxisSize: MainAxisSize.min,                             // Minimize height
          children: [                                                 // Children
            if (message.replyToId != null)                           // Show if reply
              Container(                                              // Reply indicator
                padding: const EdgeInsets.only(bottom: 4),            // Bottom padding
                child: Text(                                          // Reply text
                  'Replying to...',                                  // Placeholder
                  style: TextStyle(                                  // Text style
                    fontSize: 12,                                     // Small font
                    color: isMe                                       // Text color
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.7) // Light if sent
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7), // Dark if received
                  ),
                ),
              ),
            Text( // Message content
              message.content, // Text to display
              style: TextStyle( // Text style
                color: isMe                                           // Text color
                    ? theme.colorScheme.onPrimary                     // On primary if sent
                    : theme.colorScheme.onSurface,                    // On surface if received
                fontSize: 16,                                         // Font size
              ),
            ),
            const SizedBox(height: 4), // Spacing
            Row( // Horizontal layout
              mainAxisSize: MainAxisSize.min,                         // Minimize width
              children: [                                             // Children
                Text(                                                 // Timestamp
                  _formatTime(message.timestamp),                    // Formatted time
                  style: TextStyle(                                  // Text style
                    fontSize: 11,                                     // Small font
                    color: isMe                                       // Color
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.6) // Light
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6), // Dark
                  ),
                ),
                const SizedBox(width: 4),                              // Spacing
                if (isMe)                                             // Show status if sent
                  Icon(                                               // Status icon
                    _getStatusIcon(message.status),                   // Status icon
                    size: 14,                                         // Small icon
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.6), // Color
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) { // Format timestamp
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'; // HH:MM
  }

  IconData _getStatusIcon(MessageStatus status) { // Get status icon
    switch (status) {                                                 // Switch on status
      case MessageStatus.sent:                                        // Sent state
        return Icons.check;                                           // Single check
      case MessageStatus.delivered:                                   // Delivered
        return Icons.done_all;                                        // Double check
      case MessageStatus.read:                                        // Read state
        return Icons.done_all;                                        // Double check (blue in real app)
      default:                                                        // Default
        return Icons.access_time;                                     // Clock icon
    }
  }
}
