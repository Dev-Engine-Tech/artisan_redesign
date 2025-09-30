import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

Future<String?> uploadFile(
  FirebaseStorage storage,
  String localPath,
  String remotePath,
  String contentType,
) async {
  final file = File(localPath);
  final ref = storage.ref(remotePath);
  final task =
      await ref.putFile(file, SettableMetadata(contentType: contentType));
  return task.ref.getDownloadURL();
}
