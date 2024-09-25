class UserModel {

  final String uuid;
  final String username;
  final String email;
  final String password;
  final bool isAdmin;

  UserModel({
    required this.uuid,
    required this.username,
    required this.email,
    required this.password,
    required this.isAdmin,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'uuid': uuid,
      'email': email,
      'password': password,
      'isAdmin': isAdmin,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uuid: map['uuid'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      isAdmin: map['isAdmin'] as bool,
    );
  }
}
