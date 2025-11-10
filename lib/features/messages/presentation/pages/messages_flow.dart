/// Messages flow - unified export for messages feature pages
///
/// This file provides backward compatibility for existing imports.
/// The actual implementations have been split into separate files:
/// - messages_list_page.dart: List of all conversations
/// - chat_page.dart: Individual conversation view
///
/// Usage (existing code will continue to work):
/// ```dart
/// import 'package:artisans_circle/features/messages/presentation/pages/messages_flow.dart';
///
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => MessagesListPage(),
/// ));
///
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => ChatPage(conversation: conversation),
/// ));
/// ```
library;

export 'messages_list_page.dart';
export 'chat_page.dart';
