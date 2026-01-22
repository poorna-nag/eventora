import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    required File imageFile,
    required String path,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child('$path/$fileName');

      final String extension = imageFile.path.split('.').last.toLowerCase();
      final String contentType = extension == 'png'
          ? 'image/png'
          : 'image/jpeg';

      // Add metadata to help with upload
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {'uploaded': DateTime.now().toIso8601String()},
      );

      print('Uploading image to: $path/$fileName');
      final uploadTask = await ref.putFile(imageFile, metadata);
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
