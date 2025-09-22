import 'package:firebase_storage/firebase_storage.dart';

Future<String?> uploadFile(
  FirebaseStorage storage,
  String localPath,
  String remotePath,
  String contentType,
) async {
  // On web, we receive a local file system path which isn't usable.
  // Return null to fallback to using the original path (UI will render an icon).
  return null;
}

