import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../models/message_model.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key, this.embedded = false});

  static const route = '/conversations';

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final chatService = ChatService();
    
    if (authProvider.user == null) {
      return const Center(child: Text('Veuillez vous connecter.'));
    }

    final body = StreamBuilder<List<ConversationModel>>(
      stream: chatService.getConversations(authProvider.user!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final conversations = snapshot.data ?? [];
        if (conversations.isEmpty) {
          return const Center(child: Text('Aucune conversation.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: conversations.length,
          separatorBuilder: (context, _) => const Divider(height: 1, indent: 76),
      itemBuilder: (context, i) {
            final c = conversations[i];
            return ListTile(
              onTap: () => Navigator.pushNamed(
                context, 
                ChatScreen.route,
                arguments: {'conversationId': c.id}
              ),
              leading: Container(
                height: 46,
                width: 46,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person, color: AppColors.primaryDark),
              ),
              title: Text(
                'Conversation #${c.id.substring(0, 4)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                c.lastMessage ?? 'Pas de message',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              trailing: Text(
                c.lastMessageTime != null 
                  ? '${c.lastMessageTime!.hour}:${c.lastMessageTime!.minute.toString().padLeft(2, '0')}'
                  : '',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            );
          },
        );
      },
    );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Messages'),
      ),
      body: body,
    );
  }
}
