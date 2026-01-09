class UserProfile {
  final String id;
  final String name;
  final String email;
  final bool isOnline;
  final String? photoUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.isOnline,
    this.photoUrl,
  });
}