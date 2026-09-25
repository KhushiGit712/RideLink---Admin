import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads raw file bytes to Firebase Storage and returns the public download URL.
  /// 
  /// Path format: `driver_documents/{driverId}/{docType}_{timestamp}.{ext}`
  static Future<String> uploadDriverDocument({
    required String driverId,
    required String docType,
    required Uint8List fileBytes,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final sanitizedDocType = docType
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_]'), '_');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.contains('.') ? fileName.split('.').last : 'jpg';
      final path = 'driver_documents/$driverId/${sanitizedDocType}_$timestamp.$extension';

      debugPrint('Uploading driver document to Firebase Storage: $path');

      final storageRef = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'driverId': driverId,
          'docType': docType,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = storageRef.putData(fileBytes, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Successfully uploaded to Firebase Storage. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Firebase Storage upload error: $e');
      rethrow;
    }
  }

  /// Delete a file from Firebase Storage given its download URL or reference path
  static Future<void> deleteFileByUrl(String fileUrl) async {
    try {
      if (fileUrl.isEmpty) return;
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      debugPrint('Deleted file from Firebase Storage: $fileUrl');
    } catch (e) {
      debugPrint('Error deleting file from Firebase Storage: $e');
    }
  }
}
