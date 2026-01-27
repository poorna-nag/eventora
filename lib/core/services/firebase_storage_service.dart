import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  // Explicitly using the bucket to avoid potential config issues on some platforms
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://eventora-d7ef2.firebasestorage.app',
  );

  Future<String> uploadImage({
    required File imageFile,
    required String path,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child('$path/$fileName');

      print('Uploading image to: $path/$fileName');
      // Read file as bytes to avoid iOS file path access issues (Error 40)
      final bytes = await imageFile.readAsBytes();
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('Upload successful: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage Error: ${e.code} - ${e.message}');
      throw Exception('Failed to upload image: ${e.message ?? e.code}');
    } catch (e) {
      print('Upload Error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadEventImage(File imageFile) async {
    return uploadImage(imageFile: imageFile, path: 'events');
  }

  Future<String> uploadProfileImage(File imageFile) async {
    return uploadImage(imageFile: imageFile, path: 'profiles');
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
