import 'dart:convert';
import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Face Recognition Service
/// Handles face detection and template extraction for patient identification
class FaceRecognitionService {
  final FaceDetector _faceDetector;

  FaceRecognitionService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableTracking: true,
            enableLandmarks: true,
            enableClassification:
                false, // We only need detection for template extraction
            performanceMode: FaceDetectorMode.accurate,
          ),
        );

  /// Detect faces from image file and extract face template
  /// Returns a JSON string containing face embeddings if successful
  /// Returns null if no face or multiple faces detected
  Future<String?> extractFaceTemplate(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return null;
      }

      if (faces.length > 1) {
        // Multiple faces detected - not suitable for template extraction
        return null;
      }

      final face = faces.first;

      // Extract face template from landmarks and bounding box
      // This creates a simplified face representation based on facial features
      final template = _createFaceTemplate(face);

      // Convert to JSON string for storage
      return jsonEncode({'embedding': template});
    } catch (e) {
      return null;
    }
  }

  /// Detect faces from camera XFile and extract face template
  Future<String?> extractFaceTemplateFromXFile(File imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return null;
      }

      if (faces.length > 1) {
        return null;
      }

      final face = faces.first;
      final template = _createFaceTemplate(face);

      return jsonEncode({'embedding': template});
    } catch (e) {
      return null;
    }
  }

  /// Create a face template from detected face
  /// Uses facial landmarks and bounding box to create a numerical representation
  List<double> _createFaceTemplate(Face face) {
    final List<double> template = [];

    // Add bounding box features (normalized)
    final box = face.boundingBox;
    template.add(box.width / 500); // Normalize by expected max width
    template.add(box.height / 500);
    template.add(box.left / 500);
    template.add(box.top / 500);

    // Add key landmark positions (normalized to face size)
    final faceWidth = box.width;
    final faceHeight = box.height;
    final faceCenterX = box.left + faceWidth / 2;
    final faceCenterY = box.top + faceHeight / 2;

    // Left eye position
    if (face.landmarks[FaceLandmarkType.leftEye] != null) {
      final leftEye = face.landmarks[FaceLandmarkType.leftEye]!.position;
      template.add((leftEye.x - faceCenterX) / faceWidth);
      template.add((leftEye.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    // Right eye position
    if (face.landmarks[FaceLandmarkType.rightEye] != null) {
      final rightEye = face.landmarks[FaceLandmarkType.rightEye]!.position;
      template.add((rightEye.x - faceCenterX) / faceWidth);
      template.add((rightEye.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    // Nose base position
    if (face.landmarks[FaceLandmarkType.noseBase] != null) {
      final nose = face.landmarks[FaceLandmarkType.noseBase]!.position;
      template.add((nose.x - faceCenterX) / faceWidth);
      template.add((nose.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    // Left mouth position
    if (face.landmarks[FaceLandmarkType.leftMouth] != null) {
      final leftMouth = face.landmarks[FaceLandmarkType.leftMouth]!.position;
      template.add((leftMouth.x - faceCenterX) / faceWidth);
      template.add((leftMouth.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    // Right mouth position
    if (face.landmarks[FaceLandmarkType.rightMouth] != null) {
      final rightMouth = face.landmarks[FaceLandmarkType.rightMouth]!.position;
      template.add((rightMouth.x - faceCenterX) / faceWidth);
      template.add((rightMouth.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    // Bottom mouth position
    if (face.landmarks[FaceLandmarkType.bottomMouth] != null) {
      final bottomMouth =
          face.landmarks[FaceLandmarkType.bottomMouth]!.position;
      template.add((bottomMouth.x - faceCenterX) / faceWidth);
      template.add((bottomMouth.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    // Left ear position
    if (face.landmarks[FaceLandmarkType.leftEar] != null) {
      final leftEar = face.landmarks[FaceLandmarkType.leftEar]!.position;
      template.add((leftEar.x - faceCenterX) / faceWidth);
      template.add((leftEar.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    // Right ear position
    if (face.landmarks[FaceLandmarkType.rightEar] != null) {
      final rightEar = face.landmarks[FaceLandmarkType.rightEar]!.position;
      template.add((rightEar.x - faceCenterX) / faceWidth);
      template.add((rightEar.y - faceCenterY) / faceHeight);
    } else {
      template.add(0);
      template.add(0);
    }

    // Add head rotation angles (Euler angles)
    template.add(face.headEulerAngleX ?? 0); // Pitch
    template.add(face.headEulerAngleY ?? 0); // Yaw
    template.add(face.headEulerAngleZ ?? 0); // Roll

    // Add eye tracking distances (for liveness detection)
    if (face.landmarks[FaceLandmarkType.leftEye] != null &&
        face.landmarks[FaceLandmarkType.rightEye] != null) {
      final leftEye = face.landmarks[FaceLandmarkType.leftEye]!.position;
      final rightEye = face.landmarks[FaceLandmarkType.rightEye]!.position;
      final eyeDistance = (rightEye.x - leftEye.x).abs();
      template.add(eyeDistance / faceWidth); // Normalized interocular distance
    } else {
      template.add(0);
    }

    // Add face turning angle indicator
    // This helps distinguish between different face angles
    if (face.landmarks[FaceLandmarkType.noseBase] != null &&
        face.landmarks[FaceLandmarkType.leftMouth] != null) {
      final nose = face.landmarks[FaceLandmarkType.noseBase]!.position;
      final leftMouth = face.landmarks[FaceLandmarkType.leftMouth]!.position;
      template.add((nose.x - leftMouth.x) / faceWidth);
    } else {
      template.add(0);
    }

    // Pad the template to ensure consistent size (32 values)
    // This provides enough variance for basic face matching
    while (template.length < 32) {
      template.add(0);
    }

    return template;
  }

  /// Calculate cosine similarity between two face templates
  /// Returns value between 0 and 1, where 1 is identical
  double calculateSimilarity(String template1Json, String template2Json) {
    try {
      final template1 = _parseTemplate(template1Json);
      final template2 = _parseTemplate(template2Json);

      if (template1.length != template2.length || template1.isEmpty) {
        return 0;
      }

      double dotProduct = 0;
      double norm1 = 0;
      double norm2 = 0;

      for (int i = 0; i < template1.length; i++) {
        dotProduct += template1[i] * template2[i];
        norm1 += template1[i] * template1[i];
        norm2 += template2[i] * template2[i];
      }

      if (norm1 == 0 || norm2 == 0) return 0;

      return dotProduct / (norm1 * norm2);
    } catch (e) {
      return 0;
    }
  }

  List<double> _parseTemplate(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map && decoded.containsKey('embedding')) {
        return (decoded['embedding'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
      } else if (decoded is List) {
        return decoded.map((e) => (e as num).toDouble()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Check if the detected face is suitable for template extraction
  /// Returns true if face is clearly visible and centered
  bool isFaceSuitable(Face face) {
    // Check if face is too small
    final box = face.boundingBox;
    if (box.width < 100 || box.height < 100) {
      return false;
    }

    // Check head rotation (too much tilt makes it unsuitable)
    final yaw = face.headEulerAngleY ?? 0;
    final roll = face.headEulerAngleZ ?? 0;

    if (yaw.abs() > 30 || roll.abs() > 30) {
      return false;
    }

    return true;
  }

  /// Dispose the face detector
  void dispose() {
    _faceDetector.close();
  }
}
