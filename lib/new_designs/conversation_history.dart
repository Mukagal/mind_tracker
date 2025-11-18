import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mob_edu/config.dart';
import 'package:intl/intl.dart';
import 'package:mob_edu/new_designs/chatbot.dart';

class ConversationHistory {
  final String conversationId;
  final DateTime startedAt;
  final DateTime lastMessageAt;
  final String? preview;

  ConversationHistory({
    required this.conversationId,
    required this.startedAt,
    required this.lastMessageAt,
    this.preview,
  });

  factory ConversationHistory.fromJson(Map<String, dynamic> json) {
    return ConversationHistory(
      conversationId: json['conversation_id'],
      startedAt: DateTime.parse(json['started_at']),
      lastMessageAt: DateTime.parse(json['last_message_at']),
      preview: json['preview'],
    );
  }
}

class ConversationHistoryPage extends StatefulWidget {
  final int? userId;
  final String? userName;

  const ConversationHistoryPage({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<ConversationHistoryPage> createState() =>
      _ConversationHistoryPageState();
}

class _ConversationHistoryPageState extends State<ConversationHistoryPage> {
  List<ConversationHistory> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/conversations/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final conversations = data['conversations'] as List;

        setState(() {
          _conversations = conversations
              .map((conv) => ConversationHistory.fromJson(conv))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading conversations: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteConversation(String conversationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
          'Are you sure you want to delete this conversation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await http.delete(
          Uri.parse(
            '$baseUrl/api/conversations/${widget.userId}/$conversationId',
          ),
        );
        _loadConversations();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Conversation deleted')));
      } catch (e) {
        print('Error deleting conversation: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete conversation')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE HH:mm').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Conversation History'),
            Text(
              widget.userName ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a new conversation to see it here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadConversations,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        'Conversation ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _formatDate(conversation.lastMessageAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        onPressed: () =>
                            _deleteConversation(conversation.conversationId),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              userId: widget.userId,
                              userName: widget.userName,
                              conversationId: conversation.conversationId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatPage(userId: widget.userId, userName: widget.userName),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Chat'),
      ),
    );
  }
}
