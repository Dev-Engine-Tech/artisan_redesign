import 'package:share_plus/share_plus.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:flutter/services.dart';

class JobShareService {
  static const String _appName = 'Artisans Circle';
  static const String _appStoreUrl =
      'https://apps.apple.com/app/artisans-circle/id123456789';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.artisanscircle.app';
  static const String _webUrl = 'https://artisanscircle.com';

  /// Share a job with formatted text and app promotion
  static Future<void> shareJob(Job job, {String? subject}) async {
    try {
      final shareText = _formatJobShareText(job);

      await Share.share(
        shareText,
        subject: subject ?? 'Check out this job opportunity on $_appName',
      );
    } catch (e) {
      // Log error but don't throw to avoid breaking the UI
      // ignore: avoid_print
    }
  }

  /// Share a job with additional context for referrals
  static Future<void> shareJobAsReferral(Job job,
      {String? personalMessage}) async {
    try {
      final shareText = _formatJobReferralText(job, personalMessage);

      await Share.share(
        shareText,
        subject: 'Job Opportunity Referral - $_appName',
      );
    } catch (e) {
      // ignore: avoid_print
    }
  }

  /// Share multiple jobs as a collection
  static Future<void> shareJobCollection(
      List<Job> jobs, String collectionName) async {
    try {
      final shareText = _formatJobCollectionText(jobs, collectionName);

      await Share.share(
        shareText,
        subject: '$collectionName - $_appName',
      );
    } catch (e) {
      // ignore: avoid_print
    }
  }

  /// Copy job details to clipboard
  static Future<void> copyJobToClipboard(Job job) async {
    try {
      final jobText = _formatJobShareText(job);
      await Clipboard.setData(ClipboardData(text: jobText));
    } catch (e) {
      // ignore: avoid_print
    }
  }

  /// Share app with download links
  static Future<void> shareApp({String? personalMessage}) async {
    try {
      final shareText = _formatAppShareText(personalMessage);

      await Share.share(
        shareText,
        subject: 'Join me on $_appName - Find Your Next Project',
      );
    } catch (e) {
      // ignore: avoid_print
    }
  }

  static String _formatJobShareText(Job job) {
    final budget = job.minBudget == job.maxBudget
        ? '₦${job.maxBudget.toStringAsFixed(0)}'
        : '₦${job.minBudget.toStringAsFixed(0)} - ₦${job.maxBudget.toStringAsFixed(0)}';

    return '''
🔨 ${job.title}

💰 Budget: $budget
⏱️ Duration: ${job.duration}
📍 Location: ${job.address}
🏷️ Category: ${job.category}

${job.description.length > 200 ? '${job.description.substring(0, 200)}...' : job.description}

Find this job and many more on $_appName!

📱 Download the app:
iOS: $_appStoreUrl
Android: $_playStoreUrl
Web: $_webUrl

#ArtisansCircle #Jobs #${job.category.replaceAll(' ', '')}
''';
  }

  static String _formatJobReferralText(Job job, String? personalMessage) {
    final budget = job.minBudget == job.maxBudget
        ? '₦${job.maxBudget.toStringAsFixed(0)}'
        : '₦${job.minBudget.toStringAsFixed(0)} - ₦${job.maxBudget.toStringAsFixed(0)}';

    return '''
${personalMessage != null ? '$personalMessage\n\n' : ''}Hi! I found this job opportunity that might interest you:

🔨 ${job.title}
💰 Budget: $budget
⏱️ Duration: ${job.duration}
📍 Location: ${job.address}

${job.description.length > 150 ? '${job.description.substring(0, 150)}...' : job.description}

You can apply through $_appName:

📱 Download the app:
iOS: $_appStoreUrl
Android: $_playStoreUrl
Web: $_webUrl

Good luck! 🍀
''';
  }

  static String _formatJobCollectionText(
      List<Job> jobs, String collectionName) {
    final jobsPreview = jobs.take(3).map((job) {
      final budget = job.minBudget == job.maxBudget
          ? '₦${job.maxBudget.toStringAsFixed(0)}'
          : '₦${job.minBudget.toStringAsFixed(0)} - ₦${job.maxBudget.toStringAsFixed(0)}';

      return '• ${job.title} - $budget (${job.duration})';
    }).join('\n');

    return '''
📋 $collectionName

Here are ${jobs.length} great job opportunities:

$jobsPreview${jobs.length > 3 ? '\n... and ${jobs.length - 3} more!' : ''}

Find these jobs and apply on $_appName!

📱 Download the app:
iOS: $_appStoreUrl
Android: $_playStoreUrl
Web: $_webUrl

#ArtisansCircle #Jobs #Opportunities
''';
  }

  static String _formatAppShareText(String? personalMessage) {
    return '''
${personalMessage != null ? '$personalMessage\n\n' : ''}🔨 Join me on $_appName!

The best platform for artisans to:
✅ Find high-quality job opportunities
✅ Connect with verified clients
✅ Secure guaranteed payments
✅ Build your professional network
✅ Showcase your skills

📱 Download now:
iOS: $_appStoreUrl
Android: $_playStoreUrl
Web: $_webUrl

#ArtisansCircle #Artisans #Jobs #Construction #HomeServices
''';
  }

  /// Share result callback for analytics or UI feedback
  static Future<ShareResult?> shareJobWithResult(Job job,
      {String? subject}) async {
    try {
      final shareText = _formatJobShareText(job);

      final result = await Share.shareWithResult(
        shareText,
        subject: subject ?? 'Check out this job opportunity on $_appName',
      );

      return result;
    } catch (e) {
      // ignore: avoid_print
      return null;
    }
  }

  /// Share to specific platforms (if needed for future implementation)
  static Future<void> shareJobToWhatsApp(Job job) async {
    // This would require additional WhatsApp-specific implementation
    // For now, use the standard share which will show WhatsApp as an option
    await shareJob(job);
  }

  static Future<void> shareJobToEmail(Job job, {String? emailSubject}) async {
    // This would require additional email-specific implementation
    // For now, use the standard share which will show email as an option
    await shareJob(job, subject: emailSubject);
  }
}
