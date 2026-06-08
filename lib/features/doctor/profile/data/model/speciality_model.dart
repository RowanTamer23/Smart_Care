class Specialty {
  final String id;
  final String name;
  final String staffType;
  final DateTime? createdAt;

  Specialty({
    required this.id,
    required this.name,
    required this.staffType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: (json["id"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      staffType: (json["staff_type"] ?? json["staffType"] ?? "").toString(),
      createdAt: json["created_at"] == null && json["createdAt"] == null
          ? null
          : DateTime.tryParse((json["created_at"] ?? json["createdAt"]).toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "staff_type": staffType,
        "staffType": staffType,
        "created_at": createdAt?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
      };
}
