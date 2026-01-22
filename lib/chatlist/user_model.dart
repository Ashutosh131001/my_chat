class UserModel {
  final String uid;
  final String phoneNumber;
  final String? name;
  final String? about;
  final String? profileImageUrl;
  final int? createdAt;
  final bool isOnline;
  final int? lastSeen;
  final List<int> fcmTokens;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.name,
    this.about,
    this.profileImageUrl,
    this.createdAt,
    this.isOnline = false,
    this.lastSeen,
    this.fcmTokens = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'],
      about: map['about'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'about': about,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? name,
    String? about,
    String? profileImageUrl,
    int? createdAt,
    bool? isOnline,
    int? lastSeen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      about: about ?? this.about,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, phone: $phoneNumber, name: $name, isOnline: $isOnline)';
  }
}
