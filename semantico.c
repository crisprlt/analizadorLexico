#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "semantico.h"

/* Variables globales */
Simbolo tabla_simbolos[MAX_SIMBOLOS];
int num_simbolos = 0;

ErrorCompilacion errores[MAX_ERRORES];
int num_errores = 0;

/* Inicializar la tabla de símbolos */
void inicializar_tabla_simbolos() {
    num_simbolos = 0;
    num_errores = 0;
}

/* Declarar una variable en la tabla de símbolos */
int declarar_variable(const char *nombre, const char *tipo, int linea) {
    // Verificar si ya existe
    for (int i = 0; i < num_simbolos; i++) {
        if (strcmp(tabla_simbolos[i].nombre, nombre) == 0) {
            return 0; // Ya declarada
        }
    }

    // Agregar nuevo símbolo
    if (num_simbolos < MAX_SIMBOLOS) {
        tabla_simbolos[num_simbolos].nombre = strdup(nombre);
        tabla_simbolos[num_simbolos].tipo = strdup(tipo);
        tabla_simbolos[num_simbolos].linea = linea;
        tabla_simbolos[num_simbolos].usado = 0;
        num_simbolos++;
        return 1; // Éxito
    }

    return 0; // Tabla llena
}

/* Verificar si una variable está declarada */
int variable_declarada(const char *nombre) {
    for (int i = 0; i < num_simbolos; i++) {
        if (strcmp(tabla_simbolos[i].nombre, nombre) == 0) {
            return 1;
        }
    }
    return 0;
}

/* Buscar una variable en la tabla */
Simbolo* buscar_variable(const char *nombre) {
    for (int i = 0; i < num_simbolos; i++) {
        if (strcmp(tabla_simbolos[i].nombre, nombre) == 0) {
            return &tabla_simbolos[i];
        }
    }
    return NULL;
}

/* Marcar variable como usada */
void marcar_variable_usada(const char *nombre) {
    Simbolo *var = buscar_variable(nombre);
    if (var) {
        var->usado = 1;
    }
}

/* Verificar compatibilidad de tipos */
int tipos_compatibles(const char *tipo1, const char *tipo2) {
    if (!tipo1 || !tipo2) return 1; // Si alguno es NULL, asumimos compatible

    // Mismos tipos
    if (strcmp(tipo1, tipo2) == 0) return 1;

    // int y float son compatibles (con conversión implícita)
    if ((strcmp(tipo1, "int") == 0 && strcmp(tipo2, "float") == 0) ||
        (strcmp(tipo1, "float") == 0 && strcmp(tipo2, "int") == 0)) {
        return 1;
    }

    // int y double son compatibles
    if ((strcmp(tipo1, "int") == 0 && strcmp(tipo2, "double") == 0) ||
        (strcmp(tipo1, "double") == 0 && strcmp(tipo2, "int") == 0)) {
        return 1;
    }

    // float y double son compatibles
    if ((strcmp(tipo1, "float") == 0 && strcmp(tipo2, "double") == 0) ||
        (strcmp(tipo1, "double") == 0 && strcmp(tipo2, "float") == 0)) {
        return 1;
    }

    return 0; // Tipos incompatibles
}

/* Inferir tipo resultante de operación aritmética */
char* inferir_tipo_aritmetico(const char *tipo1, const char *tipo2) {
    if (!tipo1 || !tipo2) return strdup("int");

    // Si alguno es double, el resultado es double
    if (strcmp(tipo1, "double") == 0 || strcmp(tipo2, "double") == 0) {
        return strdup("double");
    }

    // Si alguno es float, el resultado es float
    if (strcmp(tipo1, "float") == 0 || strcmp(tipo2, "float") == 0) {
        return strdup("float");
    }

    // Por defecto, int
    return strdup("int");
}

/* Agregar error sintáctico */
void agregar_error_sintactico(int linea, const char *mensaje) {
    if (num_errores < MAX_ERRORES) {
        errores[num_errores].linea = linea;
        errores[num_errores].mensaje = strdup(mensaje);
        errores[num_errores].tipo = strdup("sintactico");
        num_errores++;
    }
}

/* Agregar error semántico */
void agregar_error_semantico(int linea, const char *mensaje) {
    if (num_errores < MAX_ERRORES) {
        errores[num_errores].linea = linea;
        errores[num_errores].mensaje = strdup(mensaje);
        errores[num_errores].tipo = strdup("semantico");
        num_errores++;
    }
}

/* Escapar caracteres especiales para JSON */
void escapar_json_string(const char *str) {
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

/* Imprimir resultado en formato JSON */
void imprimir_resultado_json() {
    printf("{\n");

    // Estado del análisis
    printf("  \"exito\": %s,\n", (num_errores == 0) ? "true" : "false");

    // Tabla de símbolos
    printf("  \"tabla_simbolos\": [\n");
    for (int i = 0; i < num_simbolos; i++) {
        printf("    {\n");
        printf("      \"nombre\": \"");
        escapar_json_string(tabla_simbolos[i].nombre);
        printf("\",\n");
        printf("      \"tipo\": \"");
        escapar_json_string(tabla_simbolos[i].tipo);
        printf("\",\n");
        printf("      \"linea\": %d,\n", tabla_simbolos[i].linea);
        printf("      \"usado\": %s\n", tabla_simbolos[i].usado ? "true" : "false");
        printf("    }%s\n", (i < num_simbolos - 1) ? "," : "");
    }
    printf("  ],\n");

    // Errores
    printf("  \"errores\": [\n");
    for (int i = 0; i < num_errores; i++) {
        printf("    {\n");
        printf("      \"tipo\": \"");
        escapar_json_string(errores[i].tipo);
        printf("\",\n");
        printf("      \"linea\": %d,\n", errores[i].linea);
        printf("      \"mensaje\": \"");
        escapar_json_string(errores[i].mensaje);
        printf("\"\n");
        printf("    }%s\n", (i < num_errores - 1) ? "," : "");
    }
    printf("  ],\n");

    // Estadísticas
    printf("  \"estadisticas\": {\n");
    printf("    \"variables_declaradas\": %d,\n", num_simbolos);
    printf("    \"errores_sintacticos\": %d,\n", num_errores);
    printf("    \"errores_semanticos\": %d\n", num_errores);
    printf("  }\n");

    printf("}\n");
}
