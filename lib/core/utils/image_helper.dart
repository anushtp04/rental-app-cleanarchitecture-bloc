import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        // Save to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${const Uuid().v4()}${path.extension(image.path)}';
        final savedImage = await File(image.path).copy(
          '${appDir.path}/$fileName',
        );
        return savedImage.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${const Uuid().v4()}${path.extension(image.path)}';
        final savedImage = await File(image.path).copy(
          '${appDir.path}/$fileName',
        );
        return savedImage.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteImage(String? imagePath) async {
    if (imagePath != null) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore errors when deleting images
      }
    }
  }
}

