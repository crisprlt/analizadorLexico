%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

%}

%option noyywrap
%option yylineno

/* Definiciones de patrones */
DIGITO      [0-9]
LETRA       [a-zA-Z_]
ID          {LETRA}({LETRA}|{DIGITO})*
ENTERO      {DIGITO}+
REAL        {DIGITO}+\.{DIGITO}+
CADENA      \"[^\"]*\"
ESPACIO     [ \t]+
COMENTARIO  "//".*

%%

    /* Palabras reservadas */
"if"            { yylval.cadena = strdup(yytext); return IF; }
"else"          { yylval.cadena = strdup(yytext); return ELSE; }
"while"         { yylval.cadena = strdup(yytext); return WHILE; }
"for"           { yylval.cadena = strdup(yytext); return FOR; }
"do"            { yylval.cadena = strdup(yytext); return DO; }
"break"         { yylval.cadena = strdup(yytext); return BREAK; }
"continue"      { yylval.cadena = strdup(yytext); return CONTINUE; }
"return"        { yylval.cadena = strdup(yytext); return RETURN; }
"class"         { yylval.cadena = strdup(yytext); return CLASS; }

    /* Tipos de datos */
"int"           { yylval.cadena = strdup(yytext); return TIPO_DATO; }
"float"         { yylval.cadena = strdup(yytext); return TIPO_DATO; }
"double"        { yylval.cadena = strdup(yytext); return TIPO_DATO; }
"char"          { yylval.cadena = strdup(yytext); return TIPO_DATO; }
"string"        { yylval.cadena = strdup(yytext); return TIPO_DATO; }
"bool"          { yylval.cadena = strdup(yytext); return TIPO_DATO; }
"void"          { yylval.cadena = strdup(yytext); return TIPO_DATO; }

    /* Booleanos */
"true"          { yylval.cadena = strdup(yytext); return BOOLEANO; }
"false"         { yylval.cadena = strdup(yytext); return BOOLEANO; }

    /* Modificadores */
"public"        { yylval.cadena = strdup(yytext); return MODIFICADOR; }
"private"       { yylval.cadena = strdup(yytext); return MODIFICADOR; }
"protected"     { yylval.cadena = strdup(yytext); return MODIFICADOR; }
"static"        { yylval.cadena = strdup(yytext); return MODIFICADOR; }
"const"         { yylval.cadena = strdup(yytext); return MODIFICADOR; }

    /* Operadores aritméticos */
"++"            { yylval.cadena = strdup(yytext); return OPERADOR_ARITMETICO; }
"--"            { yylval.cadena = strdup(yytext); return OPERADOR_ARITMETICO; }
"+"             { yylval.cadena = strdup(yytext); return OPERADOR_ARITMETICO; }
"-"             { yylval.cadena = strdup(yytext); return OPERADOR_ARITMETICO; }
"*"             { yylval.cadena = strdup(yytext); return OPERADOR_ARITMETICO; }
"/"             { yylval.cadena = strdup(yytext); return OPERADOR_ARITMETICO; }
"%"             { yylval.cadena = strdup(yytext); return OPERADOR_ARITMETICO; }

    /* Operadores relacionales */
"=="            { yylval.cadena = strdup(yytext); return OPERADOR_RELACIONAL; }
"!="            { yylval.cadena = strdup(yytext); return OPERADOR_RELACIONAL; }
"<="            { yylval.cadena = strdup(yytext); return OPERADOR_RELACIONAL; }
">="            { yylval.cadena = strdup(yytext); return OPERADOR_RELACIONAL; }
"<"             { yylval.cadena = strdup(yytext); return OPERADOR_RELACIONAL; }
">"             { yylval.cadena = strdup(yytext); return OPERADOR_RELACIONAL; }

    /* Operadores lógicos */
"&&"            { yylval.cadena = strdup(yytext); return OPERADOR_LOGICO; }
"||"            { yylval.cadena = strdup(yytext); return OPERADOR_LOGICO; }
"!"             { yylval.cadena = strdup(yytext); return OPERADOR_LOGICO; }

    /* Operador de asignación */
"+="            { yylval.cadena = strdup(yytext); return OPERADOR_ASIGNACION; }
"-="            { yylval.cadena = strdup(yytext); return OPERADOR_ASIGNACION; }
"*="            { yylval.cadena = strdup(yytext); return OPERADOR_ASIGNACION; }
"/="            { yylval.cadena = strdup(yytext); return OPERADOR_ASIGNACION; }
"="             { yylval.cadena = strdup(yytext); return OPERADOR_ASIGNACION; }

    /* Delimitadores */
";"             { yylval.cadena = strdup(yytext); return PUNTO_COMA; }
","             { yylval.cadena = strdup(yytext); return COMA; }
"."             { yylval.cadena = strdup(yytext); return PUNTO; }
":"             { yylval.cadena = strdup(yytext); return DOS_PUNTOS; }

    /* Paréntesis, llaves y corchetes */
"("             { yylval.cadena = strdup(yytext); return PARENTESIS_IZQ; }
")"             { yylval.cadena = strdup(yytext); return PARENTESIS_DER; }
"{"             { yylval.cadena = strdup(yytext); return LLAVE_IZQ; }
"}"             { yylval.cadena = strdup(yytext); return LLAVE_DER; }
"["             { yylval.cadena = strdup(yytext); return CORCHETE_IZQ; }
"]"             { yylval.cadena = strdup(yytext); return CORCHETE_DER; }

    /* Literales */
{ENTERO}        { yylval.cadena = strdup(yytext); return ENTERO; }
{REAL}          { yylval.cadena = strdup(yytext); return REAL; }
{CADENA}        { yylval.cadena = strdup(yytext); return CADENA; }

    /* Identificadores */
{ID}            { yylval.cadena = strdup(yytext); return IDENTIFICADOR; }

    /* Comentarios */
{COMENTARIO}    { yylval.cadena = strdup(yytext); return COMENTARIO; }

    /* Espacios en blanco */
{ESPACIO}       { /* Ignorar espacios */ }

    /* Nueva línea */
\n              { /* FLEX maneja yylineno automáticamente */ }

    /* Error léxico */
.               { yylval.cadena = strdup(yytext); return ERROR_LEXICO; }

%%
