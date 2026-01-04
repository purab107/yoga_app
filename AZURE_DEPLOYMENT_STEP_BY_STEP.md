# 🎓 Azure Deployment Guide - Step by Step (Using Azure Portal Website)

**Complete guide to deploy your Yoga Pose Analyzer backend on Azure for FREE using your student subscription**

---

## 📋 Prerequisites Checklist

Before starting, make sure you have:
- ✅ Azure student account (activated at portal.azure.com)
- ✅ GitHub account
- ✅ Your yoga_app code ready

---

## 🚀 PART 1: Prepare Your Code for Deployment

### Step 1.1: Update Backend for Azure

1. Open `d:\yoga_app\backend\requirements.txt`
2. Add this line at the end (needed for Azure):
   ```
   gunicorn==21.2.0
   ```

3. Open `d:\yoga_app\backend\main.py`
4. Find line 33 that says:
   ```python
   SAVED_MODEL_PATH = "D:/yoga_app/model_prep/yoga_savedmodel"
   ```
5. Change it to:
   ```python
   SAVED_MODEL_PATH = os.path.join(os.path.dirname(__file__), "..", "model_prep", "yoga_savedmodel")
   ```

### Step 1.2: Create Azure Configuration File

1. Create a new file: `d:\yoga_app\backend\startup.sh`
2. Add this content:
   ```bash
   #!/bin/bash
   cd /home/site/wwwroot/backend
   gunicorn -w 2 -k uvicorn.workers.UvicornWorker main:app --bind=0.0.0.0:8000 --timeout 600
   ```

3. Create another file: `d:\yoga_app\.deployment`
4. Add this content:
   ```
   [config]
   SCM_DO_BUILD_DURING_DEPLOYMENT=true
   ```

---

## 📦 PART 2: Upload Your Code to GitHub

### Step 2.1: Create GitHub Repository

1. Go to **https://github.com**
2. Click **"New"** button (green button, top right)
3. Repository settings:
   - **Name:** `yoga-pose-analyzer`
   - **Description:** `AI-powered yoga pose analysis app`
   - **Visibility:** Private (recommended) or Public
   - **Don't** check "Initialize with README" (you already have one)
4. Click **"Create repository"**

### Step 2.2: Push Your Code to GitHub

1. Open **PowerShell** in VS Code
2. Navigate to your project:
   ```powershell
   cd d:\yoga_app
   ```

3. Initialize git (if not done):
   ```powershell
   git init
   ```

4. Add all files:
   ```powershell
   git add .
   ```

5. Commit:
   ```powershell
   git commit -m "Initial commit for Azure deployment"
   ```

6. Add remote (replace YOUR_USERNAME with your GitHub username):
   ```powershell
   git remote add origin https://github.com/YOUR_USERNAME/yoga-pose-analyzer.git
   ```

7. Push to GitHub:
   ```powershell
   git branch -M main
   git push -u origin main
   ```

8. **Enter your GitHub username and password when prompted**
   - If password doesn't work, use a Personal Access Token:
     - Go to GitHub → Settings → Developer settings → Personal access tokens → Generate new token
     - Select "repo" scope
     - Use this token as password

---

## ☁️ PART 3: Deploy on Azure Portal

### Step 3.1: Login to Azure

1. Open browser and go to **https://portal.azure.com**
2. Click **"Sign in"**
3. Use your **student email** and password
4. You should see the Azure Portal dashboard

### Step 3.2: Create a Web App

1. In the search bar at top, type: **"App Services"**
2. Click **"App Services"** from results
3. Click **"+ Create"** button (top left)
4. Click **"Web App"**

### Step 3.3: Configure Basic Settings

**On the "Basics" tab:**

| Field | Value |
|-------|-------|
| **Subscription** | Select "Azure for Students" |
| **Resource Group** | Click "Create new" → Name it: `yoga-app-rg` |
| **Name** | `yoga-analyzer-yourname` (must be globally unique) |
| **Publish** | Select **"Code"** |
| **Runtime stack** | Select **"Python 3.11"** |
| **Operating System** | Select **"Linux"** |
| **Region** | Select closest to you (e.g., "East US", "West Europe") |

**Pricing Plans section:**

1. Click **"Explore pricing plans"**
2. In the "Pricing Plans" page:
   - Find **"Dev/Test"** tab
   - Select **"F1"** (Free)
   - Shows: "1 GB memory, 60 minutes/day compute"
3. Click **"Select"**

### Step 3.4: Review and Create

1. Click **"Review + create"** (bottom left)
2. Wait for validation to pass (green checkmark)
3. Click **"Create"**
4. Wait 2-3 minutes for deployment
5. When done, click **"Go to resource"**

---

## 🔗 PART 4: Connect GitHub to Azure

### Step 4.1: Open Deployment Center

1. In your Web App page (yoga-analyzer-yourname), look at the left menu
2. Under **"Deployment"** section, click **"Deployment Center"**

### Step 4.2: Configure GitHub Connection

1. **Source:** Select **"GitHub"**
2. Click **"Authorize"** (if shown)
   - Sign in to GitHub if prompted
   - Click **"Authorize Azure App Service"**
3. After authorization, configure:

| Field | Value |
|-------|-------|
| **Organization** | Your GitHub username |
| **Repository** | `yoga-pose-analyzer` |
| **Branch** | `main` |
| **Build provider** | Select **"App Service Build Service"** |

4. Click **"Save"** (top left)

### Step 4.3: Wait for Deployment

1. You'll see "Deployment in progress..."
2. Click **"Logs"** to watch progress
3. First deployment takes **5-10 minutes**
4. Status will change to "Success (Active)" when done

---

## ⚙️ PART 5: Configure App Settings

### Step 5.1: Set Startup Command

1. In left menu, under **"Settings"**, click **"Configuration"**
2. Click on **"General settings"** tab
3. Find **"Startup Command"** field
4. Enter:
   ```
   gunicorn -w 2 -k uvicorn.workers.UvicornWorker main:app --bind=0.0.0.0:8000 --timeout 600 --chdir=/home/site/wwwroot/backend
   ```
5. Click **"Save"** (top)
6. Click **"Continue"** when prompted (app will restart)

### Step 5.2: Add Environment Variables

1. Still in **"Configuration"** page
2. Click **"Application settings"** tab
3. Click **"+ New application setting"**

**Add these settings one by one:**

| Name | Value |
|------|-------|
| `ENV` | `production` |
| `SCM_DO_BUILD_DURING_DEPLOYMENT` | `true` |
| `PYTHON_VERSION` | `3.11` |

4. After adding all, click **"Save"** (top)
5. Click **"Continue"** (app will restart again)

### Step 5.3: Enable Always On (Important!)

1. Still in **"Configuration"** → **"General settings"** tab
2. Find **"Always On"** toggle
3. Switch it to **"On"**
4. Click **"Save"** (top)
5. Click **"Continue"**

---

## 🧪 PART 6: Test Your Deployment

### Step 6.1: Get Your URL

1. In left menu, click **"Overview"**
2. Find **"Default domain"** - it looks like:
   ```
   https://yoga-analyzer-yourname.azurewebsites.net
   ```
3. Copy this URL

### Step 6.2: Test the API

1. Open a new browser tab
2. Go to your URL + `/docs`:
   ```
   https://yoga-analyzer-yourname.azurewebsites.net/docs
   ```
3. You should see **FastAPI documentation page** with your endpoints

4. Test the health check:
   ```
   https://yoga-analyzer-yourname.azurewebsites.net/
   ```
5. Should show: `{"status":"ok","message":"Yoga Pose Correction API is running"}`

---

## 📱 PART 7: Update Flutter App to Use Azure Backend

### Step 7.1: Create API Configuration

1. In VS Code, create new file: `d:\yoga_app\flutter_app\lib\config\api_config.dart`
2. Add this code:
```dart
class ApiConfig {
  // Replace with YOUR Azure URL
  static const String baseUrl = 'https://yoga-analyzer-yourname.azurewebsites.net';
  
  static const String analyzeEndpoint = '$baseUrl/analyze-pose';
  
  // For local testing, uncomment this:
  // static const String baseUrl = 'http://localhost:8000';
}
```

### Step 7.2: Update Video Upload Screen

1. Open: `d:\yoga_app\flutter_app\lib\screens\video_upload_screen.dart`
2. Find any line that has: `http://localhost:8000`
3. Replace with: `ApiConfig.baseUrl`
4. At the top of the file, add import:
```dart
import '../config/api_config.dart';
```

### Step 7.3: Update Processing Screen (if needed)

1. Open: `d:\yoga_app\flutter_app\lib\screens\processing_screen.dart`
2. Same process - replace localhost with `ApiConfig.analyzeEndpoint`

### Step 7.4: Build and Install APK

1. Open PowerShell in VS Code
2. Navigate to Flutter app:
   ```powershell
   cd d:\yoga_app\flutter_app
   ```

3. Build release APK:
   ```powershell
   flutter build apk --release
   ```

4. APK location will be shown:
   ```
   build\app\outputs\flutter-apk\app-release.apk
   ```

5. **Transfer to phone:**
   - Connect phone via USB
   - Copy APK to phone's Downloads folder
   - On phone: Open file manager → Install APK
   - Allow installation from unknown sources if prompted

---

## 🎉 PART 8: Test on Your Phone

1. Open the yoga app on your phone
2. Select an asana
3. Upload a video
4. Click "Analyze"
5. Wait for results (may take 30-60 seconds first time)

**Your app is now connected to Azure and works from anywhere! 🚀**

---

## 🔍 PART 9: Monitoring and Troubleshooting

### View Logs

1. In Azure Portal → Your Web App
2. Left menu → **"Log stream"**
3. See real-time logs as requests come in

### Check Deployment History

1. Left menu → **"Deployment Center"**
2. Click **"Logs"** to see all deployments
3. Can manually sync/redeploy from here

### Common Issues and Fixes

#### Issue 1: "Application Error" or 500 Error

**Solution:**
1. Go to **Configuration** → **General settings**
2. Verify startup command is correct
3. Check **Log stream** for errors

#### Issue 2: Model Not Loading

**Solution:**
1. Model files might be too large (Azure F1 has 1GB limit)
2. Check if model files were pushed to GitHub:
   ```powershell
   git lfs track "*.pb"
   git lfs track "*.tflite"
   git add .gitattributes
   git commit -m "Track large files"
   git push
   ```

#### Issue 3: Slow Response

**Solution:**
- First request after idle is slow (cold start)
- Enable "Always On" in Configuration → General settings
- F1 tier has limited compute, consider upgrading to B1

#### Issue 4: CORS Error from Flutter App

**Solution:**
1. Make sure CORS is enabled in `backend/main.py`
2. Should have: `allow_origins=["*"]`
3. Restart app in Azure

---

## 📊 PART 10: Monitor Usage and Costs

### Check Resource Usage

1. Azure Portal → **"Cost Management + Billing"**
2. Click **"Cost analysis"**
3. See your $100 student credit balance

### F1 Tier Limits

- ✅ **FREE** (no credit used)
- 1 GB RAM
- 1 GB storage
- 60 minutes/day compute (resets daily)
- Shared CPU

### When to Upgrade

If you see:
- Slow performance
- Frequent timeouts
- "Quota exceeded" errors

**Upgrade to B1 tier:**
1. Go to **"Scale up (App Service plan)"**
2. Select **"Production"** tab
3. Choose **"B1"** (~$13/month from your $100 credit)
4. Click **"Select"**

---

## 🔄 PART 11: Updating Your App

### When You Make Code Changes

1. Commit and push to GitHub:
   ```powershell
   git add .
   git commit -m "Your update description"
   git push
   ```

2. Azure automatically redeploys!
3. Check **Deployment Center** → **Logs** for progress
4. Usually takes 2-5 minutes

---

## 🎯 Quick Reference

### Your URLs

- **API Base:** `https://yoga-analyzer-yourname.azurewebsites.net`
- **API Docs:** `https://yoga-analyzer-yourname.azurewebsites.net/docs`
- **Health Check:** `https://yoga-analyzer-yourname.azurewebsites.net/`

### Important Pages in Azure Portal

- **Overview:** See URL, status, restart app
- **Deployment Center:** GitHub connection, deployment logs
- **Configuration:** Environment variables, startup command
- **Log stream:** Real-time logs
- **Scale up/out:** Change pricing tier

---

## ✅ Checklist - Did You Complete All Steps?

- [ ] Updated `requirements.txt` with gunicorn
- [ ] Fixed model path in `main.py` to use relative path
- [ ] Pushed code to GitHub
- [ ] Created Azure Web App (F1 tier)
- [ ] Connected GitHub to Azure
- [ ] Set startup command
- [ ] Enabled "Always On"
- [ ] Tested `/docs` endpoint works
- [ ] Created `api_config.dart` in Flutter app
- [ ] Updated Flutter app to use Azure URL
- [ ] Built APK and installed on phone
- [ ] Successfully analyzed a video from phone

---

## 🆘 Need Help?

**Azure Portal:** portal.azure.com
**Azure Status:** status.azure.com
**Azure Support:** Submit support ticket from portal

**Azure for Students Help:**
- https://aka.ms/azureforstudents
- https://docs.microsoft.com/azure/app-service/

---

## 🎓 Congratulations!

You now have a **production-grade, 24/7 available** yoga pose analyzer API running on Azure that you can access from any phone anywhere in the world! 🌍

Your app is:
- ✅ Deployed on enterprise cloud infrastructure
- ✅ Accessible via HTTPS
- ✅ Always online (no sleep)
- ✅ FREE with your student subscription
- ✅ Automatically updates when you push to GitHub

**Share your app with friends and add it to your portfolio!** 🚀
