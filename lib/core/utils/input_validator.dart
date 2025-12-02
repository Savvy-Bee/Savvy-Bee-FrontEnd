class InputValidator {
  // Checks if a string is not empty or just whitespace.
  static String? validateRequired(
    String? value,
    String fieldName, {
    int? minLength,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty.';
    }
    if (minLength != null && value.length < minLength) {
      return '$fieldName must be at least $minLength characters long.';
    }
    return null; // Valid
  }

  // Checks if a string is not empty or just whitespace.
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username cannot be empty.';
    }
    if (value.length < 6) {
      return 'Username must be at least 6 characters long.';
    }
    if (value.length > 20) {
      return 'Username must not exceed 20 characters.';
    }
    if (value.contains(' ')) {
      return 'Username cannot contain whitespaces.';
    }
    if (value.contains(RegExp(r'[A-Z]'))) {
      return 'Username cannot contain uppercase characters.';
    }
    if (!RegExp(r'^[a-z0-9_-]+$').hasMatch(value)) {
      return 'Username can only contain lowercase letters, numbers, underscores, and hyphens.';
    }
    if (RegExp(r'^[_-]|[_-]$').hasMatch(value)) {
      return 'Username cannot start or end with underscore or hyphen.';
    }
    return null;
  }

  // Validates if a string is a valid name (only letters and spaces).
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty.';
    }
    // Regex for name validation (letters and spaces only)
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return '$fieldName must contain only letters and spaces.';
    }
    return null; // Valid
  }

  // Email validation.
  static String? validateEmail(String? email, {bool isRequired = true}) {
    if (isRequired && (email == null || email.isEmpty)) {
      return 'Email cannot be empty.';
    }
    if (email == null || email.isEmpty) {
      return null;
    }
    // Simple regex for email validation
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null; // Valid
  }

  // Password validation: at least 8 characters, one uppercase, one lowercase, one digit.
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit.';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }
    return null; // Valid
  }

  // Confirms two passwords match.
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (validateRequired(confirmPassword, 'Confirm password') != null) {
      return validateRequired(confirmPassword, 'Confirm password');
    }
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }
    return null; // Valid
  }
}
