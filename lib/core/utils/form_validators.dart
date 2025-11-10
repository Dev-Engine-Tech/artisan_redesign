/// Form validation utilities following DRY principle
/// Centralized validation logic to avoid duplication across the codebase
class FormValidators {
  FormValidators._(); // Private constructor to prevent instantiation

  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter ${fieldName ?? 'this field'}';
    }
    return null;
  }

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s-()]+$');
    final cleanedValue = value.replaceAll(RegExp(r'[\s-()]'), '');

    if (!phoneRegex.hasMatch(value) || cleanedValue.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate password strength
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  /// Validate password confirmation
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Please enter ${fieldName ?? 'this field'}';
    }

    if (value.length < length) {
      return '${fieldName ?? 'This field'} must be at least $length characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int length, {String? fieldName}) {
    if (value != null && value.length > length) {
      return '${fieldName ?? 'This field'} must not exceed $length characters';
    }

    return null;
  }

  /// Validate numeric input
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter ${fieldName ?? 'a number'}';
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  /// Validate integer input
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter ${fieldName ?? 'a number'}';
    }

    if (int.tryParse(value.trim()) == null) {
      return 'Please enter a valid whole number';
    }

    return null;
  }

  /// Validate minimum value
  static String? minValue(String? value, double min, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter ${fieldName ?? 'a value'}';
    }

    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return 'Please enter a valid number';
    }

    if (numValue < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }

    return null;
  }

  /// Validate maximum value
  static String? maxValue(String? value, double max, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter ${fieldName ?? 'a value'}';
    }

    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return 'Please enter a valid number';
    }

    if (numValue > max) {
      return '${fieldName ?? 'Value'} must not exceed $max';
    }

    return null;
  }

  /// Validate URL format
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a URL';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }

  /// Custom validator with message
  static String? Function(String?) custom(
    bool Function(String?) test,
    String errorMessage,
  ) {
    return (value) {
      if (!test(value)) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Validate alphabetic characters only
  static String? alphabetic(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter ${fieldName ?? 'this field'}';
    }

    final alphaRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!alphaRegex.hasMatch(value.trim())) {
      return '${fieldName ?? 'This field'} should contain only letters';
    }

    return null;
  }

  /// Validate alphanumeric characters
  static String? alphanumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter ${fieldName ?? 'this field'}';
    }

    final alphanumRegex = RegExp(r'^[a-zA-Z0-9\s]+$');
    if (!alphanumRegex.hasMatch(value.trim())) {
      return '${fieldName ?? 'This field'} should contain only letters and numbers';
    }

    return null;
  }

  /// Validate date format (YYYY-MM-DD)
  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a date';
    }

    try {
      DateTime.parse(value.trim());
      return null;
    } catch (e) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
  }

  /// Validate future date
  static String? futureDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a date';
    }

    try {
      final date = DateTime.parse(value.trim());
      if (date.isBefore(DateTime.now())) {
        return 'Date must be in the future';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  /// Validate past date
  static String? pastDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a date';
    }

    try {
      final date = DateTime.parse(value.trim());
      if (date.isAfter(DateTime.now())) {
        return 'Date must be in the past';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }
}
