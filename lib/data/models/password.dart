class Password {
  int? id;
  String title;
  String username;
  String password;

  Password({
    this.id,
    required this.title,
    required this.username,
    required this.password,
  });

  factory Password.fromMap(Map<String, dynamic> json) => Password(
        id: json['id'] as int?,
        title: json['title'] as String? ?? '',
        username: json['username'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
    };
  }
}
