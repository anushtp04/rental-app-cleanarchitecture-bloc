import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase;

  SupabaseStorageService(this._supabase);

  // Get current user ID
  String get _userId => _supabase.auth.currentUser?.id ?? '';

  // Check if a path is a cloud URL
  bool isCloudUrl(String? path) {
    if (path == null) return false;
    return path.startsWith('http://') || path.startsWith('https://');
  }

  // Upload car image
  Future<String> uploadCarImage(String localPath, String carId) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final file = File(localPath);
      final fileName = 'car_$carId${_getFileExtension(localPath)}';
      // Path must include user ID as first folder to match RLS policy
      final path = '$_userId/$fileName';

      await _supabase.storage.from('car-images').upload(
            path,
            file,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _getMimeType(localPath),
            ),
          );

      final publicUrl = _supabase.storage.from('car-images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading car image: $e');
      throw Exception('Failed to upload car image: $e');
    }
  }

  // Delete car image
  Future<void> deleteCarImage(String carId) async {
    try {
      if (_userId.isEmpty) {
        debugPrint('User not authenticated, skipping delete');
        return;
      }

      // List all files in user's folder
      final files = await _supabase.storage.from('car-images').list(path: _userId);
      
      // Find and delete files matching the car ID
      for (final file in files) {
        if (file.name.startsWith('car_$carId')) {
          await _supabase.storage.from('car-images').remove(['$_userId/${file.name}']);
        }
      }
    } catch (e) {
      // Silently fail if image doesn't exist
      debugPrint('Failed to delete car image: $e');
    }
  }

  // Upload rental image
  Future<String> uploadRentalImage(String localPath, String rentalId) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final file = File(localPath);
      final fileName = 'rental_image_$rentalId${_getFileExtension(localPath)}';
      // Path must include user ID as first folder to match RLS policy
      final path = '$_userId/$fileName';

      await _supabase.storage.from('rental-files').upload(
            path,
            file,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _getMimeType(localPath),
            ),
          );

      final publicUrl = _supabase.storage.from('rental-files').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading rental image: $e');
      throw Exception('Failed to upload rental image: $e');
    }
  }

  // Upload rental document
  Future<String> uploadRentalDocument(String localPath, String rentalId) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final file = File(localPath);
      final fileName = 'rental_document_$rentalId${_getFileExtension(localPath)}';
      // Path must include user ID as first folder to match RLS policy
      final path = '$_userId/$fileName';

      await _supabase.storage.from('rental-files').upload(
            path,
            file,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _getMimeType(localPath),
            ),
          );

      final publicUrl = _supabase.storage.from('rental-files').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading rental document: $e');
      throw Exception('Failed to upload rental document: $e');
    }
  }

  // Delete rental files (image and document)
  Future<void> deleteRentalFiles(String rentalId) async {
    try {
      if (_userId.isEmpty) {
        debugPrint('User not authenticated, skipping delete');
        return;
      }

      // List all files in user's folder
      final files = await _supabase.storage.from('rental-files').list(path: _userId);
      
      // Find and delete files matching the rental ID
      for (final file in files) {
        if (file.name.startsWith('rental_image_$rentalId') || 
            file.name.startsWith('rental_document_$rentalId')) {
          await _supabase.storage.from('rental-files').remove(['$_userId/${file.name}']);
        }
      }
    } catch (e) {
      // Silently fail if files don't exist
      debugPrint('Failed to delete rental files: $e');
    }
  }

  // Helper method to get file extension
  String _getFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';
    return path.substring(lastDot);
  }

  // Helper method to get MIME type
  String? _getMimeType(String path) {
    final ext = _getFileExtension(path).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      default:
        return null; // Let Supabase try to detect or default
    }
  }
}
