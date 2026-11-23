import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'live_camera_view.dart';

/// Opens the in-app camera and returns the photo path to the caller
/// (`final path = await context.push<String>('/camera')`).
class LiveCameraScreen extends StatelessWidget {
  const LiveCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LiveCameraView(
          onCaptured: (path) => context.pop(path),
          onBack: () => context.pop(),
          onGallery: () async {
            final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 92, maxWidth: 2400);
            if (x != null && context.mounted) context.pop(x.path);
          },
        ),
      ),
    );
  }
}
