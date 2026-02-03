import 'package:hive/hive.dart';

// ⚠️ Run 'flutter pub run build_runner build' after saving this file!
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String phoneNumber;

  @HiveField(2)
  final String? name;

  @HiveField(3)
  final String? about;

  @HiveField(4)
  final String? profileImageUrl;

  @HiveField(5)
  final int? createdAt;

  @HiveField(6)
  final bool isOnline;

  @HiveField(7)
  final int? lastSeen;

  @HiveField(8)
  final List<String> fcmTokens; // 🟢 Fixed: Tokens are Strings, not Ints

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

  // Factory to create from Firebase JSON
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'],
      about: map['about'],
      profileImageUrl: map['profileImageUrl'],
      
      // 🛡️ CRASH FIX: Safely convert String -> Int
      createdAt: _toInt(map['createdAt']),
      
      isOnline: map['isOnline'] ?? false,
      
      // 🛡️ CRASH FIX: Safely convert String -> Int
      lastSeen: _toInt(map['lastSeen']),

      // 🛡️ TYPE FIX: Ensure tokens are Strings
      fcmTokens: map['fcmTokens'] != null 
          ? List<String>.from(map['fcmTokens']) 
          : const [],
    );
  }

  // Convert to JSON
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
      'fcmTokens': fcmTokens,
    };
  }

  // CopyWith
  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? name,
    String? about,
    String? profileImageUrl,
    int? createdAt,
    bool? isOnline,
    int? lastSeen,
    List<String>? fcmTokens,
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
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, phone: $phoneNumber, name: $name)';
  }

  // 🛠️ HELPER: Safely convert ANYTHING to int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value); // Try parsing "123" to 123
    }
    return null;
  }
}