import 'dart:io';
import 'package:flutter/material.dart';

class CarImageWidget extends StatelessWidget {
  final String? imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;

  const CarImageWidget({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  bool _isNetworkImage(String? path) {
    if (path == null) return false;
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Icon(
          Icons.directions_car,
          size: 48,
          color: Colors.grey[400],
        ),
      );
    }

    if (_isNetworkImage(imagePath)) {
      return Image.network(
        imagePath!,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Icon(
              Icons.broken_image,
              size: 48,
              color: Colors.grey[400],
            ),
          );
        },
      );
    }

    // Local file
    return Image.file(
      File(imagePath!),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey[400],
          ),
        );
      },
    );
  }
}
