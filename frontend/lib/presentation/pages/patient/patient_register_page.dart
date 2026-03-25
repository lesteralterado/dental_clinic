import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart' as camera;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/models/patient_model.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../di/injection_container.dart';

class PatientRegisterPage extends StatefulWidget {
  const PatientRegisterPage({super.key});

  @override
  State<PatientRegisterPage> createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _complaintController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _allergiesController = TextEditingController();
  String? _selectedStatus;
  String? _selectedGender;
  bool _isLoading = false;

  // Face capture state
  bool _isCapturingFace = false;
  String? _capturedFacePath;
  String? _faceTemplate;
  camera.CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableTracking: true,
      enableLandmarks: true,
      enableClassification: false,
    ),
  );

  // Registered patient for QR display
  PatientModel? _registeredPatient;
  bool _showQrDialog = false;

  final PatientRepository _patientRepo = sl<PatientRepository>();

  final List<String> _statusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed'
  ];
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _complaintController.dispose();
    _emailController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _medicalNotesController.dispose();
    _allergiesController.dispose();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  /// Start camera for face capture
  Future<void> _startFaceCapture() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Camera permission is required for face capture')),
        );
      }
      return;
    }

    setState(() {
      _isCapturingFace = true;
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
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _isCapturingFace = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  /// Capture face photo
  Future<void> _captureFacePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'No face detected. Please position your face in the camera.')),
          );
        }
        return;
      }

      if (faces.length > 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Multiple faces detected. Please capture only one face.')),
          );
        }
        return;
      }

      // Face detected - extract template
      final face = faces.first;
      final template = _extractFaceTemplate(face);

      setState(() {
        _capturedFacePath = imageFile.path;
        _faceTemplate = template;
        _isCapturingFace = false;
      });

      await _cameraController?.dispose();
      _cameraController = null;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Face captured successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing face: ${e.toString()}')),
        );
      }
    }
  }

  /// Extract face template from detected face
  String _extractFaceTemplate(Face face) {
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
      template.add(0);
      template.add(0);
    }

    if (face.landmarks[FaceLandmarkType.rightEye] != null) {
      final rightEye = face.landmarks[FaceLandmarkType.rightEye]!.position;
      template.add((rightEye.x - faceCenterX) / faceWidth);
      template.add((rightEye.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    if (face.landmarks[FaceLandmarkType.noseBase] != null) {
      final nose = face.landmarks[FaceLandmarkType.noseBase]!.position;
      template.add((nose.x - faceCenterX) / faceWidth);
      template.add((nose.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    if (face.landmarks[FaceLandmarkType.leftMouth] != null) {
      final leftMouth = face.landmarks[FaceLandmarkType.leftMouth]!.position;
      template.add((leftMouth.x - faceCenterX) / faceWidth);
      template.add((leftMouth.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    if (face.landmarks[FaceLandmarkType.rightMouth] != null) {
      final rightMouth = face.landmarks[FaceLandmarkType.rightMouth]!.position;
      template.add((rightMouth.x - faceCenterX) / faceWidth);
      template.add((rightMouth.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    template.add(face.headEulerAngleX ?? 0);
    template.add(face.headEulerAngleY ?? 0);
    template.add(face.headEulerAngleZ ?? 0);

    // Pad to consistent size
    while (template.length < 32) {
      template.add(0);
    }

    return '{"embedding":${template.toString()}}';
  }

  /// Cancel face capture
  Future<void> _cancelFaceCapture() async {
    await _cameraController?.dispose();
    _cameraController = null;
    setState(() {
      _isCapturingFace = false;
    });
  }

  /// Clear captured face
  void _clearCapturedFace() {
    setState(() {
      _capturedFacePath = null;
      _faceTemplate = null;
    });
  }

  /// Show QR code dialog after successful registration
  void _showQrCodeDialog(PatientModel patient) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Patient has been registered. Here is their QR Code:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: QrImageView(
                data: patient.qrCode,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'QR Code: ${patient.qrCode}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (patient.email != null && patient.email!.isNotEmpty)
              FilledButton.icon(
                onPressed: () => _sendQrCodeEmail(patient),
                icon: const Icon(Icons.email),
                label: const Text('Send QR via Email'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(this.context).pop(true);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  /// Send QR code via email
  Future<void> _sendQrCodeEmail(PatientModel patient) async {
    if (patient.email == null || patient.email!.isEmpty) {
      return;
    }

    try {
      final success = await _patientRepo.sendQrCodeViaEmail(
        patient.id,
        patient.email!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'QR Code sent to ${patient.email}'
                : 'Failed to send QR Code'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Show QR code dialog after successful registration
      try {
        final patient = await _patientRepo.createPatient(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          telephone: _phoneController.text.trim(),
          age: int.tryParse(_ageController.text.trim()) ?? 0,
          occupation: _occupationController.text.trim().isEmpty
              ? null
              : _occupationController.text.trim(),
          status: _selectedStatus,
          complaint: _complaintController.text.trim().isEmpty
              ? null
              : _complaintController.text.trim(),
          gender: _selectedGender,
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          emergencyContact: _emergencyContactController.text.trim().isEmpty
              ? null
              : _emergencyContactController.text.trim(),
          emergencyPhone: _emergencyPhoneController.text.trim().isEmpty
              ? null
              : _emergencyPhoneController.text.trim(),
          medicalNotes: _medicalNotesController.text.trim().isEmpty
              ? null
              : _medicalNotesController.text.trim(),
          allergies: _allergiesController.text.trim().isEmpty
              ? null
              : _allergiesController.text.trim(),
          faceTemplate: _faceTemplate,
        );

        // Show QR code dialog after successful registration
        if (mounted) {
          _showQrCodeDialog(patient);
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = e.toString();

          // Check if it's a session-related error
          if (errorMessage.toLowerCase().contains('session') ||
              errorMessage.toLowerCase().contains('login') ||
              errorMessage.toLowerCase().contains('jwt') ||
              errorMessage.toLowerCase().contains('cryptography') ||
              errorMessage.toLowerCase().contains('expired')) {
            errorMessage = 'Session expired. Please login again.';

            // Show dialog to re-login
            _showReLoginDialog();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showReLoginDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text(
            'Your session has expired. Please login again to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushNamed('/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Patient'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Personal Information Section
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Full Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Full name is required' : null,
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Phone number is required' : null,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                helperText: 'Required for sending QR code via email',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Age and Gender Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age *',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.wc_outlined),
                    ),
                    items: _genderOptions
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Occupation
            TextFormField(
              controller: _occupationController,
              decoration: const InputDecoration(
                labelText: 'Occupation',
                prefixIcon: Icon(Icons.work_outline),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Marital Status
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Marital Status',
                prefixIcon: Icon(Icons.favorite_outline),
              ),
              items: _statusOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedStatus = v),
            ),
            const SizedBox(height: 24),

            // Complaint Section
            Text(
              'Complaint',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _complaintController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Initial Complaint',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.medical_services_outlined),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Face Capture Section
            Text(
              'Face Recognition (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            if (_capturedFacePath != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Face captured successfully!',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearCapturedFace,
                      child: const Text('Retake'),
                    ),
                  ],
                ),
              ),
            ] else if (_isCapturingFace && _cameraController != null) ...[
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: camera.CameraPreview(_cameraController!),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: _captureFacePhoto,
                            icon: const Icon(Icons.camera),
                            label: const Text('Capture'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: _cancelFaceCapture,
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.face,
                      size: 48,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Capture face for quick check-in',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _startFaceCapture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Capture Face'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Register Button
            FilledButton.icon(
              onPressed: _savePatient,
              icon: const Icon(Icons.person_add),
              label: const Text('Register Patient'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
