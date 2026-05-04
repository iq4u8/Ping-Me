class UserEntity {
  final String id;
  final String username;
  final String displayName;
  final String? bio;
  final String? photoUrl;

  UserEntity({
    required this.id,
    required this.username,
    required this.displayName,
    this.bio,
    this.photoUrl,
  });
}
