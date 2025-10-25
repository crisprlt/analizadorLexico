@echo off
echo ========================================
echo   COMPILANDO ANALIZADOR LEXICO - FLEX
echo ========================================
echo.

REM Verificar si flex está disponible
where flex >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] No se encontro FLEX en el sistema
    echo.
    echo Por favor, instala FLEX y agregalo al PATH:
    echo 1. Descarga win_flex_bison de: https://github.com/lexxmark/winflexbison
    echo 2. Extrae el contenido
    echo 3. Agrega la carpeta al PATH del sistema
    echo    O renombra win_flex.exe a flex.exe y copialo aqui
    echo.
    pause
    exit /b 1
)

echo [1/3] Generando codigo C con FLEX...
flex -o lexer.c lexer.l
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Fallo la generacion con FLEX
    pause
    exit /b 1
)
echo [OK] Codigo C generado: lexer.c

echo.
echo [2/3] Verificando compilador GCC...
where gcc >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] No se encontro GCC en el sistema
    echo.
    echo Por favor, instala MinGW-w64 o TDM-GCC:
    echo - MinGW-w64: https://www.mingw-w64.org/
    echo - TDM-GCC: https://jmeubank.github.io/tdm-gcc/
    echo.
    pause
    exit /b 1
)

echo [3/3] Compilando con GCC...
gcc lexer.c -o lexer.exe -O2
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Fallo la compilacion con GCC
    pause
    exit /b 1
)

echo [OK] Ejecutable generado: lexer.exe
echo.
echo ========================================
echo   COMPILACION EXITOSA
echo ========================================
echo.
echo Archivos generados:
echo   - lexer.c (codigo fuente en C)
echo   - lexer.exe (ejecutable)
echo.
echo Para ejecutar la interfaz grafica:
echo   python analizador_gui.py
echo.
pause
