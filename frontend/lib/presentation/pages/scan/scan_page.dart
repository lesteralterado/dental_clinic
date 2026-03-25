import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart' as camera;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../di/injection_container.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../data/models/patient_model.dart';
import '../../../core/services/face_recognition_service.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Patient'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.face),
              text: 'Face',
            ),
            Tab(
              icon: Icon(Icons.qr_code),
              text: 'QR Code',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FaceScanTab(),
          _QRScanTab(),
        ],
      ),
    );
  }
}

class _FaceScanTab extends StatefulWidget {
  @override
  State<_FaceScanTab> createState() => _FaceScanTabState();
}

class _FaceScanTabState extends State<_FaceScanTab> {
  bool _isScanning = false;
  String _statusMessage = 'Ready';
  camera.CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableTracking: true,
      enableLandmarks: true,
      enableClassification: true,
    ),
  );
  final PatientRepository _patientRepository = sl<PatientRepository>();
  final FaceRecognitionService _faceService = sl<FaceRecognitionService>();
  bool _isSearching = false;
  bool _isCameraInitialized = false;

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _startCameraScan() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
      return;
    }

    setState(() {
      _isScanning = true;
      _statusMessage = 'Initializing camera...';
    });

    try {
      final cameras = await camera.availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == camera.CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = camera.CameraController(
        frontCamera,
        camera.ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _statusMessage = 'Scanning for faces...';
        });
        _processCameraFrames();
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _processCameraFrames() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    while (_isScanning && mounted) {
      try {
        final XFile imageFile = await _cameraController!.takePicture();
        final inputImage = InputImage.fromFilePath(imageFile.path);
        final faces = await _faceDetector.processImage(inputImage);

        if (faces.isNotEmpty) {
          // Face detected
          setState(() {
            _statusMessage = 'Face detected! Searching patient...';
          });

          // Stop scanning and show result
          await _stopCameraScan();

          if (mounted) {
            _showFaceDetectedDialog(faces.first);
          }
          return;
        }
      } catch (e) {
        // Continue scanning on error
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _stopCameraScan() async {
    setState(() {
      _isScanning = false;
      _isCameraInitialized = false;
      _statusMessage = 'Ready';
    });
    await _cameraController?.dispose();
    _cameraController = null;
  }

  Future<void> _selectFromGallery() async {
    // Request storage permission (for older Android versions)
    await Permission.photos.request();

    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return;

      setState(() {
        _statusMessage = 'Processing image...';
      });

      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No face detected in the image')),
          );
        }
        setState(() {
          _statusMessage = 'Ready';
        });
        return;
      }

      if (mounted) {
        _showFaceDetectedDialog(faces.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      setState(() {
        _statusMessage = 'Ready';
      });
    }
  }

  void _showFaceDetectedDialog(Face face) {
    if (_isSearching) return;

    setState(() {
      _isSearching = true;
    });

    // Extract face template and search for patient
    _searchPatientByFace(face);
  }

  /// Extract face template and search for matching patient
  Future<void> _searchPatientByFace(Face face) async {
    try {
      // Extract face template from detected face
      final template = _extractFaceTemplate(face);

      if (template == null) {
        _showFaceDetectionError('Could not extract face features');
        return;
      }

      setState(() {
        _statusMessage = 'Searching for patient...';
      });

      // Search for patient using face template
      final patient = await _patientRepository.getPatientByFaceTemplate(template);

      if (patient != null) {
        if (mounted) {
          _showPatientFoundDialog(patient);
        }
      } else {
        if (mounted) {
          _showNoMatchDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        _showFaceDetectionError('Error searching patient: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isSearching = false;
        _statusMessage = 'Ready';
      });
    }
  }

  /// Extract face template from detected face
  String? _extractFaceTemplate(Face face) {
    try {
      final List<double> template = [];
      final box = face.boundingBox;
      
      template.add(box.width / 500);
      template.add(box.height / 500);
      
      final faceWidth = box.width;
      final faceHeight = box.height;
      final faceCenterX = box.left + faceWidth / 2;
      final faceCenterY = box.top + faceHeight / 2;

      // Add landmark positions
      if (face.landmarks[FaceLandmarkType.leftEye] != null) {
        final leftEye = face.landmarks[FaceLandmarkType.leftEye]!.position;
        template.add((leftEye.x - faceCenterX) / faceWidth);
        template.add((leftEye.y - faceCenterY) / faceHeight);
      } else {
        template.add(0); template.add(0);
      }

      if (face.landmarks[FaceLandmarkType.rightEye] != null) {
        final rightEye = face.landmarks[FaceLandmarkType.rightEye]!.position;
        template.add((rightEye.x - faceCenterX) / faceWidth);
        template.add((rightEye.y - faceCenterY) / faceHeight);
      } else {
        template.add(0); template.add(0);
      }

      if (face.landmarks[FaceLandmarkType.noseBase] != null) {
        final nose = face.landmarks[FaceLandmarkType.noseBase]!.position;
        template.add((nose.x - faceCenterX) / faceWidth);
        template.add((nose.y - faceCenterY) / faceHeight);
      } else {
        template.add(0); template.add(0);
      }

      if (face.landmarks[FaceLandmarkType.leftMouth] != null) {
        final leftMouth = face.landmarks[FaceLandmarkType.leftMouth]!.position;
        template.add((leftMouth.x - faceCenterX) / faceWidth);
        template.add((leftMouth.y - faceCenterY) / faceHeight);
      } else {
        template.add(0); template.add(0);
      }

      if (face.landmarks[FaceLandmarkType.rightMouth] != null) {
        final rightMouth = face.landmarks[FaceLandmarkType.rightMouth]!.position;
        template.add((rightMouth.x - faceCenterX) / faceWidth);
        template.add((rightMouth.y - faceCenterY) / faceHeight);
      } else {
        template.add(0); template.add(0);
      }

      template.add(face.headEulerAngleX ?? 0);
      template.add(face.headEulerAngleY ?? 0);
      template.add(face.headEulerAngleZ ?? 0);

      // Pad to consistent size
      while (template.length < 32) {
        template.add(0);
      }

      return jsonEncode({'embedding': template});
    } catch (e) {
      return null;
    }
  }

  void _showPatientFoundDialog(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Patient Found!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              patient.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('QR Code: ${patient.qrCode}'),
            const SizedBox(height: 4),
            Text('Phone: ${patient.telephone}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNoMatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Match Found'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'No patient found with matching face. Please register the patient or try QR code scan.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFaceDetectionError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    setState(() {
      _statusMessage = 'Ready';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // If camera is active, show camera preview
    if (_isCameraInitialized && _cameraController != null) {
      return Stack(
        children: [
          Center(
            child: camera.CameraPreview(_cameraController!),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.face),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_statusMessage)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _stopCameraScan,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Camera Placeholder
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.face,
                      size: 120,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    Positioned(
                      bottom: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.videocam,
                              size: 16,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _statusMessage,
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Text(
                'Face Recognition',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Position face in the camera frame',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              FilledButton.icon(
                onPressed: _isScanning ? null : _startCameraScan,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Start Scanning'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _selectFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Select from Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QRScanTab extends StatefulWidget {
  @override
  State<_QRScanTab> createState() => _QRScanTabState();
}

class _QRScanTabState extends State<_QRScanTab> {
  bool _isScanning = false;
  MobileScannerController? _scannerController;
  final PatientRepository _patientRepository = sl<PatientRepository>();
  bool _isSearching = false;

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _startQRScan() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
      return;
    }

    setState(() {
      _isScanning = true;
    });

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  Future<void> _stopQRScan() async {
    await _scannerController?.stop();
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _onQRCodeDetected(String code) async {
    if (_isSearching) return;

    setState(() {
      _isSearching = true;
    });

    await _stopQRScan();

    try {
      // Try to find patient by QR code
      final patient = await _patientRepository.getPatientByQrCode(code);

      if (patient != null) {
        if (mounted) {
          _showPatientFoundDialog(patient);
        }
      } else {
        // Try searching by the code (in case it's a patient ID or name)
        final patients = await _patientRepository.searchPatients(code);
        if (patients.isNotEmpty) {
          if (mounted) {
            _showPatientFoundDialog(patients.first);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No patient found with code: $code')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showPatientFoundDialog(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                patient.initials,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(patient.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Code', patient.qrCode),
            _buildInfoRow('Age', '${patient.age}'),
            _buildInfoRow('Gender', patient.gender ?? 'N/A'),
            _buildInfoRow('Phone', patient.telephone),
            _buildInfoRow('Status', patient.status ?? 'Active'),
            if (patient.lastVisit != null)
              _buildInfoRow('Last Visit', _formatDate(patient.lastVisit!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Patient found: ${patient.name}')),
              );
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showManualEntryDialog() async {
    final TextEditingController codeController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Patient Code'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Patient Code',
            hintText: 'Enter QR code or patient ID',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, codeController.text.trim()),
            child: const Text('Search'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _onQRCodeDetected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // If scanner is active, show scanner
    if (_isScanning && _scannerController != null) {
      return Stack(
        children: [
          MobileScanner(
            controller: _scannerController!,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _onQRCodeDetected(barcodes.first.rawValue!);
              }
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_isSearching
                          ? 'Searching...'
                          : 'Point camera at QR code'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _stopQRScan,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR Scanner Placeholder
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 120,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    // Corner decorations
                    Positioned(
                      top: 20,
                      left: 20,
                      child: _buildCorner(colorScheme, false),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: _buildCorner(colorScheme, true),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: _buildCorner(colorScheme, false),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: _buildCorner(colorScheme, true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Text(
                'QR Code Scanner',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Point camera at QR code',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              FilledButton.icon(
                onPressed: _startQRScan,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Start Scanning'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _showManualEntryDialog,
                icon: const Icon(Icons.keyboard),
                label: const Text('Enter Code Manually'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(ColorScheme colorScheme, bool flipped) {
    return Transform.rotate(
      angle: flipped ? 3.14159 : 0,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.primary,
              width: 3,
            ),
            left: BorderSide(
              color: colorScheme.primary,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}
