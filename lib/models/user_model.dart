class UserModel {
  final String uuid;
  final String username;
  String email;
  final String password;
  String role;
  String orgId;
  String orgName;
  String locId;
  String locName;
  String allowSummaryEdit;
  List<String> users;

  UserModel({
    required this.uuid,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    required this.orgId,
    required this.orgName,
    required this.locId,
    required this.locName,
    this.allowSummaryEdit = "0",
    this.users = const [],
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'uuid': uuid,
      'email': email,
      'password': password,
      'role': role,
      'orgId': orgId,
      'orgName': orgName,
      'locId': locId,
      'locName': locName,
      'allowSummaryEdit': allowSummaryEdit,
      'users': users, // <-- Added
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uuid: map['uuid'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      orgId: map['orgId'] as String,
      orgName: map['orgName'] as String,
      locId: map['locId'] as String,
      locName: map['locName'] as String,
      allowSummaryEdit: map['allowSummaryEdit'] ?? "0",
      users: List<String>.from(map['users'] ?? []), // <-- Added with fallback
    );
  }

  factory UserModel.emptyUser() {
    return UserModel(
      uuid: "",
      username: "",
      email: "",
      password: "",
      role: "",
      orgId: "",
      orgName: "",
      locId: "",
      locName: "",
      allowSummaryEdit: "0",
      users: [],
    );
  }

  UserModel._builder(UserModelBuilder builder)
      : uuid = builder.uuid!,
        username = builder.username!,
        email = builder.email!,
        password = builder.password!,
        role = builder.role!,
        orgId = builder.orgId!,
        orgName = builder.orgName!,
        locId = builder.locId!,
        locName = builder.locName!,
        allowSummaryEdit = builder.allowSummaryEdit ?? "0",
        users = builder.users ?? []; // <-- Added

  @override
  String toString() {
    return 'UserModel(uuid: $uuid, username: $username, email: $email, password: $password, role: $role, orgId: $orgId, orgName: $orgName, locId: $locId, locName: $locName, allowSummaryEdit: $allowSummaryEdit, users: $users)';
  }
}

class UserModelBuilder {
  String? uuid;
  String? username;
  String? email;
  String? password;
  String? role;
  String? orgId;
  String? orgName;
  String? locId;
  String? locName;
  String? allowSummaryEdit;
  List<String>? users; // <-- New field

  UserModelBuilder setUuid(String uuid) {
    this.uuid = uuid;
    return this;
  }

  UserModelBuilder setUsername(String username) {
    this.username = username;
    return this;
  }

  UserModelBuilder setEmail(String email) {
    this.email = email;
    return this;
  }

  UserModelBuilder setPassword(String password) {
    this.password = password;
    return this;
  }

  UserModelBuilder setRole(String role) {
    this.role = role;
    return this;
  }

  UserModelBuilder setOrgId(String orgId) {
    this.orgId = orgId;
    return this;
  }

  UserModelBuilder setOrgName(String orgName) {
    this.orgName = orgName;
    return this;
  }

  UserModelBuilder setLocId(String locId) {
    this.locId = locId;
    return this;
  }

  UserModelBuilder setLocName(String locName) {
    this.locName = locName;
    return this;
  }

  UserModelBuilder setAllowSummaryEdit(String allowSummaryEdit) {
    this.allowSummaryEdit = allowSummaryEdit;
    return this;
  }

  UserModelBuilder setUsers(List<String> users) {
    this.users = users;
    return this;
  }

  UserModel build() {
    if (uuid == null ||
        username == null ||
        email == null ||
        password == null ||
        role == null ||
        orgId == null ||
        orgName == null ||
        locId == null ||
        locName == null) {
      throw Exception('All fields are required');
    }

    return UserModel._builder(this);
  }
}

enum UserRole { superAdmin, orgAdmin, orgUser }
