class UserProfile {
  final int userId;
  final String userName;
  final String userLastname;
  final String userBirthday;
  final String userEmail;
  final String profilePictureUrl;
  final String userRole;

  UserProfile({
    required this.userId,
    required this.userName,
    required this.userLastname,
    required this.userBirthday,
    required this.userEmail,
    required this.profilePictureUrl,
    required this.userRole,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      userLastname: json['userLastname'] as String,
      userBirthday: json['userBirthday']?.toString() ?? '',
      userEmail: json['userEmail'] as String,
      profilePictureUrl: (json['profilePictureUrl'] as String?) ?? '',
      userRole: json['userRole'] as String? ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'name': userName,
      'lastname': userLastname,
      'birthday': userBirthday,
      'email': userEmail,
      'pictureUrl': profilePictureUrl,
      'role': userRole,
    };
  }

  UserProfile copyWith({
    int? userId,
    String? userName,
    String? userLastname,
    String? userBirthday,
    String? userEmail,
    String? profilePictureUrl,
    String? userRole,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userLastname: userLastname ?? this.userLastname,
      userBirthday: userBirthday ?? this.userBirthday,
      userEmail: userEmail ?? this.userEmail,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      userRole: userRole ?? this.userRole,
    );
  }
}

class UpdateProfileRequest {
  final String userName;
  final String userLastname;
  final String userBirthday;
  final String userEmail;
  final String profilePictureUrl;

  UpdateProfileRequest({
    required this.userName,
    required this.userLastname,
    required this.userBirthday,
    required this.userEmail,
    required this.profilePictureUrl,
  });

  Map<String, dynamic> toJson() => {
    if (userName.isNotEmpty) 'userName': userName,
    if (userLastname.isNotEmpty) 'userLastname': userLastname,
    if (userBirthday.isNotEmpty) 'userBirthday': userBirthday,
    if (userEmail.isNotEmpty) 'userEmail': userEmail,
    if (profilePictureUrl.isNotEmpty) 'profilePictureUrl': profilePictureUrl,
  };
}

class UpdatePasswordRequest {
  final String currentPassword;
  final String newPassword;

  UpdatePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}

class ProfileException implements Exception {
  final String message;
  final int statusCode;

  ProfileException({
    required this.message,
    this.statusCode = 500,
  });

  @override
  String toString() => 'ProfileException($statusCode): $message';
}