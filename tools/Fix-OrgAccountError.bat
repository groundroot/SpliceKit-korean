@echo off
:: ============================================================
::  Fix-OrgAccountError.bat
::  "Another account from your organization is already signed
::   in on this device" 오류 자동 수정 도구
::  작성: groundroot/SpliceKit-korean
:: ============================================================

:: --- 관리자 권한 자동 요청 ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 관리자 권한이 필요합니다. UAC 창이 열립니다...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: --- PowerShell 스크립트 인라인 실행 ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"& {

# ─── 색상/UI 헬퍼 ───────────────────────────────────────────
function Write-Header {
    Clear-Host
    Write-Host ''
    Write-Host '  ╔══════════════════════════════════════════════════════════╗' -ForegroundColor Cyan
    Write-Host '  ║   조직 계정 오류 자동 수정 도구  v1.0                   ║' -ForegroundColor Cyan
    Write-Host '  ║   Another account from your organization is already      ║' -ForegroundColor Cyan
    Write-Host '  ║   signed in on this device                               ║' -ForegroundColor Cyan
    Write-Host '  ╚══════════════════════════════════════════════════════════╝' -ForegroundColor Cyan
    Write-Host ''
}

function Write-Step { param([int]$n, [string]$msg)
    Write-Host "  [$n/4] $msg" -ForegroundColor Yellow
}

function Write-OK   { param([string]$msg) Write-Host '       ✔ ' -NoNewline -ForegroundColor Green;  Write-Host $msg }
function Write-SKIP { param([string]$msg) Write-Host '       - ' -NoNewline -ForegroundColor Gray;   Write-Host $msg }
function Write-WARN { param([string]$msg) Write-Host '       ! ' -NoNewline -ForegroundColor Red;    Write-Host $msg }

Write-Header

# ─── STEP 1: 앱에서 사용하는 Microsoft 계정 제거 ───────────────
Write-Step 1 '앱 계정(Email & accounts) 정리 중...'

\$regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent'
if (Test-Path \$regPath) {
    Remove-Item -Path \$regPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-OK 'CloudExperienceHost Intent 레지스트리 항목 제거'
} else {
    Write-SKIP 'CloudExperienceHost Intent 항목 없음 (건너뜀)'
}

\$tokenPath = 'HKCU:\Software\Microsoft\IdentityCRL\TokenBroker\Accounts'
if (Test-Path \$tokenPath) {
    Remove-Item -Path \$tokenPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-OK 'TokenBroker 계정 캐시 제거'
} else {
    Write-SKIP 'TokenBroker 계정 항목 없음 (건너뜀)'
}

Write-Host ''

# ─── STEP 2: 자격 증명 관리자 (Credential Manager) 정리 ────────
Write-Step 2 '자격 증명 관리자 캐시 정리 중...'

\$patterns = @('MicrosoftOffice*','*AzureAD*','*MicrosoftAccount*',
               '*AAD*','*office365*','*live.com*','*microsoftonline*')
\$removed = 0

foreach (\$pat in \$patterns) {
    try {
        \$creds = cmdkey /list 2>\$null |
                 Select-String '대상|Target' |
                 ForEach-Object { (\$_ -replace '.*?(대상|Target)\s*:\s*','').Trim() } |
                 Where-Object { \$_ -like \$pat }
        foreach (\$c in \$creds) {
            cmdkey /delete:\$c 2>\$null | Out-Null
            Write-OK \"제거됨: \$c\"
            \$removed++
        }
    } catch {}
}

# PowerShell CredentialManager 모듈 방식도 시도
\$credManagerAssembly = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.CSharp')
\$vaultTypes = @('MicrosoftAccount','Domain:target=MicrosoftOffice*')
foreach (\$v in \$vaultTypes) {
    try {
        \$cmd = \"cmdkey /delete:\`\"\$v\`\"\"
        Invoke-Expression \$cmd 2>\$null | Out-Null
    } catch {}
}

if (\$removed -eq 0) { Write-SKIP '제거할 자격 증명 항목 없음' }
else { Write-OK \"총 \$removed 개 항목 제거 완료\" }

Write-Host ''

# ─── STEP 3: AAD/Work 계정 레지스트리 토큰 캐시 정리 ───────────
Write-Step 3 'Azure AD / 회사 계정 토큰 캐시 정리 중...'

\$aadPaths = @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\AAD',
    'HKCU:\Software\Microsoft\Office\16.0\Common\Identity',
    'HKCU:\Software\Microsoft\Office\15.0\Common\Identity',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSIECompatCache'
)

foreach (\$p in \$aadPaths) {
    if (Test-Path \$p) {
        Remove-Item -Path \$p -Recurse -Force -ErrorAction SilentlyContinue
        Write-OK \"캐시 제거: \$(\$p -replace 'HKCU:\\\\','')\"
    } else {
        Write-SKIP \"없음: \$(\$p -replace 'HKCU:\\\\','')\"
    }
}

# MSAL 토큰 캐시 파일 정리
\$msalCache = \"\$env:LOCALAPPDATA\Microsoft\MsalTokenCache\"
if (Test-Path \$msalCache) {
    Remove-Item -Path \$msalCache -Recurse -Force -ErrorAction SilentlyContinue
    Write-OK 'MSAL 토큰 캐시 파일 제거'
} else {
    Write-SKIP 'MSAL 캐시 없음'
}

Write-Host ''

# ─── STEP 4: SFC 시스템 파일 검사 ──────────────────────────────
Write-Step 4 '시스템 파일 무결성 검사 (sfc /scannow) 실행 중...'
Write-Host '       이 단계는 수 분이 소요될 수 있습니다. 잠시 기다려 주세요...' -ForegroundColor Gray
Write-Host ''

\$sfcResult = & sfc /scannow 2>&1
if (\$LASTEXITCODE -eq 0) {
    Write-OK 'SFC 검사 완료 — 손상된 파일 없음 또는 복구 완료'
} else {
    Write-WARN 'SFC 검사 중 문제 발생. CBS.log를 확인하세요.'
}

# ─── 완료 메시지 ────────────────────────────────────────────────
Write-Host ''
Write-Host '  ══════════════════════════════════════════════════════════' -ForegroundColor Cyan
Write-Host ''
Write-Host '  ✔ 모든 수정 작업이 완료되었습니다!' -ForegroundColor Green
Write-Host ''
Write-Host '  다음 단계:' -ForegroundColor White
Write-Host '    1. 컴퓨터를 재시작하세요.' -ForegroundColor Gray
Write-Host '    2. 재시작 후 Microsoft 계정으로 다시 로그인하세요.' -ForegroundColor Gray
Write-Host '    3. 오류가 지속되면 설정 > 계정 > 회사/학교 액세스에서' -ForegroundColor Gray
Write-Host '       기존 계정을 연결 해제 후 재연결하세요.' -ForegroundColor Gray
Write-Host ''
Write-Host '  ══════════════════════════════════════════════════════════' -ForegroundColor Cyan
Write-Host ''

\$restart = Read-Host '  지금 바로 재시작하시겠습니까? (Y/N)'
if (\$restart -match '^[Yy]') {
    Write-Host '  5초 후 재시작합니다...' -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    Restart-Computer -Force
} else {
    Write-Host '  수동으로 재시작해 주세요.' -ForegroundColor Gray
    Write-Host ''
    Read-Host '  엔터를 누르면 종료됩니다'
}

}"
