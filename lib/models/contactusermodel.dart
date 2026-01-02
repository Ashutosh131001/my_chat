// ignore: camel_case_types
class usermodel {
  final String uid;
  final String name;
  final String phonenumber;
  final String? about;
  final String? profileImageUrl;

  usermodel({
    required this.uid,
    required this.name,
    required this.phonenumber,
    this.about,
    this.profileImageUrl,
  });

  factory usermodel.frommap(Map<String, dynamic> map) {
    return usermodel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phonenumber: map['phoneNumber'] ?? '',
      about: map['about'] ?? 'Hey there! I am using MyChat 💬',
      profileImageUrl: map['profileImageUrl'],
    );
  }

  /// 🧩 Convert model to map (useful for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phonenumber,
      'about': about,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// 🧩 Create a model directly from phone contact (used if we later match phone contacts)
  factory usermodel.fromphone(String name, String phonenumber) {
    return usermodel(uid: '', name: name, phonenumber: phonenumber);
  }

  /// 🧩 Copy model with modifications
  usermodel copyWith({
    String? uid,
    String? name,
    String? phonenumber,
    String? about,
    String? profileImageUrl,
  }) {
    return usermodel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phonenumber: phonenumber ?? this.phonenumber,
      about: about ?? this.about,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
