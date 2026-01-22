class AuthModel {
  final String phonenumber;
  final String ?verificationid;

  AuthModel({required this.phonenumber, this.verificationid});

  AuthModel copywith({String? phonenumber, String? verificationid}) {
    return AuthModel(
      phonenumber: phonenumber ?? this.phonenumber,
      verificationid: verificationid ?? this.verificationid,
    );
  }

  Map<String, dynamic> tomap() {
    return {'phonenumber': phonenumber, 'verificationid': verificationid};
  }

  factory AuthModel.frommap(Map<String, dynamic> map) {
    return AuthModel(
      phonenumber: map['phonenumber'],
      verificationid: map['verificationid'],
    );
  }
}
