class User {
  final dynamic id;
  final String name;
  final String lastname;
  final String? birthday;
  final String email;
  final String? role;

  User({
    required this.id,
    required this.name,
    required this.lastname,
    this.birthday,
    required this.email,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'],
      name: json['userName'] as String,
      lastname: json['userLastname'] as String,
      birthday: json['userBirthday']?.toString(),
      email: json['userEmail'] as String,
      role: json['userRole'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'userName': name,
      'userLastname': lastname,
      'userBirthday': birthday,
      'userEmail': email,
      'userRole': role,
    };
  }

  String get fullName => '$name $lastname';
}