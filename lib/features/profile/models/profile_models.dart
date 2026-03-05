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
      userId: json['id'] as int,
      userName: json['name'] as String,
      userLastname: json['lastname'] as String,
      userBirthday: json['birthday']?.toString() ?? '',
      userEmail: json['email'] as String,
      profilePictureUrl: (json['pictureUrl'] as String?) ?? '',
      userRole: json['role'] as String? ?? 'USER',
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

  Map<String, dynamic> toJson() {
    return {
      'name': userName,
      'lastname': userLastname,
      'birthday': userBirthday,
      'email': userEmail,
      if (profilePictureUrl.isNotEmpty) 'pictureUrl': profilePictureUrl,
    };
  }
}

class UpdatePasswordRequest {
  final String currentPassword;
  final String newPassword;

  UpdatePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
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