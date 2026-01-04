# 🧘 Yoga Pose Analyzer

A comprehensive AI-powered yoga pose analysis application with web, desktop, and mobile support. Analyzes yoga poses from uploaded videos or live webcam feeds using TensorFlow deep learning models and provides real-time feedback on form correctness.

## ✨ Features

- 📹 **Video Upload Analysis** - Upload videos to analyze your yoga poses frame by frame
- 📷 **Live Webcam Analysis** - Real-time pose checking using your webcam
- 📱 **Cross-Platform Support** - Web app, Flutter desktop app, and Flutter mobile app
- 🤖 **AI-Powered** - Uses TensorFlow/TFLite models for accurate pose detection
- 📊 **Detailed Feedback** - Frame-by-frame analysis with confidence scores
- 🎯 **Accuracy Metrics** - Overall performance statistics and improvement tracking
- 💡 **Improvement Suggestions** - Actionable feedback for better form
- 🎨 **Modern UI** - Clean, responsive interface across all platforms

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- Node.js (for web frontend)
- Flutter SDK (for mobile/desktop app)
- TensorFlow model files

### Running the Web Application

1. **Start Backend Server:**
   ```bash
   cd backend
   python -m venv venv
   venv\Scripts\activate  # Windows
   # source venv/bin/activate  # Mac/Linux
   pip install -r requirements.txt
   uvicorn main:app --reload
   ```

2. **Start Frontend Server:**
   ```bash
   cd frontend
   python -m http.server 8080
   ```

3. **Access Application:**
   Open browser at `http://localhost:8080`

### Running the Flutter App

**Desktop:**
```bash
cd flutter_app
flutter run -d windows  # or macos/linux
```

**Mobile (Android):**
```bash
cd flutter_app
flutter run
# Or build APK: flutter build apk
```

## 📁 Project Structure

```
yoga_app/
├── backend/                    # Python FastAPI backend
│   ├── main.py                # REST API endpoints
│   ├── model_handler.py       # TensorFlow model inference
│   ├── video_processor.py     # Video frame extraction
│   └── requirements.txt       # Python dependencies
├── frontend/                   # Web application
│   ├── index.html             # Main UI
│   ├── app.js                 # Frontend logic
│   └── styles.css             # Styling
├── flutter_app/               # Flutter mobile/desktop app
│   ├── lib/
│   │   ├── main.dart          # App entry point
│   │   └── screens/           # UI screens
│   ├── android/               # Android configuration
│   └── pubspec.yaml           # Flutter dependencies
├── model_prep/                # ML model files
│   ├── yoga_savedmodel/       # TensorFlow SavedModel
│   └── yoga_model_fp16.tflite # TFLite model for mobile
└── README.md                  # This file
```

## 🛠️ Technology Stack

**Backend:**
- FastAPI - Modern Python web framework
- TensorFlow 2.15 - Deep learning model
- OpenCV - Video processing
- Uvicorn - ASGI server

**Frontend (Web):**
- HTML5/CSS3/JavaScript
- Fetch API for backend communication
- Responsive design

**Mobile/Desktop:**
- Flutter - Cross-platform framework
- Dart programming language
- TFLite - On-device ML inference
- Video Player plugin

## 📖 Usage

1. **Select Asana**: Choose the yoga pose you want to analyze from the dropdown
2. **Upload/Record**: Either upload a video file or use your webcam for live analysis
3. **Analyze**: Click the analyze button to process your pose
4. **Review Results**: View accuracy scores, confidence levels, and frame-by-frame feedback
5. **Improve**: Follow the suggestions provided to improve your form

## 🎯 Supported Yoga Poses

The application currently supports analysis for various yoga asanas including:
- Tadasana (Mountain Pose)
- Vrikshasana (Tree Pose)
- Trikonasana (Triangle Pose)
- And more...

## 📋 Requirements

**Backend:**
- Python 3.8+
- TensorFlow 2.15
- FastAPI 0.109
- OpenCV 4.9
- NumPy 1.26

**Flutter App:**
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android SDK (for mobile)
- Compatible IDE (VS Code/Android Studio)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License.

## 🔗 Links

- [Detailed Setup Instructions](HOW_TO_RUN.txt)
- [Run Instructions](RUN_INSTRUCTIONS.txt)

## 📞 Support

For issues and questions, please open an issue in the GitHub repository.

---

**Note**: Make sure to have the TensorFlow model files in the `model_prep` directory before running the application.
   pip install -r requirements.txt
   ```

5. **Start the backend server:**
   ```bash
   python main.py
   ```
   
   Backend will run at: `http://localhost:8000`

### Frontend Setup

1. **Open frontend in browser:**
   - Simply open `frontend/index.html` in your browser
   - Or use a local server (recommended):
     ```bash
     cd frontend
     python -m http.server 8080
     ```
   - Then open: `http://localhost:8080`

## Usage

### Video Analysis

1. Click on "Upload Video" tab
2. Choose a video file or drag & drop
3. Click "Analyze Pose" button
4. Wait for processing
5. Review results with frame-by-frame feedback

### Webcam Analysis

1. Click on "Live Webcam" tab
2. Click "Start Webcam" to enable camera
3. Position yourself in frame
4. Click "Capture & Analyze" to analyze current pose
5. Review instant feedback

## API Endpoints

### `GET /`
Health check endpoint

### `POST /analyze-pose`
Analyze yoga pose from video
- **Input:** Video file (multipart/form-data)
- **Output:** JSON with analysis results

### `POST /analyze-webcam-frame`
Analyze single frame from webcam
- **Input:** Image file (multipart/form-data)
- **Output:** JSON with pose prediction

## Model Information

- **Architecture:** EfficientNet-based CNN
- **Format:** TensorFlow SavedModel
- **Input:** 224x224 RGB images
- **Output:** Pose classification with confidence scores

## Customization

### Adding More Pose Classes

Edit `model_handler.py` and update the `pose_classes` list:

```python
self.pose_classes = [
    "Your Pose 1",
    "Your Pose 2",
    # Add more poses...
]
```

### Adjusting Confidence Threshold

Edit `model_handler.py`:

```python
is_correct = confidence > 0.75  # Adjust threshold (0.0 - 1.0)
```

### Changing Frame Sample Rate

Edit `main.py`:

```python
frames = video_processor.extract_frames(str(video_path), sample_rate=10)  # Every 10th frame
```

## Troubleshooting

### CORS Errors
If you encounter CORS issues, ensure the backend is running and the API_URL in `frontend/app.js` matches your backend URL.

### Model Loading Issues
Verify that the model path in `main.py` correctly points to your SavedModel directory:
```python
SAVED_MODEL_PATH = "../model_prep/yoga_savedmodel"
```

### Webcam Not Working
- Ensure browser has camera permissions
- Use HTTPS or localhost (required by browsers for camera access)

## Future Enhancements

- [ ] Real-time video streaming analysis
- [ ] Multiple pose comparison
- [ ] Progress tracking over time
- [ ] Export analysis reports
- [ ] Mobile app version

## Technologies Used

- **Backend:** FastAPI, TensorFlow, OpenCV, Python
- **Frontend:** HTML5, CSS3, JavaScript
- **ML:** TensorFlow SavedModel with EfficientNet

## License

MIT License - Feel free to use and modify for your projects!
