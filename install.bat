@echo off
echo FramePack-Studio Setup Script
setlocal enabledelayedexpansion

REM Check if Python is installed (basic check)
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python is not installed or not in your PATH. Please install Python and try again.
    goto end
)

if exist "%cd%/venv" (
echo Virtual Environment already exists. 
set /p choice= "Do you want to reinstall packages?[Y/N]: "

if "!choice!" == "y" (goto checkgpu)
if "!choice!"=="Y" (goto checkgpu)

goto end
)

REM Check the python version
echo Python versions 3.10-3.12 have been confirmed to work. Other versions are currently not supported. You currently have:
python -V
set choice=
set /p choice= "Do you want to continue?[Y/N]: "


if "!choice!" == "y" (goto makevenv)
if "!choice!"=="Y" (goto makevenv)

goto end

:makevenv
REM This creates a virtual environment in the folder
echo Creating a Virtual Environment...
python -m venv venv
echo Upgrading pip in Virtual Environment to lower chance of error...
"%cd%/venv/Scripts/python.exe" -m pip install --upgrade pip

"%cd%/venv/Scripts/pip.exe" install torch==2.8.0.dev20250625 torchvision==0.23.0.dev20250626 torchaudio==2.8.0.dev20250626 pytorch-triton-rocm==3.3.1+gitc8757738 --index-url  https://download.pytorch.org/whl/nightly/rocm6.4

REM Check if pip installation was successful
if %errorlevel% neq 0 (
    echo Warning: Failed to install dependencies. You may need to install them manually.
    goto end
)

echo Installing remaining required packages through pip...
REM This assumes there's a requirements.txt file in the root
"%cd%/venv/Scripts/pip.exe" install -r requirements.txt 

REM Check if pip installation was successful
if %errorlevel% neq 0 (
    echo Warning: Failed to install dependencies. You may need to install them manually.
    goto end
)

echo Setup complete.

:end
echo Exiting setup script.
pause
