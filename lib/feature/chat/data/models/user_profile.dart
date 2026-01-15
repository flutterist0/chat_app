class UserProfile {
  final String id;
  final String name;
  final String email;
  final bool isOnline;
  final String? photoUrl;

  UserProfile({
    required this.id,
    required this.name,
    this.followersCount = 0,
    this.followingCount = 0,
    this.friendshipStatus = FriendshipStatus.none,
    required this.email,
    required this.isOnline,
    this.photoUrl,
  });

  final int followersCount;
  final int followingCount;
  final FriendshipStatus friendshipStatus;
}

enum FriendshipStatus {
  none,
  pendingSent,
  pendingReceived,
  following,
  followedBy,
  mutual,
}