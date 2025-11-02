@echo off
echo ========================================
echo Iniciando Analizador Completo
echo ========================================
echo.

REM Verificar que existe el ejecutable del parser
if not exist "parser.exe" (
    echo ERROR: No se encontro parser.exe
    echo.
    echo Por favor, ejecuta primero:
    echo   compilar_completo.bat
    echo.
    pause
    exit /b 1
)

echo Ejecutando GUI...
python analizador_completo.py

if errorlevel 1 (
    echo.
    echo ERROR: Fallo al ejecutar la GUI
    echo.
    echo Posibles causas:
    echo - Python no esta instalado o no esta en el PATH
    echo - Tkinter no esta instalado
    pause
    exit /b 1
)
