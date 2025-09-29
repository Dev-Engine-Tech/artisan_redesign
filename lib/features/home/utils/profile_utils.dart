import 'package:artisans_circle/features/auth/domain/entities/user.dart';

class ProfileUtils {
  /// Calculate profile completion progress based on user data
  /// Returns a value between 0.0 and 1.0
  static double calculateProfileProgress(User user) {
    int totalFields = 5;
    int completedFields = 0;

    // 1. Bio/About me
    if (user.bio != null && user.bio!.isNotEmpty) {
      completedFields++;
    }

    // 2. Skills
    if (user.skills != null && user.skills!.isNotEmpty) {
      completedFields++;
    }

    // 3. Location (state/LGA)
    if (user.state != null && user.state!.isNotEmpty) {
      completedFields++;
    }

    // 4. Years of experience
    if (user.yearsOfExperience != null && user.yearsOfExperience! > 0) {
      completedFields++;
    }

    // 5. Profile picture
    if (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty) {
      completedFields++;
    }

    return completedFields / totalFields;
  }

  /// Get profile completion status as a percentage string
  static String getProfileStatus(User user) {
    double progress = calculateProfileProgress(user) * 100;

    if (progress >= 100) {
      return "Excellent";
    } else if (progress >= 80) {
      return "Good";
    } else if (progress >= 60) {
      return "Fair";
    } else {
      return "Poor";
    }
  }

  /// Check if profile is complete
  static bool isProfileComplete(User user) {
    return calculateProfileProgress(user) >= 1.0;
  }
}
