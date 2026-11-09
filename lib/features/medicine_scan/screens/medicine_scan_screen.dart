import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/image_recognition_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../database/daos/medicine_dao_provider.dart';
import '../services/matching_engine.dart';
import '../services/ocr_service.dart';

class MedicineScanScreen extends ConsumerStatefulWidget {
  const MedicineScanScreen({super.key});

  @override
  ConsumerState<MedicineScanScreen> createState() => _MedicineScanScreenState();
}

class _MedicineScanScreenState extends ConsumerState<MedicineScanScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _isCameraInitialized = false);
        return;
      }
      // Use the back camera
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() => _isProcessing = true);
    try {
      // 1. Get prefs ONCE here
      final prefs = await SharedPreferences.getInstance();
      final userLang = prefs.getString(AppConstants.prefLanguage) ?? 'en';

      // 2. Run OCR
      final ocr = await OcrService.extractText(imageFile, userLang);

      // 3. Run AI Embedding
      final scanEmbedding =
          await ImageRecognitionService.generateEmbedding(imageFile);

      // 4. Fetch Data (Reuse prefs from above)
      final userId = prefs.getString(AppConstants.prefUserId) ?? 'local-user';
      final dao = ref.read(medicineDaoProvider);

      final registered = await dao.getAllMedicines(userId);
      final savedEmbeddings = await dao.getAllEmbeddings();

      // 5. Match
      final result = MatchingEngine.match(
        ocrText: ocr.rawText,
        scanEmbedding: scanEmbedding,
        registeredMedicines: registered,
        savedEmbeddings: savedEmbeddings,
      );

      if (!mounted) return;
      context.push('/scan/result', extra: {
        'file': imageFile,
        'result': result,
      });
    } catch (e) {
      // ... error handling
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile picture = await _controller!.takePicture();
      await _processImage(File(picture.path));
    } catch (e) {
      // Handle capture error
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Medicine'),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : !_isCameraInitialized
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Stack(
                  children: [
                    // Live Camera Preview
                    Positioned.fill(
                      child: CameraPreview(_controller!),
                    ),
                    // Full-Screen Portrait Overlay (leaving 16px on edges)
                    Positioned(
                      top: 24,
                      bottom: 120, // Leave space for the shutter button
                      left: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 24.0),
                            child: Text(
                              'Align medicine inside the box',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                        blurRadius: 4,
                                        color: Colors.black54,
                                        offset: Offset(0, 1))
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Shutter Button
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FloatingActionButton(
                          onPressed: _takePicture,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.camera_alt,
                              color: Colors.black, size: 32),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
