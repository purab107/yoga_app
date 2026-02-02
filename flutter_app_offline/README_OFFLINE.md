# Yoga App - Offline Version with TensorFlow Lite

## 🎯 What's Changed

This is the **offline-capable version** of the Yoga App that runs TensorFlow Lite models **on-device** without requiring a backend API.

### Key Differences from Original App:

| Feature | Original App | Offline App |
|---------|-------------|-------------|
| **Model Location** | Backend server (TensorFlow) | On-device (TFLite) |
| **Model Size** | ~270MB | ~3MB |
| **Internet Required** | ✅ Yes | ❌ No |
| **Processing** | Server-side | On-device |
| **Speed** | Network dependent | Fast, local |
| **Privacy** | Video uploaded | Video stays on device |

---

## 📦 Installation Steps

### 1. Get Dependencies

Run from the `flutter_app_offline` directory:

```bash
flutter pub get
```

This will install:
- `tflite_flutter` - TensorFlow Lite runtime for Flutter
- `image` - Image processing library
- `path_provider` - Temporary file storage
- `ffmpeg_kit_flutter` - Video frame extraction

### 2. Verify Model Asset

Ensure the TFLite model is in place:
```
flutter_app_offline/
  assets/
    yoga_model_fp16.tflite  ← Should exist (already copied)
```

### 3. Run the App

#### Android:
```bash
flutter run -d <device-id>
```

#### iOS:
```bash
flutter run -d <device-id>
```

#### Build APK:
```bash
flutter build apk --release
```

---

## 🔧 How It Works

### Architecture Flow:

```
1. User uploads video
   ↓
2. Video saved to temp storage
   ↓
3. FFmpeg extracts frames (every 10th frame)
   ↓
4. Each frame preprocessed (224x224, normalized)
   ↓
5. TFLite model predicts pose for each frame
   ↓
6. Results aggregated and feedback generated
   ↓
7. Results displayed to user
```

### Key Components:

**1. TFLiteModelService** (`lib/services/tflite_model_service.dart`)
- Loads TFLite model from assets
- Preprocesses images (resize, normalize)
- Runs inference on frames
- Aggregates results and generates feedback

**2. VideoFrameExtractor** (`lib/services/video_frame_extractor.dart`)
- Uses FFmpeg to extract frames from video
- Samples frames at specified rate (default: every 10th frame)
- Returns list of decoded images

**3. ProcessingScreen** (`lib/screens/processing_screen.dart`)
- **Modified**: Now uses local TFLite instead of API calls
- Shows progress updates during processing
- Handles errors gracefully

---

## 🎨 Supported Yoga Poses

The model recognizes these 10 asanas:

1. **Anantasana** - Side Reclining Leg Lift
2. **Ardhakati Chakrasana** - Standing Side Bend
3. **Bhujangasana** - Cobra Pose
4. **Kati Chakrasana** - Standing Spinal Twist
5. **Marjariasana** - Cat Pose
6. **Parvatasana** - Mountain Pose
7. **Sarvangasana** - Shoulder Stand
8. **Tadasana** - Palm Tree Pose
9. **Vajrasana** - Thunderbolt Pose
10. **Viparita Karani** - Legs Up the Wall

---

## 🚀 Performance

### Expected Performance:
- **Model Load Time**: ~1-2 seconds (first time only)
- **Frame Extraction**: ~2-5 seconds (depends on video length)
- **Inference**: ~50-100ms per frame
- **Total Processing**: ~5-15 seconds for typical video

### Optimization Tips:
- Shorter videos = faster processing
- Model stays loaded after first use (faster subsequent analyses)
- GPU delegate available on supported devices (auto-enabled if available)

---

## 🆚 Comparison: Online vs Offline

### Online (Original) App:
✅ No app size increase  
✅ Centralized model updates  
❌ Requires internet connection  
❌ Slower (network latency)  
❌ Privacy concerns (video upload)  

### Offline (This Version):
✅ Works without internet  
✅ Faster processing (no network)  
✅ Better privacy (data stays local)  
✅ Consistent performance  
❌ Larger app size (+3MB)  
❌ Model updates require app update  

---

## 🛠️ Troubleshooting

### Issue: "Failed to load TFLite model"
**Solution**: Ensure `assets/yoga_model_fp16.tflite` exists and is declared in `pubspec.yaml`

### Issue: "FFmpeg extraction failed"
**Solution**: FFmpeg is bundled with `ffmpeg_kit_flutter`. If it fails, check video format (MP4 recommended)

### Issue: Slow performance on Android
**Solution**: Enable GPU acceleration (automatically attempted, requires Android 8.1+)

### Issue: Out of memory error
**Solution**: Process fewer frames or reduce sample rate in `video_frame_extractor.dart`

---

## 📝 Future Enhancements

Planned features for next phases:

1. **MediaPipe Integration** - Add skeletal keypoint detection for enhanced feedback
2. **Real-time Analysis** - Live camera feed processing
3. **Pose Comparison** - Side-by-side comparison with reference poses
4. **Progress Tracking** - Historical data and improvement metrics
5. **Offline-first Sync** - Optional cloud backup when online

---

## 🔗 Related Files

- Original Online App: `../flutter_app/`
- TFLite Model Source: `../model_prep/yoga_model_fp16.tflite`
- Backend API (for reference): `../backend/main.py`

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Full Support | Recommended: Android 8.1+ for GPU |
| iOS | ✅ Full Support | Requires iOS 12+ |
| Web | ⚠️ Limited | TFLite works, FFmpeg may have issues |
| Desktop | ⚠️ Experimental | Windows/Linux/Mac with limitations |

---

## 🤝 Contributing

This offline version maintains the same UI/UX as the original app. If you modify the model or add features:

1. Update model asset if changed
2. Update `poseClasses` list in `tflite_model_service.dart` if classes change
3. Test thoroughly on real devices (not just emulator)

---

## 📄 License

Same license as the main Yoga App project.

---

**Built with ❤️ for offline-first mobile experiences**
