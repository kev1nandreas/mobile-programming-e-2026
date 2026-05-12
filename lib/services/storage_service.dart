import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadImage({
    required File file,
    required String folder,
  }) async {
    final ref = _storage.ref().child('$folder/${_uuid.v4()}.jpg');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
