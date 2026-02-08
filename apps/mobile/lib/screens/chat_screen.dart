import 'package:flutter/material.dart'; // Flutter material widgets
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod state management
import 'package:ecomesh_services/ecomesh_services.dart'; // Business logic
import 'package:ecomesh_core/ecomesh_core.dart'; // Core models
import '../widgets/message_bubble.dart'; // Message widget
import '../widgets/message_input.dart'; // Input widget

class ChatScreen extends ConsumerStatefulWidget {
  // Chat screen with Riverpod
  const ChatScreen({super.key}); // Constructor

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState(); // Create state
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  // Chat screen state
  final TextEditingController _messageController =
      TextEditingController(); // Input controller
  final String _currentPeerId = 'peer_123'; // Current peer (mock)

  @override
  Widget build(BuildContext context) {
    // Build UI
    final messagesAsync =
        ref.watch(conversationProvider(_currentPeerId)); // Watch messages

    return Scaffold(
      // Scaffold layout
      appBar: AppBar(
        // App bar
        title: const Text('EcoMesh Chat'), // Title
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary, // Themed background
        actions: [
          // Action buttons
          IconButton(
            // AI suggestions button
            icon: const Icon(Icons.auto_awesome), // AI icon
            onPressed: _showSmartReplies, // Show smart replies
            tooltip: 'Smart Replies', // Tooltip
          ),
          IconButton(
            // Settings button
            icon: const Icon(Icons.settings), // Settings icon
            onPressed: () {}, // TODO: Navigate to settings
            tooltip: 'Settings', // Tooltip
          ),
        ],
      ),
      body: Column(
        // Vertical layout
        children: [
          // Children widgets
          Expanded(
            // Flexible space
            child: messagesAsync.when(
              // Handle async state
              data: (messages) =>
                  _buildMessageList(messages), // Build message list
              loading: () =>
                  const Center(child: CircularProgressIndicator()), // Loading
              error: (error, stack) =>
                  Center(child: Text('Error: $error')), // Error display
            ),
          ),
          MessageInput(
            // Message input widget
            controller: _messageController, // Text controller
            onSend: _sendMessage, // Send callback
            onAiSuggest: _getAiSuggestion, // AI suggest callback
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages) {
    // Build message list
    return ListView.builder(
      // Scrollable list
      reverse: true, // Newest at bottom
      padding: const EdgeInsets.all(16), // List padding
      itemCount: messages.length, // Number of messages
      itemBuilder: (context, index) {
        // Item builder
        final message =
            messages[messages.length - 1 - index]; // Get message (reversed)
        final isMe = message.senderId != _currentPeerId; // Check if sent by me

        return MessageBubble(
          // Message bubble widget
          message: message, // Message data
          isMe: isMe, // Ownership flag
          onReply: () => _replyToMessage(message), // Reply callback
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    // Send message handler
    final content = _messageController.text.trim(); // Get trimmed text
    if (content.isEmpty) return; // Ignore empty

    _messageController.clear(); // Clear input

    final messagingService = ref.read(messagingServiceProvider); // Get service
    await messagingService.sendMessage(
      // Send message
      recipientId: _currentPeerId, // Target peer
      content: content, // Message text
    );

    ref.invalidate(conversationProvider(_currentPeerId)); // Refresh UI
  }

  Future<void> _replyToMessage(Message message) async {
    // Reply to message
    _messageController.text = '> ${message.content}\n'; // Quote original
  }

  Future<void> _getAiSuggestion() async {
    // Get AI suggestion
    final aiService = ref.read(aiServiceProvider); // Get AI service
    final messagingService =
        ref.read(messagingServiceProvider); // Get messaging
    final messages =
        await messagingService.getConversation(_currentPeerId); // Get history

    if (messages.isEmpty) return; // No history

    final lastMessage = messages.last; // Get last message
    final aiContext = MessageContext(
      // Build AI context
      incomingMessage: lastMessage.content, // Last message
      recentHistory:
          messages.take(5).map((m) => m.content).toList(), // Recent 5 messages
      preferredTone: 'friendly', // Friendly tone
    );

    try {
      final suggestion =
          await aiService.generateReply(aiContext); // Get AI reply
      if (!mounted) return;
      _messageController.text = suggestion; // Fill input
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        // Show error
        SnackBar(content: Text('AI unavailable: $e')), // Error message
      );
    }
  }

  void _showSmartReplies() {
    // Show smart reply options
    showModalBottomSheet(
      // Show bottom sheet
      context: context,
      builder: (context) => Container(
        // Container
        padding: const EdgeInsets.all(16), // Padding
        child: Column(
          // Vertical layout
          mainAxisSize: MainAxisSize.min, // Minimize height
          children: [
            // Children
            const Text('Smart Replies',
                style: TextStyle(
                  // Title
                  fontSize: 18, // Font size
                  fontWeight: FontWeight.bold, // Bold
                )),
            const SizedBox(height: 16), // Spacing
            _buildReplyChip('👍 That sounds great!'), // Reply option 1
            _buildReplyChip('🤔 Let me think about it'), // Reply option 2
            _buildReplyChip('✅ I agree'), // Reply option 3
          ],
        ),
      ),
    );
  }

  Widget _buildReplyChip(String text) {
    // Build reply chip
    return Padding(
      // Padding wrapper
      padding: const EdgeInsets.symmetric(vertical: 4), // Vertical padding
      child: ActionChip(
        // Action chip
        label: Text(text), // Chip text
        onPressed: () {
          // Tap handler
          Navigator.pop(context); // Close sheet
          _messageController.text = text; // Set text
        },
      ),
    );
  }
}
