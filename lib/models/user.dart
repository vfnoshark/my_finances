class User {
  final String login;
  final String? name;
  final String? token;

  User({
    required this.login,
    this.name,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['login'] as String,
      name: json['name'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'name': name,
      'token': token,
    };
  }
}