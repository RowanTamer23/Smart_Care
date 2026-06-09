import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_care/features/patient/book/data/model/chat_model.dart';

class ChatRepository {
  final _client = Supabase.instance.client;

  /// Fetch all messages for a given [appointmentId], ordered oldest first.
  Future<List<ChatMessage>> getMessages(String appointmentId) async {
    final response = await _client
        .from('chat_messages')
        .select()
        .eq('appointment_id', appointmentId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  /// Send a new message. Returns the saved [ChatMessage].
  Future<ChatMessage> sendMessage({
    required String appointmentId,
    required String senderProfileId,
    required String receiverProfileId,
    required String message,
  }) async {
    final payload = {
      'appointment_id': appointmentId,
      'sender_profile_id': senderProfileId,
      'receiver_profile_id': receiverProfileId,
      'message': message,
      'is_read': false,
    };

    final response = await _client
        .from('chat_messages')
        .insert(payload)
        .select()
        .single();

    return ChatMessage.fromMap(response);
  }

  /// Mark all messages in [appointmentId] sent TO [currentUserId] as read.
  Future<void> markAsRead({
    required String appointmentId,
    required String currentUserId,
  }) async {
    await _client
        .from('chat_messages')
        .update({'is_read': true})
        .eq('appointment_id', appointmentId)
        .eq('receiver_profile_id', currentUserId)
        .eq('is_read', false);
  }

  /// Subscribe to realtime inserts for a conversation.
  /// [onNewMessage] is called for every new row.
  RealtimeChannel subscribeToMessages({
    required String appointmentId,
    required void Function(ChatMessage) onNewMessage,
  }) {
    return _client
        .channel('chat_$appointmentId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'appointment_id',
            value: appointmentId,
          ),
          callback: (payload) {
            final newRow = payload.newRecord;
            if (newRow.isNotEmpty) {
              onNewMessage(ChatMessage.fromMap(newRow));
            }
          },
        )
        .subscribe();
  }

  /// Cancel a realtime channel subscription.
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}
