import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_care/features/patient/book/data/model/chat_model.dart';
import 'package:smart_care/features/patient/book/data/repository/chat_repository.dart';
import 'package:smart_care/features/patient/book/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repo;
  RealtimeChannel? _channel;

  ChatCubit(this._repo) : super(ChatInitial());

  List<ChatMessage> _messages = [];

  /// Load messages and start listening for realtime updates.
  Future<void> loadAndSubscribe({
    required String appointmentId,
    required String currentUserId,
  }) async {
    emit(ChatLoading());
    try {
      _messages = await _repo.getMessages(appointmentId);
      emit(ChatLoaded(List.from(_messages)));

      // Mark incoming messages as read
      await _repo.markAsRead(
        appointmentId: appointmentId,
        currentUserId: currentUserId,
      );

      // Subscribe to realtime
      _channel = _repo.subscribeToMessages(
        appointmentId: appointmentId,
        onNewMessage: (msg) {
          // Avoid duplicates (local optimistic message may already exist)
          final alreadyExists = _messages.any((m) => m.id == msg.id);
          if (!alreadyExists) {
            _messages = [..._messages, msg];
            emit(ChatLoaded(List.from(_messages)));
          }
        },
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  /// Send a message — optimistic update then sync with server.
  Future<void> sendMessage({
    required String appointmentId,
    required String senderProfileId,
    required String receiverProfileId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    // Optimistic placeholder
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: tempId,
      appointmentId: appointmentId,
      senderProfileId: senderProfileId,
      receiverProfileId: receiverProfileId,
      message: text.trim(),
      isRead: false,
      createdAt: DateTime.now(),
    );

    _messages = [..._messages, optimistic];
    emit(ChatSending(List.from(_messages)));

    try {
      final saved = await _repo.sendMessage(
        appointmentId: appointmentId,
        senderProfileId: senderProfileId,
        receiverProfileId: receiverProfileId,
        message: text.trim(),
      );

      // Replace the optimistic entry with the real one
      _messages = _messages.map((m) => m.id == tempId ? saved : m).toList();
      emit(ChatLoaded(List.from(_messages)));
    } catch (e) {
      // Remove optimistic on failure
      _messages = _messages.where((m) => m.id != tempId).toList();
      emit(ChatError('Failed to send: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() async {
    if (_channel != null) {
      await _repo.unsubscribe(_channel!);
    }
    super.close();
  }
}
