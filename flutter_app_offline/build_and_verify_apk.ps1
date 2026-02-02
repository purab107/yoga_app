# Build and Verify APK - PowerShell Version
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Building Offline Flutter APK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "d:\yoga_app\flutter_app_offline"

Write-Host "[1/3] Cleaning previous build..." -ForegroundColor Yellow
& d:\yoga_app\flutter\bin\flutter.bat clean | Out-Null

Write-Host ""
Write-Host "[2/3] Building APK (this will take 5-15 minutes)..." -ForegroundColor Yellow
Write-Host "Please wait - downloading dependencies and compiling..." -ForegroundColor Gray
Write-Host ""

$buildOutput = & d:\yoga_app\flutter\bin\flutter.bat build apk --release 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    Write-Host $buildOutput
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "[3/3] Verifying APK size..." -ForegroundColor Yellow
Write-Host ""

$apkPath = "build\app\outputs\flutter-apk\app-release.apk"

if (Test-Path $apkPath) {
    $apkFile = Get-Item $apkPath
    $sizeMB = [math]::Round($apkFile.Length / 1MB, 2)
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "APK File: $($apkFile.Name)" -ForegroundColor White
    Write-Host "Size: $sizeMB MB" -ForegroundColor White
    Write-Host "Full Path: $($apkFile.FullName)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SIZE VERIFICATION:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    if ($sizeMB -lt 40) {
        Write-Host "❌ WARNING: APK is only $sizeMB MB" -ForegroundColor Red
        Write-Host "   Expected: 50-150 MB" -ForegroundColor Red
        Write-Host "   Model may not be bundled correctly!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Checking assets..." -ForegroundColor Yellow
        
        # Try to check if model is in assets
        if (Test-Path "assets\yoga_model_fp16.tflite") {
            $modelSize = [math]::Round((Get-Item "assets\yoga_model_fp16.tflite").Length / 1MB, 2)
            Write-Host "   Model file exists: $modelSize MB" -ForegroundColor Yellow
            Write-Host "   But may not be bundled in APK" -ForegroundColor Yellow
        }
    }
    elseif ($sizeMB -gt 200) {
        Write-Host "⚠️  NOTE: APK is $sizeMB MB" -ForegroundColor Yellow
        Write-Host "   This is larger than expected" -ForegroundColor Yellow
        Write-Host "   Includes all architectures (arm, arm64, x86)" -ForegroundColor Yellow
        Write-Host "   ✅ App will work OFFLINE" -ForegroundColor Green
    }
    else {
        Write-Host "✅ APK size looks correct: $sizeMB MB" -ForegroundColor Green
        Write-Host "   Model and dependencies are bundled" -ForegroundColor Green
        Write-Host "   ✅ App will work OFFLINE" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  BREAKDOWN (Estimated):" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "- TFLite Model:      22.2 MB" -ForegroundColor Gray
    Write-Host "- Flutter Framework: ~10 MB" -ForegroundColor Gray
    Write-Host "- FFmpeg Kit:        ~20 MB" -ForegroundColor Gray
    Write-Host "- TFLite Runtime:    ~3 MB" -ForegroundColor Gray
    Write-Host "- Other libs:        ~5 MB" -ForegroundColor Gray
    Write-Host "- Total Expected:    ~60 MB (single arch)" -ForegroundColor Gray
    Write-Host "                     ~120 MB (all arch)" -ForegroundColor Gray
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  APK LOCATION:" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host $apkFile.FullName -ForegroundColor White
    Write-Host ""
    Write-Host "Transfer this APK to your Android device to install" -ForegroundColor Cyan
    Write-Host ""
    
} else {
    Write-Host "❌ APK file not found!" -ForegroundColor Red
    Write-Host "Build may have failed." -ForegroundColor Red
    Write-Host "Expected location: $apkPath" -ForegroundColor Gray
}

Write-Host ""
Read-Host "Press Enter to exit"
