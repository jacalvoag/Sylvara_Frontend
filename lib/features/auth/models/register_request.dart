class RegisterRequest {
  final String name;
  final String lastname;
  final String birthday;
  final String email;
  final String password;

  RegisterRequest({
    required this.name,
    required this.lastname,
    required this.birthday,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'userName': name,
    'userLastname': lastname,
    'userBirthday': birthday,
    'userEmail': email,
    'userPassword': password,
  };
}