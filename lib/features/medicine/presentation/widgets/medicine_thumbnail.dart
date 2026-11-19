import 'dart:io';

import 'package:flutter/material.dart';

class MedicineThumbnail extends StatelessWidget {
  const MedicineThumbnail({super.key, this.path, this.size = 64, this.label});
  final String? path;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: const Color(0xFFE6EEF2),
      child: Icon(Icons.medication, size: size * 0.5),
    );
    return Semantics(
      image: true,
      label: label ?? (path == null ? 'No photo' : 'Medicine photo'),
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: path == null
              ? placeholder
              : Image.file(File(path!),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  cacheWidth: (size * 3).round(),
                  errorBuilder: (_, __, ___) => placeholder),
        ),
      ),
    );
  }
}
