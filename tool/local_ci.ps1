param(
    [switch]$FullBuild = $false
)

$ErrorActionPreference = "Stop"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "🚀 Starting Local CI Checks for Flutter User-app-and-web" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

# Stage 1: Dependencies
Write-Host "`n📦 [1/3] Fetching dependencies (flutter pub get)..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to fetch dependencies." -ForegroundColor Red
    exit 1
}

# Stage 2: Code Analysis
Write-Host "`n🔍 [2/3] Running static code analysis (flutter analyze --no-fatal-infos lib/)..." -ForegroundColor Yellow
flutter analyze --no-fatal-infos lib/
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Static analysis failed with issues." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Static analysis passed with 0 errors!" -ForegroundColor Green

# Stage 3: Test Suites
Write-Host "`n🧪 [3/3] Running automated unit, integration, and security tests..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ One or more tests failed." -ForegroundColor Red
    exit 1
}
Write-Host "✅ All tests passed successfully!" -ForegroundColor Green

# Optional Stage 4: Smoke Build
if ($FullBuild) {
    Write-Host "`n🏗️ [Optional 4/4] Running smoke debug APK build..." -ForegroundColor Yellow
    flutter build apk --debug
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Smoke build failed." -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Debug APK built successfully!" -ForegroundColor Green
}

Write-Host "`n🎉 ======================================================" -ForegroundColor Green
Write-Host "✅ All Local CI checks completed successfully! Ready to commit." -ForegroundColor Green
Write-Host "======================================================`n" -ForegroundColor Green
