class PhoneNumberFilter {
  /// Comprehensive regex patterns for detecting phone numbers in various formats
  static final List<RegExp> _phoneNumberPatterns = [
    // Nigerian numbers (various formats)
    RegExp(r'\b(?:\+234|234|0)(?:70|80|81|90|91|71)[0-9]{8}\b'),

    // International formats
    RegExp(r'\+[1-9]\d{1,14}'), // E.164 format
    RegExp(r'\b\d{3}-\d{3}-\d{4}\b'), // US format: 123-456-7890
    RegExp(r'\b\d{3}\.\d{3}\.\d{4}\b'), // US format: 123.456.7890
    RegExp(r'\b\(\d{3}\)\s?\d{3}-?\d{4}\b'), // US format: (123) 456-7890

    // General patterns
    RegExp(r'\b\d{10,15}\b'), // 10-15 consecutive digits
    RegExp(
        r'\b\d{3,4}[\s\-\.]\d{3,4}[\s\-\.]\d{3,4}\b'), // Separated by spaces, hyphens, or dots
    RegExp(
        r'\b\d{2,3}[\s\-\.]\d{3,4}[\s\-\.]\d{3,4}[\s\-\.]\d{3,4}\b'), // 4-part numbers

    // WhatsApp format
    RegExp(r'\bwa\.me\/\+?\d{10,15}\b', caseSensitive: false),

    // Common phone number keywords followed by numbers
    RegExp(
        r'\b(?:phone|tel|mobile|cell|whatsapp|call|contact)[\s\:]*[\+\d\(\)\-\s\.]{7,20}\b',
        caseSensitive: false),

    // Numbers with country codes
    RegExp(r'\b\+\d{1,3}[\s\-\.]?\d{1,4}[\s\-\.]?\d{1,4}[\s\-\.]?\d{1,9}\b'),
  ];

  /// Checks if the given text contains any phone numbers
  static bool containsPhoneNumber(String text) {
    if (text.trim().isEmpty) return false;

    // Clean the text by removing excessive whitespace
    String cleanText = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Check against all patterns
    for (RegExp pattern in _phoneNumberPatterns) {
      if (pattern.hasMatch(cleanText)) {
        return true;
      }
    }

    // Additional check for sequences of digits that might be phone numbers
    // Look for 7+ consecutive digits (common phone number length)
    RegExp digitSequence = RegExp(r'\b\d{7,}\b');
    Iterable<Match> digitMatches = digitSequence.allMatches(cleanText);

    for (Match match in digitMatches) {
      String digits = match.group(0)!;

      // Skip if it's likely a date, year, or other non-phone number
      if (_isLikelyPhoneNumber(digits)) {
        return true;
      }
    }

    return false;
  }

  /// Removes phone numbers from the text and returns cleaned text
  static String removePhoneNumbers(String text) {
    if (text.trim().isEmpty) return text;

    String cleanedText = text;

    // Remove matches for each pattern
    for (RegExp pattern in _phoneNumberPatterns) {
      cleanedText = cleanedText.replaceAll(pattern, '[Phone number removed]');
    }

    // Clean up any remaining suspicious digit sequences
    RegExp digitSequence = RegExp(r'\b\d{7,}\b');
    cleanedText = cleanedText.replaceAllMapped(digitSequence, (match) {
      String digits = match.group(0)!;
      return _isLikelyPhoneNumber(digits) ? '[Phone number removed]' : digits;
    });

    // Clean up multiple consecutive removals
    cleanedText = cleanedText.replaceAll(
        RegExp(r'(\[Phone number removed\]\s*){2,}'),
        '[Phone number removed] ');

    return cleanedText.trim();
  }

  /// Helper method to determine if a sequence of digits is likely a phone number
  static bool _isLikelyPhoneNumber(String digits) {
    // Skip years (1900-2099)
    if (digits.length == 4 && int.tryParse(digits) != null) {
      int year = int.parse(digits);
      if (year >= 1900 && year <= 2099) return false;
    }

    // Skip common non-phone patterns
    if (digits.length < 7 || digits.length > 15) return false;

    // Skip if all digits are the same (like 1111111)
    if (RegExp(r'^(\d)\1+$').hasMatch(digits)) return false;

    // Skip if it's likely a sequential number (like 1234567)
    if (_isSequential(digits)) return false;

    // Skip common non-phone number patterns
    if (digits == '1000' || digits == '2023' || digits == '123456') {
      return false;
    }

    return true;
  }

  /// Checks if digits are in sequential order
  static bool _isSequential(String digits) {
    if (digits.length < 4) return false;

    for (int i = 0; i < digits.length - 1; i++) {
      int current = int.parse(digits[i]);
      int next = int.parse(digits[i + 1]);

      // Check for ascending sequence
      if (next != current + 1) {
        // Check for descending sequence
        bool descending = true;
        for (int j = 0; j < digits.length - 1; j++) {
          int curr = int.parse(digits[j]);
          int nxt = int.parse(digits[j + 1]);
          if (nxt != curr - 1) {
            descending = false;
            break;
          }
        }
        return descending;
      }
    }
    return true;
  }

  /// Gets a user-friendly message about phone number detection
  static String getPhoneNumberWarningMessage() {
    return "Phone numbers are not allowed in messages for privacy and security reasons.";
  }
}
