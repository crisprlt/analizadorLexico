#ifndef SEMANTICO_H
#define SEMANTICO_H

#define MAX_SIMBOLOS 1000
#define MAX_ERRORES 100

/* Estructura para un símbolo en la tabla */
typedef struct {
    char *nombre;
    char *tipo;
    int linea;
    int usado;
} Simbolo;

/* Estructura para errores */
typedef struct {
    int linea;
    char *mensaje;
    char *tipo; // "sintactico" o "semantico"
} ErrorCompilacion;

/* Tabla de símbolos */
extern Simbolo tabla_simbolos[MAX_SIMBOLOS];
extern int num_simbolos;

/* Errores */
extern ErrorCompilacion errores[MAX_ERRORES];
extern int num_errores;

/* Funciones para manejo de símbolos */
void inicializar_tabla_simbolos();
int declarar_variable(const char *nombre, const char *tipo, int linea);
int variable_declarada(const char *nombre);
Simbolo* buscar_variable(const char *nombre);
void marcar_variable_usada(const char *nombre);

/* Funciones para manejo de tipos */
int tipos_compatibles(const char *tipo1, const char *tipo2);
char* inferir_tipo_aritmetico(const char *tipo1, const char *tipo2);

/* Funciones para manejo de errores */
void agregar_error_sintactico(int linea, const char *mensaje);
void agregar_error_semantico(int linea, const char *mensaje);

/* Función para imprimir resultado en JSON */
void imprimir_resultado_json();

#endif
