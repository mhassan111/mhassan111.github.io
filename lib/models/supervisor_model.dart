class Supervisor {
  String id;
  String name;
  List<String> userEmails;

  Supervisor({
    required this.id,
    required this.name,
    required this.userEmails,
  });

  factory Supervisor.fromMap(Map<String, dynamic> data) {
    var emailsList = (data['user_emails'] as List?)
        ?.map((email) => email.toString())
        .toList() ??
        [];

    return Supervisor(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      userEmails: emailsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'user_emails': userEmails,
    };
  }
}
