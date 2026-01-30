const API_URL = 'http://localhost:8000';
let selectedFile = null;
let webcamStream = null;
let currentFrameIndex = 0;
let frameResultsData = [];
let showAllFrames = false;
let analysisData = null;

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
    analysisData = data;
    frameResultsData = data.frame_results || [];
    currentFrameIndex = 0;
    showAllFrames = false;
    
    // Update asana name
    document.getElementById('asanaName').textContent = data.expected_pose || 'Yoga Asana';
    
    // Update statistics
    const accuracy = data.accuracy_percentage || 0;
    document.getElementById('accuracy').textContent = `${accuracy.toFixed(1)}%`;
    document.getElementById('confidence').textContent = `${(data.average_confidence * 100).toFixed(1)}%`;
    document.getElementById('framesCount').textContent = data.total_frames_analyzed || 0;
    document.getElementById('correctFrames').textContent = `${data.correct_frames || 0}/${data.total_frames_analyzed || 0}`;
    
    // Update status banner
    updateStatusBanner(accuracy);
    
    // Update overall feedback
    document.getElementById('overallFeedback').textContent = data.overall_feedback || 'No feedback available';
    
    // Initialize video analysis
    if (frameResultsData.length > 0) {
        updateVideoPlayer(0);
        document.querySelector('.video-analysis-section').style.display = 'block';
    } else {
        document.querySelector('.video-analysis-section').style.display = 'none';
    }
    
    // Update frame-by-frame results
    renderFrameCards();
    
    // Show results
    document.getElementById('results').style.display = 'block';
    document.getElementById('results').scrollIntoView({ behavior: 'smooth' });
}

function updateStatusBanner(accuracy) {
    const banner = document.getElementById('statusBanner');
    const statusText = document.getElementById('statusText');
    const statusIcon = banner.querySelector('.status-icon');
    
    banner.className = 'status-banner';
    
    if (accuracy >= 90) {
        banner.classList.add('status-excellent');
        statusText.textContent = 'Excellent';
        statusIcon.textContent = '✓';
    } else if (accuracy >= 70) {
        banner.classList.add('status-good');
        statusText.textContent = 'Good';
        statusIcon.textContent = '⚠';
    } else {
        banner.classList.add('status-needs-improvement');
        statusText.textContent = 'Needs Improvement';
        statusIcon.textContent = '✗';
    }
}

function updateVideoPlayer(index) {
    if (index < 0 || index >= frameResultsData.length) return;
    
    currentFrameIndex = index;
    const frame = frameResultsData[index];
    
    // Update frame image
    const frameImage = document.getElementById('currentFrameImage');
    frameImage.src = frame.image || '';
    frameImage.style.display = frame.image ? 'block' : 'none';
    
    // Update feedback badge
    const feedbackBadge = document.getElementById('frameFeedbackBadge');
    const isCorrect = frame.is_correct || false;
    const pose = frame.pose_detected || 'Unknown';
    const confidence = ((frame.confidence || 0) * 100).toFixed(1);
    
    feedbackBadge.textContent = isCorrect 
        ? `✓ Correct Form - ${pose} (${confidence}%)` 
        : `✗ Adjust Pose - ${pose} (${confidence}%)`;
    feedbackBadge.className = isCorrect ? 'feedback-badge correct' : 'feedback-badge incorrect';
    
    // Update frame counter
    document.getElementById('frameCounter').textContent = `Frame ${index + 1}/${frameResultsData.length}`;
    
    // Update progress bar
    const progressBar = document.getElementById('progressBar');
    const progress = ((index + 1) / frameResultsData.length) * 100;
    progressBar.style.width = `${progress}%`;
    
    // Update button states
    document.getElementById('prevFrameBtn').disabled = index === 0;
    document.getElementById('nextFrameBtn').disabled = index === frameResultsData.length - 1;
}

function previousFrame() {
    if (currentFrameIndex > 0) {
        updateVideoPlayer(currentFrameIndex - 1);
    }
}

function nextFrame() {
    if (currentFrameIndex < frameResultsData.length - 1) {
        updateVideoPlayer(currentFrameIndex + 1);
    }
}

async function playFrameSequence() {
    const playBtn = document.getElementById('playBtn');
    const playIcon = playBtn.querySelector('span');
    
    // Disable button during playback
    playBtn.disabled = true;
    playIcon.textContent = '⏸';
    
    for (let i = 0; i < frameResultsData.length; i++) {
        updateVideoPlayer(i);
        await new Promise(resolve => setTimeout(resolve, 800));
    }
    
    // Re-enable button
    playBtn.disabled = false;
    playIcon.textContent = '▶';
}

function renderFrameCards() {
    const frameResults = document.getElementById('frameResults');
    frameResults.innerHTML = '';
    
    const framesToShow = showAllFrames ? frameResultsData : frameResultsData.slice(0, 5);
    
    framesToShow.forEach(frame => {
        const frameCard = document.createElement('div');
        frameCard.className = `frame-card ${frame.is_correct ? 'correct' : 'incorrect'}`;
        
        const frameNum = (frame.frame_number || 0) + 1;
        const pose = frame.pose_detected || 'Unknown';
        const confidence = ((frame.confidence || 0) * 100).toFixed(1);
        const feedback = frame.feedback || '';
        
        frameCard.innerHTML = `
            ${frame.image ? `<img src="${frame.image}" alt="Frame ${frameNum}" class="frame-image">` : ''}
            <div class="frame-header">
                <span class="frame-number">Frame ${frameNum}</span>
                <span class="frame-status">${frame.is_correct ? '✅' : '❌'}</span>
            </div>
            <div class="frame-info">
                <p><strong>Pose:</strong> ${pose}</p>
                <p><strong>Confidence:</strong> ${confidence}%</p>
                ${feedback ? `<p class="frame-feedback">${feedback}</p>` : ''}
            </div>
        `;
        frameResults.appendChild(frameCard);
    });
    
    // Update toggle button
    const toggleBtn = document.getElementById('toggleFramesBtn');
    const toggleText = document.getElementById('toggleText');
    const toggleIcon = document.getElementById('toggleIcon');
    
    if (frameResultsData.length > 5) {
        toggleBtn.style.display = 'flex';
        if (showAllFrames) {
            toggleText.textContent = 'Show less';
            toggleIcon.textContent = '▲';
        } else {
            toggleText.textContent = `+ ${frameResultsData.length - 5} more frames`;
            toggleIcon.textContent = '▼';
        }
    } else {
        toggleBtn.style.display = 'none';
    }
}

function toggleFrames() {
    showAllFrames = !showAllFrames;
    renderFrameCards();
}

function retakeVideo() {
    // Hide results and reset video
    document.getElementById('results').style.display = 'none';
    document.getElementById('videoPreview').scrollIntoView({ behavior: 'smooth' });
}

function backToHome() {
    // Hide results and reset everything
    document.getElementById('results').style.display = 'none';
    document.getElementById('selectedFile').style.display = 'none';
    document.getElementById('videoPreview').style.display = 'none';
    selectedFile = null;
    document.getElementById('videoInput').value = '';
    document.getElementById('poseSelect').value = '';
    window.scrollTo({ top: 0, behavior: 'smooth' });
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
