class TwoFactorPendingResponse {
  final bool requiresTwoFactor;
  final String twoFactorToken;

  TwoFactorPendingResponse({
    required this.requiresTwoFactor,
    required this.twoFactorToken,
  });

  factory TwoFactorPendingResponse.fromJson(Map<String, dynamic> json) {
    return TwoFactorPendingResponse(
      requiresTwoFactor: json['requiresTwoFactor'] as bool,
      twoFactorToken: json['twoFactorToken'] as String,
    );
  }
}