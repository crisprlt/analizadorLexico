%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "semantico.h"

extern int yylex();
extern int yylineno;
extern char *yytext;
extern FILE *yyin;

void yyerror(const char *s);

int error_sintactico = 0;
int error_semantico = 0;
%}

%union {
    char *cadena;
    int entero;
    double real;
}

/* Tokens del léxico */
%token <cadena> IF ELSE WHILE FOR DO BREAK CONTINUE RETURN CLASS
%token <cadena> TIPO_DATO MODIFICADOR BOOLEANO
%token <cadena> OPERADOR_ARITMETICO OPERADOR_RELACIONAL OPERADOR_LOGICO OPERADOR_ASIGNACION
%token <cadena> PUNTO_COMA COMA PUNTO DOS_PUNTOS
%token <cadena> PARENTESIS_IZQ PARENTESIS_DER LLAVE_IZQ LLAVE_DER CORCHETE_IZQ CORCHETE_DER
%token <cadena> ENTERO REAL CADENA IDENTIFICADOR COMENTARIO ERROR_LEXICO

/* Tipos no terminales */
%type <cadena> tipo expresion termino factor literal

/* Precedencia de operadores (menor a mayor) */
%left OPERADOR_LOGICO
%left OPERADOR_RELACIONAL
%left '+' '-' OPERADOR_ARITMETICO
%left '*' '/' '%'
%right '!' OPERADOR_ASIGNACION

%%

/* Programa principal */
programa:
    /* vacío */
    | lista_declaraciones
    ;

lista_declaraciones:
    declaracion
    | lista_declaraciones declaracion
    ;

declaracion:
    declaracion_variable
    | declaracion_funcion
    | asignacion
    | estructura_control
    | expresion_statement
    | bloque
    | COMENTARIO
    | error PUNTO_COMA {
        error_sintactico = 1;
        agregar_error_sintactico(yylineno, "Error de sintaxis en declaración");
        yyerrok;
    }
    ;

/* Declaración de variables */
declaracion_variable:
    tipo IDENTIFICADOR PUNTO_COMA {
        if (!declarar_variable($2, $1, yylineno)) {
            error_semantico = 1;
            char msg[256];
            snprintf(msg, sizeof(msg), "Variable '%s' ya declarada", $2);
            agregar_error_semantico(yylineno, msg);
        }
    }
    | tipo IDENTIFICADOR OPERADOR_ASIGNACION expresion PUNTO_COMA {
        if (!declarar_variable($2, $1, yylineno)) {
            error_semantico = 1;
            char msg[256];
            snprintf(msg, sizeof(msg), "Variable '%s' ya declarada", $2);
            agregar_error_semantico(yylineno, msg);
        } else {
            // Verificar compatibilidad de tipos en la asignación
            Simbolo *var = buscar_variable($2);
            if (var && $4) {
                if (!tipos_compatibles(var->tipo, $4)) {
                    error_semantico = 1;
                    char msg[256];
                    snprintf(msg, sizeof(msg), "Tipos incompatibles en asignación: '%s' es tipo '%s'", $2, var->tipo);
                    agregar_error_semantico(yylineno, msg);
                }
            }
        }
    }
    | MODIFICADOR tipo IDENTIFICADOR PUNTO_COMA {
        if (!declarar_variable($3, $2, yylineno)) {
            error_semantico = 1;
            char msg[256];
            snprintf(msg, sizeof(msg), "Variable '%s' ya declarada", $3);
            agregar_error_semantico(yylineno, msg);
        }
    }
    | MODIFICADOR tipo IDENTIFICADOR OPERADOR_ASIGNACION expresion PUNTO_COMA {
        if (!declarar_variable($3, $2, yylineno)) {
            error_semantico = 1;
            char msg[256];
            snprintf(msg, sizeof(msg), "Variable '%s' ya declarada", $3);
            agregar_error_semantico(yylineno, msg);
        }
    }
    ;

/* Tipos de datos */
tipo:
    TIPO_DATO { $$ = $1; }
    ;

/* Asignación */
asignacion:
    IDENTIFICADOR OPERADOR_ASIGNACION expresion PUNTO_COMA {
        if (!variable_declarada($1)) {
            error_semantico = 1;
            char msg[256];
            snprintf(msg, sizeof(msg), "Variable '%s' no declarada", $1);
            agregar_error_semantico(yylineno, msg);
        } else {
            // Verificar tipos
            Simbolo *var = buscar_variable($1);
            if (var && $3) {
                if (!tipos_compatibles(var->tipo, $3)) {
                    error_semantico = 1;
                    char msg[256];
                    snprintf(msg, sizeof(msg), "Tipos incompatibles: no se puede asignar tipo '%s' a variable '%s' de tipo '%s'", $3, $1, var->tipo);
                    agregar_error_semantico(yylineno, msg);
                }
            }
        }
    }
    ;

/* Expresiones */
expresion:
    termino { $$ = $1; }
    | expresion OPERADOR_ARITMETICO termino {
        $$ = inferir_tipo_aritmetico($1, $3);
    }
    | expresion OPERADOR_RELACIONAL termino {
        $$ = strdup("bool");
    }
    | expresion OPERADOR_LOGICO termino {
        $$ = strdup("bool");
    }
    | OPERADOR_LOGICO expresion {
        $$ = strdup("bool");
    }
    ;

termino:
    factor { $$ = $1; }
    | termino OPERADOR_ARITMETICO factor {
        $$ = inferir_tipo_aritmetico($1, $3);
    }
    ;

factor:
    literal { $$ = $1; }
    | IDENTIFICADOR {
        if (!variable_declarada($1)) {
            error_semantico = 1;
            char msg[256];
            snprintf(msg, sizeof(msg), "Variable '%s' no declarada", $1);
            agregar_error_semantico(yylineno, msg);
            $$ = NULL;
        } else {
            Simbolo *var = buscar_variable($1);
            $$ = var ? strdup(var->tipo) : NULL;
        }
    }
    | PARENTESIS_IZQ expresion PARENTESIS_DER { $$ = $2; }
    ;

literal:
    ENTERO { $$ = strdup("int"); }
    | REAL { $$ = strdup("float"); }
    | CADENA { $$ = strdup("string"); }
    | BOOLEANO { $$ = strdup("bool"); }
    ;

/* Estructuras de control */
estructura_control:
    if_statement
    | while_statement
    | for_statement
    | do_while_statement
    | return_statement
    | break_statement
    | continue_statement
    ;

if_statement:
    IF PARENTESIS_IZQ expresion PARENTESIS_DER bloque
    | IF PARENTESIS_IZQ expresion PARENTESIS_DER bloque ELSE bloque
    ;

while_statement:
    WHILE PARENTESIS_IZQ expresion PARENTESIS_DER bloque
    ;

do_while_statement:
    DO bloque WHILE PARENTESIS_IZQ expresion PARENTESIS_DER PUNTO_COMA
    ;

for_statement:
    FOR PARENTESIS_IZQ for_init PUNTO_COMA expresion PUNTO_COMA for_update PARENTESIS_DER bloque
    ;

for_init:
    /* vacío */
    | tipo IDENTIFICADOR OPERADOR_ASIGNACION expresion {
        if (!declarar_variable($2, $1, yylineno)) {
            error_semantico = 1;
            char msg[256];
            snprintf(msg, sizeof(msg), "Variable '%s' ya declarada", $2);
            agregar_error_semantico(yylineno, msg);
        }
    }
    | IDENTIFICADOR OPERADOR_ASIGNACION expresion {
        if (!variable_declarada($1)) {
            error_semantico = 1;
            char msg[256];
            snprintf(msg, sizeof(msg), "Variable '%s' no declarada", $1);
            agregar_error_semantico(yylineno, msg);
        }
    }
    ;

for_update:
    /* vacío */
    | IDENTIFICADOR OPERADOR_ASIGNACION expresion {
        if (!variable_declarada($1)) {
            error_semantico = 1;
            char msg[256];
            snprintf(msg, sizeof(msg), "Variable '%s' no declarada", $1);
            agregar_error_semantico(yylineno, msg);
        }
    }
    ;

return_statement:
    RETURN PUNTO_COMA
    | RETURN expresion PUNTO_COMA
    ;

break_statement:
    BREAK PUNTO_COMA
    ;

continue_statement:
    CONTINUE PUNTO_COMA
    ;

/* Declaración de funciones */
declaracion_funcion:
    tipo IDENTIFICADOR PARENTESIS_IZQ parametros PARENTESIS_DER bloque
    | tipo IDENTIFICADOR PARENTESIS_IZQ PARENTESIS_DER bloque
    ;

parametros:
    tipo IDENTIFICADOR
    | parametros COMA tipo IDENTIFICADOR
    ;

/* Bloques de código */
bloque:
    LLAVE_IZQ lista_declaraciones LLAVE_DER
    | LLAVE_IZQ LLAVE_DER
    ;

/* Expresiones como sentencias */
expresion_statement:
    expresion PUNTO_COMA
    ;

%%

void yyerror(const char *s) {
    error_sintactico = 1;
    agregar_error_sintactico(yylineno, s);
}

int main(int argc, char **argv) {
    inicializar_tabla_simbolos();

    if (argc > 1) {
        FILE *archivo = fopen(argv[1], "r");
        if (!archivo) {
            fprintf(stderr, "{\"error\": \"No se puede abrir el archivo %s\"}\n", argv[1]);
            return 1;
        }
        yyin = archivo;
    }

    yyparse();

    // Generar salida JSON
    imprimir_resultado_json();

    if (argc > 1) {
        fclose(yyin);
    }

    return (error_sintactico || error_semantico) ? 1 : 0;
}
