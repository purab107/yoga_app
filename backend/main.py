from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import shutil
import os
from pathlib import Path
import logging
import base64
import cv2

from model_handler import YogaModelHandler
from video_processor import VideoProcessor

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Yoga Pose Correction API")

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize video processor
video_processor = VideoProcessor()

# Model will be loaded lazily
# Use relative path that works both locally and on Azure
SAVED_MODEL_PATH = os.path.join(os.path.dirname(__file__), "..", "model_prep", "yoga_savedmodel")
model_handler = None

# Create temp directory for uploads
UPLOAD_DIR = Path("temp_uploads")
UPLOAD_DIR.mkdir(exist_ok=True)


@app.on_event("startup")
async def startup_event():
    """Initialize on startup"""
    global model_handler
    logger.info("Server starting up...")
    model_handler = YogaModelHandler(SAVED_MODEL_PATH)
    logger.info("Model handler initialized (model will load on first request)")


@app.get("/")
async def root():
    """Health check endpoint"""
    return {"status": "ok", "message": "Yoga Pose Correction API is running"}


@app.post("/analyze-pose")
async def analyze_pose(
    video: UploadFile = File(...),
    expected_pose: str = Form(None)
):
    """
    Analyze yoga pose from uploaded video
    
    Args:
        video: Video file (mp4, avi, mov)
        expected_pose: The expected yoga asana name
        
    Returns:
        JSON with pose analysis results
    """
    global model_handler
    
    try:
        # Load model on first request if not loaded
        if model_handler.model is None:
            logger.info("Loading TensorFlow model on first request...")
            model_handler.load_model()
            logger.info("Model loaded successfully!")
        
        # Validate file type (check content type or file extension)
        valid_video_extensions = ['.mp4', '.avi', '.mov', '.mkv', '.webm']
        is_video_content = video.content_type and video.content_type.startswith('video/')
        is_video_extension = any(video.filename.lower().endswith(ext) for ext in valid_video_extensions)
        
        if not is_video_content and not is_video_extension:
            logger.error(f"Invalid file type: {video.content_type}, filename: {video.filename}")
            raise HTTPException(400, "File must be a video (mp4, avi, mov, mkv, or webm)")
        
        # Save uploaded video temporarily
        video_path = UPLOAD_DIR / f"temp_{video.filename}"
        with open(video_path, "wb") as buffer:
            shutil.copyfileobj(video.file, buffer)
        
        logger.info(f"Processing video: {video.filename}")
        
        # Extract frames from video
        frames = video_processor.extract_frames(str(video_path), sample_rate=10)
        logger.info(f"Extracted {len(frames)} frames")
        
        # Analyze each frame
        results = []
        for idx, frame in enumerate(frames):
            prediction = model_handler.predict(frame)
            
            # Convert frame to base64 for frontend display
            _, buffer = cv2.imencode('.jpg', frame)
            frame_base64 = base64.b64encode(buffer).decode('utf-8')
            
            results.append({
                "frame_number": idx,
                "pose_detected": prediction["pose_class"],
                "confidence": prediction["confidence"],
                "is_correct": prediction["is_correct"],
                "feedback": prediction["feedback"],
                "image": f"data:image/jpeg;base64,{frame_base64}"
            })
        
        # Calculate overall statistics
        if expected_pose:
            # Check if detected pose matches expected pose
            correct_count = sum(1 for r in results 
                              if r["pose_detected"] == expected_pose and r["confidence"] > 0.7)
        else:
            correct_count = sum(1 for r in results if r["is_correct"])
        
        avg_confidence = sum(r["confidence"] for r in results) / len(results)
        
        overall_result = {
            "video_name": video.filename,
            "expected_pose": expected_pose,
            "total_frames_analyzed": len(frames),
            "correct_frames": correct_count,
            "incorrect_frames": len(frames) - correct_count,
            "accuracy_percentage": round((correct_count / len(frames)) * 100, 2),
            "average_confidence": round(avg_confidence, 2),
            "frame_results": results,
            "overall_feedback": _generate_overall_feedback(results, expected_pose)
        }
        
        # Cleanup
        os.remove(video_path)
        
        return JSONResponse(content=overall_result)
        
    except Exception as e:
        logger.error(f"Error processing video: {str(e)}")
        # Cleanup on error
        if video_path.exists():
            os.remove(video_path)
        raise HTTPException(500, f"Error processing video: {str(e)}")


@app.post("/analyze-webcam-frame")
async def analyze_webcam_frame(frame: UploadFile = File(...)):
    """
    Analyze single frame from webcam
    
    Args:
        frame: Image file (jpg, png)
        
    Returns:
        JSON with pose analysis result
    """
    global model_handler
    
    try:
        # Load model on first request if not loaded
        if model_handler.model is None:
            logger.info("Loading TensorFlow model on first request...")
            model_handler.load_model()
            logger.info("Model loaded successfully!")
        
        import cv2
        import numpy as np
        
        # Read image file
        contents = await frame.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        # Analyze frame
        prediction = model_handler.predict(img)
        
        return JSONResponse(content=prediction)
        
    except Exception as e:
        logger.error(f"Error processing frame: {str(e)}")
        raise HTTPException(500, f"Error processing frame: {str(e)}")


def _generate_overall_feedback(results, expected_pose=None):
    """Generate human-readable overall feedback"""
    correct_count = sum(1 for r in results if r["is_correct"])
    accuracy = (correct_count / len(results)) * 100
    
    feedback = ""
    if expected_pose:
        feedback = f"Expected: {expected_pose}. "
    
    if accuracy >= 90:
        feedback += "Excellent! Your form is nearly perfect. Keep it up!"
    elif accuracy >= 70:
        feedback += "Good job! Minor adjustments needed in some frames."
    elif accuracy >= 50:
        feedback += "Decent attempt. Focus on maintaining proper form throughout."
    else:
        feedback += "Needs improvement. Review the pose guidelines and try again."
    
    return feedback


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
