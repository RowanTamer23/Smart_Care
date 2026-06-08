enum UserStatus {
  approved,
  pending,
  rejected,
}

class Profile {
  final String id;
  final String? role;
  final UserStatus status;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime? updatedAt;
  final String? email;

  Profile({
    required this.id,
    this.role,
    this.status = UserStatus.approved,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.updatedAt,
    this.email,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      role: map['role'] as String?,
      status: UserStatus.values.firstWhere((e) => e.name == map['status'],
          orElse: () => UserStatus.approved),
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role ?? 'patient',
      'status': status.toString(),
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'updated_at': updatedAt?.toIso8601String(),
      'email': email,
    };
  }

  Profile copyWith({
    String? id,
    String? role,
    UserStatus? status,
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? updatedAt,
    String? email,
  }) {
    return Profile(
      id: id ?? this.id,
      role: role ?? this.role,
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      email: email ?? this.email,
    );
  }
}
