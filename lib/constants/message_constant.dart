class ValidatorMessage {
  static String emptyAmount = "Please enter an amount.";
  static String emptyAmountToPay = "Empty amount.";
  static String invalidAmount = "Please enter a valid amount.";
  static String invalidAmountToPay = "Invalid amount.";
  static String invalidTotalAmount = "The total split amounts must be exactly same as the total amount.";
  static String emptyGoalTitle = "Please enter a goal title.";
  static String emptyTransactionTitle = "Please enter a transaction title.";
  static String emptyEmail = "Please enter your email.";
  static String invalidEmail = "Please enter a valid email address.";
  static String emptyName = "Please enter your name.";
  static String emptyUsername = "Please enter your username.";
  static String emptyPassword = "Please enter your password.";
  static String invalidPassword = "Password must be at least 6 characters.";
  static String passwordsNotMatch = "Passwords do not match.";
  static String emptyGroupName = "Please enter a group name.";
  static String emptyGroupExpenseTitle = "Please enter a group expense title.";
  static String emptySharedBy = "Please select a member to share the cost.";
  static String repeatCategory = "The chosen category is existed.";
  static String emptyBillTitle = "Please enter a bill title.";
  static String emptyDebtTitle = "Please enter a debt title.";
  static String emptyDuration = "Enter a debt duration.";
  static String invalidDuration = "Please enter a valid duration.";
}

class SuccessMessage {
  static String resetPassword =
      "Password reset email has been sent to your email address.";
}

class ExceptionMessage {
  static String noSuchUser = "No user found for this email.";
}

class AuthExceptionMessage {
  static AuthException userNotFound =
      AuthException('user-not-found', 'No user found for that email.');
  static AuthException invalidEmail =
      AuthException('invalid-email', 'Invalid email address.');
  static AuthException wrongPassword =
      AuthException('wrong-password', 'Wrong password provided for that user.');
}

class AuthException {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  String get getCode => code;
  String get getMessage => message;
}
