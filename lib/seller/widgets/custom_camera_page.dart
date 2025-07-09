import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CustomCameraPage extends StatefulWidget {
  const CustomCameraPage({super.key});

  @override
  State<CustomCameraPage> createState() => _CustomCameraPageState();
}

class _CustomCameraPageState extends State<CustomCameraPage> {
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _capturePhoto() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final file = await _controller!.takePicture();
      Navigator.of(context).pop(file); // Kembalikan XFile ke halaman sebelumnya!
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? Stack(
              children: [
                Center(child: CameraPreview(_controller!)),
                // Overlay Template
                Positioned.fill(
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/icons/registration/ktp_overlay.png', // PNG overlay transparan
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Tombol capture
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.camera, color: Colors.black),
                      onPressed: _capturePhoto,
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
