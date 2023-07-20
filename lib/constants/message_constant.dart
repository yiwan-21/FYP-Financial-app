class ValidatorMessage {
  static String emptyAmount = "Please enter an amount.";
  static String invalidAmount = "Please enter a valid amount.";
  static String emptyGoalTitle = "Please enter a goal title.";
  static String emptyTransactionTitle = "Please enter a transaction title.";
  static String emptyEmail = "Please enter your email.";
  static String invalidEmail = "Please enter a valid email address.";
  static String emptyName = "Please enter your name.";
  static String emptyUsername = "Please enter your username.";
  static String emptyPassword = "Please enter your password.";
  static String invalidPassword = "Password must be at least 6 characters.";
  static String passwordsNotMatch = "Passwords do not match.";
}

class SuccessMessage {
  static String resetPassword = "Password reset email has been sent to your email address.";
}

class AuthExceptionMessage {
  static AuthException userNotFound = AuthException('user-not-found', 'No user found for that email.');
  static AuthException invalidEmail = AuthException('invalid-email', 'Invalid email address.');
  static AuthException wrongPassword = AuthException('wrong-password', 'Wrong password provided for that user.');
}

class AuthException {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  String get getCode => code;
  String get getMessage => message;
}
