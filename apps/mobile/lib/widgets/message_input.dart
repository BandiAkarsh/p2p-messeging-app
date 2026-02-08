import 'package:flutter/material.dart'; // Flutter material widgets

class MessageInput extends StatelessWidget {
  // Message input widget
  final TextEditingController controller; // Text controller
  final VoidCallback onSend; // Send callback
  final VoidCallback onAiSuggest; // AI suggest callback

  const MessageInput({
    // Constructor
    super.key, // Key
    required this.controller, // Required controller
    required this.onSend, // Required send callback
    required this.onAiSuggest, // Required AI callback
  });

  @override
  Widget build(BuildContext context) {
    // Build widget
    final theme = Theme.of(context); // Get theme

    return Container(
      // Input container
      padding: const EdgeInsets.all(12), // Padding
      decoration: BoxDecoration(
        // Decoration
        color: theme.colorScheme.surface, // Background color
        boxShadow: [
          // Shadow
          BoxShadow(
            // Shadow definition
            color: Colors.black.withValues(alpha: 0.1), // Shadow color
            blurRadius: 8, // Blur radius
            offset: const Offset(0, -2), // Shadow offset
          ),
        ],
      ),
      child: SafeArea(
        // Safe area
        child: Row(
          // Horizontal layout
          children: [
            // Children
            IconButton(
              // AI suggest button
              icon: Icon(
                // AI icon
                Icons.auto_awesome, // Icon
                color: theme.colorScheme.primary, // Icon color
              ),
              onPressed: onAiSuggest, // AI suggest action
              tooltip: 'AI Suggestion', // Tooltip
            ),
            Expanded(
              // Flexible text field
              child: TextField(
                // Text input
                controller: controller, // Attach controller
                decoration: InputDecoration(
                  // Input decoration
                  hintText: 'Type a message...', // Placeholder
                  filled: true, // Fill background
                  fillColor:
                      theme.colorScheme.surfaceContainerHighest, // Fill color
                  border: OutlineInputBorder(
                    // Border style
                    borderRadius: BorderRadius.circular(24), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    // Inner padding
                    horizontal: 20, // Horizontal padding
                    vertical: 14, // Vertical padding
                  ),
                ),
                maxLines: null, // Allow multiple lines
                textCapitalization:
                    TextCapitalization.sentences, // Capitalize sentences
                onSubmitted: (_) => onSend(), // Submit on enter
              ),
            ),
            const SizedBox(width: 8), // Spacing
            FloatingActionButton.small(
              // Send button
              onPressed: onSend, // Send action
              backgroundColor: theme.colorScheme.primary, // Button color
              elevation: 0, // No shadow
              child: Icon(
                // Send icon
                Icons.send, // Icon
                color: theme.colorScheme.onPrimary, // Icon color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
