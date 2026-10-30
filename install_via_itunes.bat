@echo off
chcp 65001 >nul
title Cai dat StopTheMadness Pro qua iTunes / USB

echo ===================================================================
echo     CÔNG CỤ NẠP STOPTHEMADNESS PRO VÀO IPHONE QUA ITUNES / USB
echo ===================================================================
echo.
echo [1] Kiem tra file StopTheMadnessPro.ipa...
if exist "StopTheMadnessPro.ipa" (
    echo     --^> Tim thay file StopTheMadnessPro.ipa san sang!
) else (
    echo     --^> Khong tim thay file IPA, dang tien hanh tao goi...
    powershell -ExecutionPolicy Bypass -File .\package_itunes_ipa.ps1
)
echo.

echo [2] Huong dan cai dat truc tiep vao iPhone dang ket noi:
echo -------------------------------------------------------------------
echo  CACH 1 (Qua iTunes ban App Sync 12.6.x hoac Apple Configurator):
echo   1. Mo iTunes tren may tinh va cam cap iPhone (chon Trust).
echo   2. Chuyen den bieu tuong thiet bi iPhone tren iTunes.
echo   3. Keo va tha truc tiep file "StopTheMadnessPro.ipa" vao muc Apps.
echo   4. Bam nut "Sync" (Dong bo) de bat dau cai dat.
echo.
echo  CACH 2 (Qua Sideloadly - Tu dong ky khong can Jailbreak):
echo   1. Mo phan mem Sideloadly (mien phi).
echo   2. Keo file "StopTheMadnessPro.ipa" vao Sideloadly.
echo   3. Nhap Apple ID cua ban va bam "Start".
echo -------------------------------------------------------------------
echo.

REM Kiem tra xem iTunes co tren he thong khong de mo giup nguoi dung
if exist "%ProgramFiles%\iTunes\iTunes.exe" (
    echo Dang khoi dong iTunes...
    start "" "%ProgramFiles%\iTunes\iTunes.exe"
) else if exist "%ProgramFiles(x86)%\iTunes\iTunes.exe" (
    echo Dang khoi dong iTunes...
    start "" "%ProgramFiles(x86)%\iTunes\iTunes.exe"
)

echo Dang mo thu muc chua file StopTheMadnessPro.ipa...
explorer /select,"StopTheMadnessPro.ipa"

echo.
pause
