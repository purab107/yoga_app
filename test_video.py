"""
Test script to analyze yoga video directly from terminal
"""
import sys
sys.path.append('d:/yoga_app/backend')

from model_handler import YogaModelHandler
from video_processor import VideoProcessor
import json

# Configuration
VIDEO_PATH = "D:/yoga_app/test-video.mp4"
MODEL_PATH = "D:/yoga_app/model_prep/yoga_savedmodel"
SAMPLE_RATE = 10  # Extract every 10th frame

print("=" * 60)
print("🧘 YOGA POSE ANALYSIS - TEST SCRIPT")
print("=" * 60)

# Initialize components
print("\n1️⃣ Initializing components...")
model_handler = YogaModelHandler(MODEL_PATH)
video_processor = VideoProcessor()

# Load model
print("\n2️⃣ Loading TensorFlow model...")
try:
    model_handler.load_model()
    print("✅ Model loaded successfully!")
except Exception as e:
    print(f"❌ Failed to load model: {e}")
    sys.exit(1)

# Extract frames from video
print(f"\n3️⃣ Extracting frames from video: {VIDEO_PATH}")
try:
    frames = video_processor.extract_frames(VIDEO_PATH, sample_rate=SAMPLE_RATE)
    print(f"✅ Extracted {len(frames)} frames")
except Exception as e:
    print(f"❌ Failed to extract frames: {e}")
    sys.exit(1)

# Analyze each frame
print(f"\n4️⃣ Analyzing {len(frames)} frames...")
results = []
for idx, frame in enumerate(frames):
    print(f"   Analyzing frame {idx + 1}/{len(frames)}...", end="\r")
    prediction = model_handler.predict(frame)
    results.append({
        "frame_number": idx,
        "pose_detected": prediction["pose_class"],
        "confidence": prediction["confidence"],
        "is_correct": prediction["is_correct"],
        "feedback": prediction["feedback"]
    })

print(f"\n✅ Analysis complete!")

# Calculate statistics
correct_count = sum(1 for r in results if r["is_correct"])
avg_confidence = sum(r["confidence"] for r in results) / len(results)
accuracy_percentage = (correct_count / len(results)) * 100

# Display results
print("\n" + "=" * 60)
print("📊 ANALYSIS RESULTS")
print("=" * 60)
print(f"\n📹 Video: {VIDEO_PATH.split('/')[-1]}")
print(f"🎞️  Total frames analyzed: {len(frames)}")
print(f"✅ Correct frames: {correct_count}")
print(f"❌ Incorrect frames: {len(frames) - correct_count}")
print(f"📈 Accuracy: {accuracy_percentage:.2f}%")
print(f"🎯 Average confidence: {avg_confidence:.2f}")

# Overall feedback
if accuracy_percentage >= 90:
    overall_feedback = "Excellent! Your form is nearly perfect. Keep it up!"
elif accuracy_percentage >= 70:
    overall_feedback = "Good job! Minor adjustments needed in some frames."
elif accuracy_percentage >= 50:
    overall_feedback = "Decent attempt. Focus on maintaining proper form throughout."
else:
    overall_feedback = "Needs improvement. Review the pose guidelines and try again."

print(f"\n💡 Feedback: {overall_feedback}")

# Frame-by-frame details
print("\n" + "=" * 60)
print("🎬 FRAME-BY-FRAME ANALYSIS")
print("=" * 60)

for result in results[:10]:  # Show first 10 frames
    status = "✅" if result["is_correct"] else "❌"
    print(f"\n{status} Frame {result['frame_number'] + 1}:")
    print(f"   Pose: {result['pose_detected']}")
    print(f"   Confidence: {result['confidence']:.2%}")
    print(f"   Feedback: {result['feedback']}")

if len(results) > 10:
    print(f"\n... and {len(results) - 10} more frames")

# Save results to JSON
output_file = "D:/yoga_app/test_results.json"
with open(output_file, 'w') as f:
    json.dump({
        "video_name": VIDEO_PATH.split('/')[-1],
        "total_frames_analyzed": len(frames),
        "correct_frames": correct_count,
        "incorrect_frames": len(frames) - correct_count,
        "accuracy_percentage": accuracy_percentage,
        "average_confidence": avg_confidence,
        "overall_feedback": overall_feedback,
        "frame_results": results
    }, f, indent=2)

print(f"\n💾 Full results saved to: {output_file}")
print("\n" + "=" * 60)
print("✅ ANALYSIS COMPLETE!")
print("=" * 60)
