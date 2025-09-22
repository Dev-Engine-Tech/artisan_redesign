import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  static const List<Map<String, String>> channels = [
    {
      "title": "Chat with us",
      "img": "msg",
      "handle": "https://wa.me/+2348117672244"
    },
    {"title": "Email us", "img": "mail", "handle": "info@artisansbridge.com"},
    {"title": "Call us", "img": "call", "handle": "+2348117672244"},
    {
      "title": "Facebook",
      "img": "facebook",
      "handle":
          "https://www.facebook.com/share/58HcoxDxiXAdVjwk/?mibextid=LQQJ4d",
    },
    {
      "title": "LinkedIn",
      "img": "linkedIn",
      "handle": "https://www.linkedin.com/company/artisansbridge/"
    },
    {
      "title": "Instagram",
      "img": "instagram",
      "handle": "https://www.instagram.com/artisansbridge/"
    },
    {"title": "Twitter", "img": "x", "handle": "https://x.com/artisansbridge"},
  ];

  Future<void> _openLink(String title, String handle) async {
    Uri url;
    switch (title) {
      case 'Email us':
        url = Uri.parse('mailto:$handle');
        break;
      case 'Call us':
        url = Uri.parse('tel:$handle');
        break;
      default:
        url = Uri.parse(handle);
    }
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: ListView.separated(
        itemCount: channels.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (ctx, i) {
          final item = channels[i];
          return ListTile(
            leading: const Icon(Icons.link),
            title: Text(item['title']!),
            onTap: () => _openLink(item['title']!, item['handle']!),
          );
        },
      ),
    );
  }
}
