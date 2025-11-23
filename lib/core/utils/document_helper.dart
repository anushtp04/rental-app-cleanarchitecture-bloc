import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class DocumentHelper {
  static Future<String?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        // Save to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final file = File(result.files.single.path!);
        final fileName = '${const Uuid().v4()}${path.extension(file.path)}';
        final savedFile = await file.copy('${appDir.path}/$fileName');
        return savedFile.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteDocument(String? documentPath) async {
    if (documentPath != null) {
      try {
        final file = File(documentPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore errors when deleting documents
      }
    }
  }

  static String getFileName(String? documentPath) {
    if (documentPath == null) return '';
    return path.basename(documentPath);
  }

  static String getFileExtension(String? documentPath) {
    if (documentPath == null) return '';
    return path.extension(documentPath).toLowerCase();
  }
}


