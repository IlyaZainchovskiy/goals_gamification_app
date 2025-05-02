class UserModel {
  final String id;
  final String email;
  final String username;
  final int level;
  final int xp;
  final List<String> achievements;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.level = 1,
    this.xp = 0,
    this.achievements = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'level': level,
      'xp': xp,
      'achievements': achievements,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    int? level,
    int? xp,
    List<String>? achievements,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      achievements: achievements ?? this.achievements,
    );
  }
}