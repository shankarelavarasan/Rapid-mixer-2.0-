@echo off
echo 🚀 Fixing GitHub Pages Flutter Web Deployment
echo =============================================

REM Navigate to Flutter project directory
cd /d "%~dp0"

REM Check if we're in the correct directory
echo 📁 Current directory: %CD%

REM Look for Flutter project files
echo 🔍 Searching for Flutter project...
if exist "rapidmixer_2_0\pubspec.yaml" (
    echo ✅ Found Flutter project in rapidmixer_2_0
    cd rapidmixer_2_0
) else if exist "pubspec.yaml" (
    echo ✅ Found Flutter project in root directory
) else (
    echo ❌ No Flutter project found!
    echo Please ensure you have a Flutter project with pubspec.yaml
    pause
    exit /b 1
)

REM Check Flutter installation
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter not found in PATH!
    echo Please install Flutter and add it to your PATH
    pause
    exit /b 1
)

echo ✅ Flutter found!

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Build web version with optimizations
echo 🔨 Building Flutter web with optimizations...
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true --dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/

REM Check if build was successful
if not exist "build\web" (
    echo ❌ Build failed! Check Flutter output above
    pause
    exit /b 1
)

echo ✅ Build completed successfully!

REM Copy build files to root for GitHub Pages
echo 📂 Copying build files to root directory...
cd ..  
if exist "rapidmixer_2_0\build\web" (
    xcopy /E /Y /I "rapidmixer_2_0\build\web\*" ".\"
    echo ✅ Files copied to root directory for GitHub Pages
) else (
    echo ❌ Build web directory not found!
    pause
    exit /b 1
)

REM Create .nojekyll file for GitHub Pages
echo. > .nojekyll
echo ✅ Created .nojekyll file for GitHub Pages

REM Update index.html with proper base href
echo 🔧 Updating index.html for GitHub Pages...
powershell -Command "(Get-Content index.html) -replace '<base href=\"/\"', '<base href=\"/Rapid-mixer-2.0-/\"' | Set-Content index.html"

REM Check Git status
echo 📊 Git status:
git status

echo.
echo 🎉 GitHub Pages deployment preparation complete!
echo.
echo Next steps:
echo 1. Run: git add .
echo 2. Run: git commit -m "Deploy Flutter web to GitHub Pages"
echo 3. Run: git push origin main
echo.
echo After push, wait 2-5 minutes for GitHub Pages to update
echo Your site should be available at: https://shankarelavarasan.github.io/Rapid-mixer-2.0-/
pause