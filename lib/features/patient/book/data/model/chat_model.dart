class ChatMessage {
  final String id;
  final String? appointmentId; // Nullable Foreign Key
  final String? senderProfileId; // Nullable Foreign Key (links to profiles)
  final String? receiverProfileId; // Nullable Foreign Key (links to profiles)
  final String message;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    this.appointmentId,
    this.senderProfileId,
    this.receiverProfileId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  /// Creates a copy of this object with the given fields replaced.
  ChatMessage copyWith({
    String? id,
    String? appointmentId,
    String? senderProfileId,
    String? receiverProfileId,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      senderProfileId: senderProfileId ?? this.senderProfileId,
      receiverProfileId: receiverProfileId ?? this.receiverProfileId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts a Map (JSON) payload from Supabase into this Dart object.
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      appointmentId: map['appointment_id'] as String?,
      senderProfileId: map['sender_profile_id'] as String?,
      receiverProfileId: map['receiver_profile_id'] as String?,
      message: map['message'] as String,
      isRead: map['is_read'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  /// Converts this Dart object into a Map (JSON) payload to send to Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'sender_profile_id': senderProfileId,
      'receiver_profile_id': receiverProfileId,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
