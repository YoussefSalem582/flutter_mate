/// Authentication result wrapper
class AuthResult {
  final bool isSuccess;
  final String message;
  final dynamic user;
  final bool isCancelled;

  AuthResult._({
    required this.isSuccess,
    required this.message,
    this.user,
    this.isCancelled = false,
  });

  factory AuthResult.success(dynamic user) {
    return AuthResult._(
      isSuccess: true,
      message: 'Success',
      user: user,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }

  factory AuthResult.cancelled() {
    return AuthResult._(
      isSuccess: false,
      message: 'Cancelled by user',
      isCancelled: true,
    );
  }
}
