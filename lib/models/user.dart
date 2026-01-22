class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? profileImage;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.profileImage,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}