@echo off
echo ========================================
echo Compilando Analizador Completo
echo (Lexico + Sintactico + Semantico)
echo ========================================
echo.

REM Verificar si existe win_flex_bison
if exist "win_flex_bison-2.5.25\win_bison.exe" (
    set BISON=win_flex_bison-2.5.25\win_bison.exe
    set FLEX=win_flex_bison-2.5.25\win_flex.exe
) else if exist "flex.exe" (
    set FLEX=flex.exe
    set BISON=bison.exe
) else (
    set FLEX=flex
    set BISON=bison
)

echo [1/4] Generando parser con BISON...
%BISON% -d parser.y
if errorlevel 1 (
    echo ERROR: Fallo al generar el parser con BISON
    pause
    exit /b 1
)
echo OK - Parser generado (parser.tab.c, parser.tab.h)
echo.

echo [2/4] Generando lexer con FLEX...
%FLEX% -o lex.yy.c lexer_parser.l
if errorlevel 1 (
    echo ERROR: Fallo al generar el lexer con FLEX
    pause
    exit /b 1
)
echo OK - Lexer generado (lex.yy.c)
echo.

echo [3/4] Compilando con GCC...
gcc parser.tab.c lex.yy.c semantico.c -o parser.exe -O2
if errorlevel 1 (
    echo ERROR: Fallo la compilacion con GCC
    echo.
    echo Posibles causas:
    echo - GCC no esta instalado o no esta en el PATH
    echo - Errores de sintaxis en los archivos
    pause
    exit /b 1
)
echo OK - Ejecutable generado (parser.exe)
echo.

echo [4/4] Limpiando archivos temporales...
if exist "parser.tab.c" del parser.tab.c
if exist "lex.yy.c" del lex.yy.c
echo OK - Archivos temporales eliminados
echo.

echo ========================================
echo COMPILACION EXITOSA!
echo ========================================
echo.
echo Ejecutable: parser.exe
echo.
echo Para analizar un archivo:
echo   parser.exe archivo.txt
echo.
pause
