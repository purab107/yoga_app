const API_URL = 'http://localhost:8000';
let selectedFile = null;
let webcamStream = null;

// Tab switching
function switchTab(tab) {
    // Update tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    document.getElementById(`${tab}-tab`).classList.add('active');
    
    // Hide results when switching tabs
    document.getElementById('results').style.display = 'none';
}

// Video upload handling
document.getElementById('videoInput').addEventListener('change', function(e) {
    selectedFile = e.target.files[0];
    
    if (selectedFile) {
        // Show selected file info
        document.getElementById('fileName').textContent = selectedFile.name;
        document.getElementById('selectedFile').style.display = 'block';
        
        // Show video preview
        const videoPlayer = document.getElementById('videoPlayer');
        videoPlayer.src = URL.createObjectURL(selectedFile);
        document.getElementById('videoPreview').style.display = 'block';
        
        // Hide results from previous analysis
        document.getElementById('results').style.display = 'none';
    }
});

// Drag and drop support
const uploadBox = document.getElementById('uploadBox');

uploadBox.addEventListener('dragover', (e) => {
    e.preventDefault();
    uploadBox.classList.add('drag-over');
});

uploadBox.addEventListener('dragleave', () => {
    uploadBox.classList.remove('drag-over');
});

uploadBox.addEventListener('drop', (e) => {
    e.preventDefault();
    uploadBox.classList.remove('drag-over');
    
    const files = e.dataTransfer.files;
    if (files.length > 0 && files[0].type.startsWith('video/')) {
        document.getElementById('videoInput').files = files;
        document.getElementById('videoInput').dispatchEvent(new Event('change'));
    }
});

// Analyze video
async function analyzeVideo() {
    if (!selectedFile) {
        alert('Please select a video file first');
        return;
    }
    
    // Get selected pose
    const poseSelect = document.getElementById('poseSelect');
    const selectedPose = poseSelect.value;
    
    if (!selectedPose) {
        alert('Please select the asana from the dropdown before uploading your video.');
        return;
    }
    
    // Show loading
    document.getElementById('loading').style.display = 'block';
    document.getElementById('results').style.display = 'none';
    
    // Create form data
    const formData = new FormData();
    formData.append('video', selectedFile);
    formData.append('expected_pose', selectedPose);
    
    try {
        console.log('Sending video to:', `${API_URL}/analyze-pose`);
        const response = await fetch(`${API_URL}/analyze-pose`, {
            method: 'POST',
            body: formData
        });
        
        console.log('Response status:', response.status);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('Error response:', errorText);
            throw new Error(`HTTP error! status: ${response.status} - ${errorText}`);
        }
        
        const data = await response.json();
        console.log('Received data:', data);
        displayResults(data);
        
    } catch (error) {
        console.error('Full error:', error);
        console.error('Error name:', error.name);
        console.error('Error message:', error.message);
        alert('Error analyzing video: ' + error.message + '\n\nCheck console for details (F12)');
    } finally {
        document.getElementById('loading').style.display = 'none';
    }
}

// Display results
function displayResults(data) {
    // Update statistics
    document.getElementById('accuracy').textContent = `${data.accuracy_percentage}%`;
    document.getElementById('confidence').textContent = `${data.average_confidence.toFixed(2)}`;
    document.getElementById('framesCount').textContent = data.total_frames_analyzed;
    document.getElementById('correctFrames').textContent = `${data.correct_frames} / ${data.total_frames_analyzed}`;
    
    // Update overall feedback
    let feedbackText = data.overall_feedback;
    if (data.expected_pose) {
        feedbackText = `Expected Asana: ${data.expected_pose}\n\n${feedbackText}`;
    }
    document.getElementById('overallFeedback').textContent = feedbackText;
    
    // Update frame-by-frame results
    const frameResults = document.getElementById('frameResults');
    frameResults.innerHTML = '';
    
    data.frame_results.forEach(frame => {
        const frameCard = document.createElement('div');
        frameCard.className = `frame-card ${frame.is_correct ? 'correct' : 'incorrect'}`;
        frameCard.innerHTML = `
            <img src="${frame.image}" alt="Frame ${frame.frame_number + 1}" class="frame-image">
            <div class="frame-header">
                <span class="frame-number">Frame ${frame.frame_number + 1}</span>
                <span class="frame-status">${frame.is_correct ? '✅' : '❌'}</span>
            </div>
            <div class="frame-info">
                <p><strong>Pose:</strong> ${frame.pose_detected}</p>
                <p><strong>Confidence:</strong> ${(frame.confidence * 100).toFixed(1)}%</p>
                <p class="frame-feedback">${frame.feedback}</p>
            </div>
        `;
        frameResults.appendChild(frameCard);
    });
    
    // Show results
    document.getElementById('results').style.display = 'block';
    document.getElementById('results').scrollIntoView({ behavior: 'smooth' });
}

// Webcam functionality
async function startWebcam() {
    try {
        webcamStream = await navigator.mediaDevices.getUserMedia({ 
            video: { width: 640, height: 480 } 
        });
        
        const webcamElement = document.getElementById('webcam');
        webcamElement.srcObject = webcamStream;
        
        // Update button visibility
        document.getElementById('startWebcam').style.display = 'none';
        document.getElementById('captureBtn').style.display = 'inline-block';
        document.getElementById('stopWebcam').style.display = 'inline-block';
        
    } catch (error) {
        console.error('Error accessing webcam:', error);
        alert('Could not access webcam: ' + error.message);
    }
}

function stopWebcam() {
    if (webcamStream) {
        webcamStream.getTracks().forEach(track => track.stop());
        webcamStream = null;
        
        document.getElementById('webcam').srcObject = null;
        
        // Update button visibility
        document.getElementById('startWebcam').style.display = 'inline-block';
        document.getElementById('captureBtn').style.display = 'none';
        document.getElementById('stopWebcam').style.display = 'none';
    }
}

async function captureAndAnalyze() {
    const webcam = document.getElementById('webcam');
    const canvas = document.getElementById('canvas');
    const context = canvas.getContext('2d');
    
    // Set canvas size to match video
    canvas.width = webcam.videoWidth;
    canvas.height = webcam.videoHeight;
    
    // Draw current frame to canvas
    context.drawImage(webcam, 0, 0);
    
    // Convert canvas to blob
    canvas.toBlob(async (blob) => {
        // Show loading
        document.getElementById('loading').style.display = 'block';
        document.getElementById('results').style.display = 'none';
        
        // Create form data
        const formData = new FormData();
        formData.append('frame', blob, 'webcam-capture.jpg');
        
        try {
            const response = await fetch(`${API_URL}/analyze-webcam-frame`, {
                method: 'POST',
                body: formData
            });
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const data = await response.json();
            displayWebcamResult(data);
            
        } catch (error) {
            console.error('Error:', error);
            alert('Error analyzing frame: ' + error.message);
        } finally {
            document.getElementById('loading').style.display = 'none';
        }
    }, 'image/jpeg');
}

function displayWebcamResult(data) {
    // Update statistics (single frame)
    document.getElementById('accuracy').textContent = data.is_correct ? '100%' : '0%';
    document.getElementById('confidence').textContent = `${(data.confidence * 100).toFixed(1)}%`;
    document.getElementById('framesCount').textContent = '1';
    document.getElementById('correctFrames').textContent = data.is_correct ? '1 / 1' : '0 / 1';
    
    // Update overall feedback
    document.getElementById('overallFeedback').textContent = data.feedback;
    
    // Update frame results
    const frameResults = document.getElementById('frameResults');
    frameResults.innerHTML = `
        <div class="frame-card ${data.is_correct ? 'correct' : 'incorrect'}">
            <div class="frame-header">
                <span class="frame-number">Captured Frame</span>
                <span class="frame-status">${data.is_correct ? '✅' : '❌'}</span>
            </div>
            <div class="frame-info">
                <p><strong>Pose:</strong> ${data.pose_class}</p>
                <p><strong>Confidence:</strong> ${(data.confidence * 100).toFixed(1)}%</p>
                <p class="frame-feedback">${data.feedback}</p>
            </div>
        </div>
    `;
    
    // Show results
    document.getElementById('results').style.display = 'block';
    document.getElementById('results').scrollIntoView({ behavior: 'smooth' });
}

// Check API status on load
window.addEventListener('load', async () => {
    try {
        const response = await fetch(`${API_URL}/`);
        if (response.ok) {
            console.log('✅ Backend API is running');
        }
    } catch (error) {
        console.error('⚠️ Backend API is not accessible:', error);
        alert('Warning: Backend API is not running. Please start the backend server.');
    }
});
