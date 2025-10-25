%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Estructura para almacenar tokens */
typedef struct {
    char *tipo;
    char *lexema;
    int linea;
} Token;

Token tokens[1000];
int token_count = 0;
int linea_actual = 1;

void agregar_token(const char *tipo, const char *lexema) {
    tokens[token_count].tipo = strdup(tipo);
    tokens[token_count].lexema = strdup(lexema);
    tokens[token_count].linea = linea_actual;
    token_count++;
}

void escapar_json(const char *str) {
    while (*str) {
        switch (*str) {
            case '"':  printf("\\\""); break;
            case '\\': printf("\\\\"); break;
            case '\b': printf("\\b"); break;
            case '\f': printf("\\f"); break;
            case '\n': printf("\\n"); break;
            case '\r': printf("\\r"); break;
            case '\t': printf("\\t"); break;
            default:
                if (*str < 32) {
                    printf("\\u%04x", (unsigned char)*str);
                } else {
                    putchar(*str);
                }
        }
        str++;
    }
}

void imprimir_tokens() {
    printf("[\n");
    for (int i = 0; i < token_count; i++) {
        printf("  {\"tipo\": \"");
        escapar_json(tokens[i].tipo);
        printf("\", \"lexema\": \"");
        escapar_json(tokens[i].lexema);
        printf("\", \"linea\": %d}", tokens[i].linea);
        if (i < token_count - 1) printf(",");
        printf("\n");
    }
    printf("]\n");
}
%}

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
"if"            { agregar_token("PALABRA_RESERVADA", yytext); }
"else"          { agregar_token("PALABRA_RESERVADA", yytext); }
"while"         { agregar_token("PALABRA_RESERVADA", yytext); }
"for"           { agregar_token("PALABRA_RESERVADA", yytext); }
"do"            { agregar_token("PALABRA_RESERVADA", yytext); }
"break"         { agregar_token("PALABRA_RESERVADA", yytext); }
"continue"      { agregar_token("PALABRA_RESERVADA", yytext); }
"return"        { agregar_token("PALABRA_RESERVADA", yytext); }
"int"           { agregar_token("TIPO_DATO", yytext); }
"float"         { agregar_token("TIPO_DATO", yytext); }
"double"        { agregar_token("TIPO_DATO", yytext); }
"char"          { agregar_token("TIPO_DATO", yytext); }
"string"        { agregar_token("TIPO_DATO", yytext); }
"bool"          { agregar_token("TIPO_DATO", yytext); }
"void"          { agregar_token("TIPO_DATO", yytext); }
"true"          { agregar_token("BOOLEANO", yytext); }
"false"         { agregar_token("BOOLEANO", yytext); }
"class"         { agregar_token("PALABRA_RESERVADA", yytext); }
"public"        { agregar_token("MODIFICADOR", yytext); }
"private"       { agregar_token("MODIFICADOR", yytext); }
"protected"     { agregar_token("MODIFICADOR", yytext); }
"static"        { agregar_token("MODIFICADOR", yytext); }
"const"         { agregar_token("MODIFICADOR", yytext); }

    /* Operadores aritméticos */
"+"             { agregar_token("OPERADOR_ARITMETICO", yytext); }
"-"             { agregar_token("OPERADOR_ARITMETICO", yytext); }
"*"             { agregar_token("OPERADOR_ARITMETICO", yytext); }
"/"             { agregar_token("OPERADOR_ARITMETICO", yytext); }
"%"             { agregar_token("OPERADOR_ARITMETICO", yytext); }
"++"            { agregar_token("OPERADOR_ARITMETICO", yytext); }
"--"            { agregar_token("OPERADOR_ARITMETICO", yytext); }

    /* Operadores relacionales */
"=="            { agregar_token("OPERADOR_RELACIONAL", yytext); }
"!="            { agregar_token("OPERADOR_RELACIONAL", yytext); }
"<"             { agregar_token("OPERADOR_RELACIONAL", yytext); }
">"             { agregar_token("OPERADOR_RELACIONAL", yytext); }
"<="            { agregar_token("OPERADOR_RELACIONAL", yytext); }
">="            { agregar_token("OPERADOR_RELACIONAL", yytext); }

    /* Operadores lógicos */
"&&"            { agregar_token("OPERADOR_LOGICO", yytext); }
"||"            { agregar_token("OPERADOR_LOGICO", yytext); }
"!"             { agregar_token("OPERADOR_LOGICO", yytext); }

    /* Operador de asignación */
"="             { agregar_token("OPERADOR_ASIGNACION", yytext); }
"+="            { agregar_token("OPERADOR_ASIGNACION", yytext); }
"-="            { agregar_token("OPERADOR_ASIGNACION", yytext); }
"*="            { agregar_token("OPERADOR_ASIGNACION", yytext); }
"/="            { agregar_token("OPERADOR_ASIGNACION", yytext); }

    /* Delimitadores */
";"             { agregar_token("PUNTO_COMA", yytext); }
","             { agregar_token("COMA", yytext); }
"."             { agregar_token("PUNTO", yytext); }
":"             { agregar_token("DOS_PUNTOS", yytext); }

    /* Paréntesis, llaves y corchetes */
"("             { agregar_token("PARENTESIS_IZQ", yytext); }
")"             { agregar_token("PARENTESIS_DER", yytext); }
"{"             { agregar_token("LLAVE_IZQ", yytext); }
"}"             { agregar_token("LLAVE_DER", yytext); }
"["             { agregar_token("CORCHETE_IZQ", yytext); }
"]"             { agregar_token("CORCHETE_DER", yytext); }

    /* Literales */
{ENTERO}        { agregar_token("ENTERO", yytext); }
{REAL}          { agregar_token("REAL", yytext); }
{CADENA}        { agregar_token("CADENA", yytext); }

    /* Identificadores */
{ID}            { agregar_token("IDENTIFICADOR", yytext); }

    /* Comentarios */
{COMENTARIO}    { agregar_token("COMENTARIO", yytext); }

    /* Espacios en blanco */
{ESPACIO}       { /* Ignorar espacios */ }

    /* Nueva línea */
\n              { linea_actual++; }

    /* Error léxico */
.               { agregar_token("ERROR_LEXICO", yytext); }

%%

int yywrap() {
    return 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *archivo = fopen(argv[1], "r");
        if (!archivo) {
            fprintf(stderr, "Error: No se puede abrir el archivo %s\n", argv[1]);
            return 1;
        }
        yyin = archivo;
    }

    yylex();
    imprimir_tokens();

    if (argc > 1) {
        fclose(yyin);
    }

    return 0;
}
