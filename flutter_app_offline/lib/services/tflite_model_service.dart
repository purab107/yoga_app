import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Service for running TensorFlow Lite model inference on device
class TFLiteModelService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // Yoga pose classes - must match training order
  final List<String> poseClasses = [
    "Anantasana",
    "Ardhakati Chakrasana",
    "Bhujangasana",
    "Kati Chakrasana",
    "Marjariasana",
    "Parvatasana",
    "Sarvangasana",
    "Tadasana",
    "Vajrasana",
    "Viparita Karani"
  ];

  // Model input size
  static const int inputSize = 224;

  /// Load the TFLite model from assets
  Future<void> loadModel() async {
    if (_isModelLoaded) return;

    try {
      // Create interpreter options
      var interpreterOptions = InterpreterOptions();
      
      // Set number of threads for better performance
      interpreterOptions.threads = 4;
      
      // Enable XNNPack delegate for better CPU performance
      try {
        interpreterOptions.addDelegate(XNNPackDelegate());
        print('XNNPack delegate added successfully');
      } catch (e) {
        print('XNNPack delegate not available: $e');
      }
      
      // Load model with TF Select ops support
      _interpreter = await Interpreter.fromAsset(
        'yoga_model_with_flex.tflite',
        options: interpreterOptions,
      );
      
      // Allocate tensors
      _interpreter!.allocateTensors();
      
      // Get input/output details for validation
      var inputTensor = _interpreter!.getInputTensor(0);
      var outputTensor = _interpreter!.getOutputTensor(0);
      
      print('=' * 60);
      print('TFLite model loaded successfully (WITH TF SELECT OPS)');
      print('=' * 60);
      print('Input shape: ${inputTensor.shape}');
      print('Input type: ${inputTensor.type}');
      print('Output shape: ${outputTensor.shape}');
      print('Output type: ${outputTensor.type}');
      print('=' * 60);
      
      _isModelLoaded = true;
    } catch (e) {
      print('Error loading TFLite model: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Preprocess image for model input
  List<List<List<List<double>>>> preprocessImage(img.Image image) {
    // Resize image to 224x224
    img.Image resized = img.copyResize(image, width: inputSize, height: inputSize);

    // Convert to normalized float values [0, 1]
    List<List<List<List<double>>>> input = List.generate(
      1, // batch size
      (b) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0, // Red channel
              pixel.g / 255.0, // Green channel
              pixel.b / 255.0, // Blue channel
            ];
          },
        ),
      ),
    );

    return input;
  }

  /// Run inference on a single image
  Future<Map<String, dynamic>> predictSingleFrame(img.Image image) async {
    if (!_isModelLoaded || _interpreter == null) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    // Preprocess image
    var input = preprocessImage(image);

    // Get actual output shape from model (could be [1, 20] instead of [1, 10])
    var outputShape = _interpreter!.getOutputTensor(0).shape;
    int numClasses = outputShape[1]; // Second dimension is number of classes
    
    // Prepare output buffer with actual model output size
    var output = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);

    // Run inference
    _interpreter!.run(input, output);

    // Get predictions
    List<double> predictions = output[0].cast<double>();

    // Find predicted class (only look at first 10 classes if model outputs 20)
    int predictedIdx = 0;
    double maxConfidence = predictions[0];
    int searchRange = poseClasses.length < numClasses ? poseClasses.length : numClasses;
    
    for (int i = 1; i < searchRange; i++) {
      if (predictions[i] > maxConfidence) {
        maxConfidence = predictions[i];
        predictedIdx = i;
      }
    }

    return {
      'predicted_pose': poseClasses[predictedIdx],
      'confidence': maxConfidence,
      'all_predictions': {
        for (int i = 0; i < poseClasses.length && i < predictions.length; i++)
          poseClasses[i]: predictions[i]
      }
    };
  }

  /// Analyze multiple frames and aggregate results
  Future<Map<String, dynamic>> analyzeFrames(List<img.Image> frames, String expectedPose) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    List<Map<String, dynamic>> frameResults = [];
    Map<String, int> poseCounts = {};
    Map<String, double> poseConfidenceSum = {};

    // Initialize counters
    for (var pose in poseClasses) {
      poseCounts[pose] = 0;
      poseConfidenceSum[pose] = 0.0;
    }

    // Process each frame
    for (int i = 0; i < frames.length; i++) {
      var result = await predictSingleFrame(frames[i]);
      frameResults.add(result);

      String predictedPose = result['predicted_pose'];
      double confidence = result['confidence'];

      poseCounts[predictedPose] = (poseCounts[predictedPose] ?? 0) + 1;
      poseConfidenceSum[predictedPose] = 
          (poseConfidenceSum[predictedPose] ?? 0.0) + confidence;
    }

    // Find most common predicted pose
    String mostCommonPose = poseCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    int mostCommonCount = poseCounts[mostCommonPose] ?? 0;
    double avgConfidence = mostCommonCount > 0
        ? (poseConfidenceSum[mostCommonPose] ?? 0.0) / mostCommonCount
        : 0.0;

    // Check if prediction matches expected pose
    bool isCorrect = mostCommonPose.toLowerCase() == expectedPose.toLowerCase();
    double accuracy = (mostCommonCount / frames.length) * 100;

    // Generate feedback message
    String feedback = _generateFeedback(
      expectedPose,
      mostCommonPose,
      isCorrect,
      accuracy,
      avgConfidence,
    );

    return {
      'expected_pose': expectedPose,
      'predicted_pose': mostCommonPose,
      'confidence': avgConfidence,
      'is_correct': isCorrect,
      'accuracy': accuracy,
      'total_frames': frames.length,
      'pose_counts': poseCounts,
      'feedback': feedback,
      'frame_results': frameResults,
    };
  }

  /// Generate feedback message based on analysis
  String _generateFeedback(
    String expectedPose,
    String predictedPose,
    bool isCorrect,
    double accuracy,
    double confidence,
  ) {
    if (isCorrect && confidence > 0.8) {
      return '✅ Excellent! Your $expectedPose pose is correct with ${confidence.toStringAsFixed(1)}% confidence. Keep up the great work!';
    } else if (isCorrect && confidence > 0.6) {
      return '✅ Good job! Your $expectedPose pose is correct, but could be more precise. Try to hold the pose more steadily.';
    } else if (isCorrect) {
      return '⚠️ Your $expectedPose pose is detected but needs improvement. Focus on proper alignment and form.';
    } else {
      return '❌ Your pose looks more like $predictedPose than $expectedPose. Please review the correct form and try again.';
    }
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}
