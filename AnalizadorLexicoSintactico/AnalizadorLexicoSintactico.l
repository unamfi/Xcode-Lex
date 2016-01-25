%{
    
    /*
     
     UNIVERSIDAD NACIONAL AUTÓNOMA DE MÉXICO
     FACULTAD DE INGENIERÍA
     
     ELABORÓ: GUZMÁN VILLANUEVA JULIO CÉSAR
     
     
     OBJETIVO
     Construir en un mismo programa, los analizadores Léxico y Sintáctico Decesendente que 
     revisen programas fuente escritos con directvas al preprocesador de C, definido por la 
     gramatica elaborada en clase.
     
     |CLASE| DESCRIPCION                             |
     |0    | Identificadores                         |
     |1    | Constantes enteras decimales            |
     |2    | Cadenas (delimitadas con @)             |
     |3    | Palabras reservadas (iniciadas con #)   |
     |4    | Simbolos especiales                     |
     |5    | Constante enteras octales				 |
     |6    | Secuencia                               |
     |7    | Constantes enteras hexadecimales		 |
     |8    | Operadores relacionales				 |
    
     */
    
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
    
#define MAXIMA_LONGITUD_DE_CAMPO 3000
#define TAMANO_MAXIMO_DE_CADENA_DE_ATOMOS 3000
#define FIN_DE_CADENA '|'
    
    FILE *archivo_tokens;
    FILE *tabla_simbolos;
    FILE *tabla_palabras_reservadas;
    FILE *tabla_simbolos_especiales;
    FILE *tabla_cadenas;
    FILE *tabla_secuencias;
    FILE *tabla_operadores_relacionales;
    FILE *archivo_cadena_de_atomos;
    
    int linea = 1;
    int indice_de_tabla_simbolos = -1;
    int indice_de_tabla_palabras_reservadas = -1;
    int indice_de_tabla_cadenas = -1;
    int indice_de_tabla_secuencias = -1;
    int indice_de_tabla_operadores_relacionales = -1;
    
    // Archivos
    void creaArchivos();
    void crea_archivo_tokens();
    void crea_tabla_simbolos();
    void crea_tabla_palabras_reservadas();
    void crea_tabla_simbolos_especiales();
    void crea_tabla_cadenas();
    void crea_tabla_secuencias();
    void crea_tabla_operadores_relacionales();
    void crea_cadena_de_atomos();
    void cierraArchivos();
    
    // Manejo de tablas
    void insert(FILE *file, char* filename , char* campo1, char* campo2, char* campo3, int esToken);  //Uso para tablas de 2 o 3 campos
    char* select_campo1(/* FROM */ FILE *file, char* filename , /* WHERE CAMPO2 = */ char* campo2 );  //Uso para tablas de 2 o 3 campos
    
    // Manejo de cadenas
    void removeSubstring(char *s,const char *toremove);
    
    // Analisis lexico
    int bandera_de_error_lexico = 0;
    
    // Manejo de clases
    void salto_de_linea();
    void identificador(char identificador[]);
    void constante_entera_decimal(char constante_entera_decimal[]);
    void cadena(char cadena[]);
    void palabra_reservada(char palabra_reservada[]);
    void simbolo_especial(char simbolo_especial[]);
    void constante_entera_octal(char constante_entera_octal[]);
    void secuencia(char secuencia[]);
    void constante_entera_hexadecimal(char constante_entera_hexadecimal[]);
    void operador_relacional(char operador_relacional[]);
    void error_lexico(char error_lexico[]);
    
    // Analisis sintactico
    
    void analisis_sintactico();
    
    char cadena_de_atomos[TAMANO_MAXIMO_DE_CADENA_DE_ATOMOS];
    char atomo;
    int indice_de_caracter_de_cadena_de_atomos = -1;
    
    
    int* R(int *bandera_de_error_sintactico);
    int* W(int *bandera_de_error_sintactico);
    int* X(int *bandera_de_error_sintactico);
    int* P(int *bandera_de_error_sintactico);
    int* D(int *bandera_de_error_sintactico);
    int* F(int *bandera_de_error_sintactico);
    int* B(int *bandera_de_error_sintactico);
    int* E(int *bandera_de_error_sintactico);
    int* U(int *bandera_de_error_sintactico);
    int* N(int *bandera_de_error_sintactico);
    int* I(int *bandera_de_error_sintactico);
    int* L(int *bandera_de_error_sintactico);
    int* C(int *bandera_de_error_sintactico);
    int* M(int *bandera_de_error_sintactico);
    int* K(int *bandera_de_error_sintactico);
    int* Q(int *bandera_de_error_sintactico);
    int* O(int *bandera_de_error_sintactico);
    int* S(int *bandera_de_error_sintactico);
    
    char getch();
    int* error_sintactico(int *bandera_de_error_sintactico);
    
%}

salto_de_linea                 [\n]
delimitador                    [\t]|[" "]*
digito                         [0-9]
cero                           [0]
digito_uno_al_nueve            [1-9]
digito_uno_al_siete            [1-7]
letra_minuscula                [a-z]
letra_mayuscula                [A-Z]
letra                          {letra_minuscula}|{letra_mayuscula}
guion_bajo                     [_]
arroba                         [@]
no_es_arroba_ni_salto_de_linea [^@]|\\n
cadena                         {arroba}{no_es_arroba_ni_salto_de_linea}*{arroba}
identificador                  ({letra}|{guion_bajo})({letra}|{digito}|{guion_bajo})*
constante_entera_decimal       {cero}|({digito_uno_al_nueve}({digito_uno_al_nueve}|{cero})*)
palabra_reservada              [#]("define"|"ifdef"|"if"|"elif"|"else"|"endif"|"undef"|"ifndef")
simbolo_especial               [;,()!]
constante_entera_octal         {cero}({digito_uno_al_siete}|{cero})+
secuencia                      [;][^\n ]*
constante_entera_hexadecimal   {cero}([x]|[X])({digito_uno_al_nueve}|[a-f]|[A-F]|{cero})+
operador_relacional            \<|"<="|\>|">="|"=="|"!="
%%
{salto_de_linea}                    linea++;
{delimitador}
{identificador}                     identificador(yytext);
{constante_entera_decimal}          constante_entera_decimal(yytext);
{cadena}                            cadena(yytext);
{palabra_reservada}                 palabra_reservada(yytext);
{simbolo_especial}                  simbolo_especial(yytext);
{constante_entera_octal}            constante_entera_octal(yytext);
{secuencia}                         secuencia(yytext);
{constante_entera_hexadecimal}      constante_entera_hexadecimal(yytext);
{operador_relacional}               operador_relacional(yytext);
.                                   error_lexico(yytext);


%%

int main(int argc, char *argv[])
{
    
    //Crea archivos
    creaArchivos();
    
    //Leer archivo de entrada
        //Linea comentada. Descomentar antes de la entrega final.
    //yyin = fopen(argv[1],"r");
        yyin = fopen("/Users/Julio/Google Drive/Facultad de Ingeniería/Octavo Semestre/Compiladores/Programas/Analizador Léxico - Sintáctico/AnalizadorLexicoSintactico/AnalizadorLexicoSintactico/input.txt", "r");
    
    //Condición de error
    if(yyin==NULL)
    {
        printf("Error: No proporcionaste un archivo para analizar o no existe en la ruta.");
    }
    
    //Abrir archivos en modo lectura y escritura
    
    //Corre el analizador lexico de flex yylex
        //Durante el analisis sintáctico se forma la cadena de simbolos.
    yylex();
    
    //Agregar el fin de cadena a la cadena de atomos
    fprintf(archivo_cadena_de_atomos, "|");
    
    //Cierra archivos
    cierraArchivos();
    
    //Analisis sintáctico
    analisis_sintactico();
    
    
    //Imprime tabla de simbolos
    printf("==================================================\n");
    printf("\t\tTabla de simbolos\n");
    printf("==================================================\n");
    system("cat tabla_simbolos.txt");
    printf("==================================================\n");
    
    //Imprime tabla de cadenas
    printf("==================================================\n");
    printf("\t\tTabla de cadenas\n");
    printf("==================================================\n");
    system("cat tabla_cadenas.txt");
    printf("==================================================\n");
    
    //Imprime tabla de cadenas
    printf("==================================================\n");
    printf("\t\tTabla de secuencias\n");
    printf("==================================================\n");
    system("cat tabla_secuencias.txt");
    printf("==================================================\n");
    
    
    //Imprime tokens
    printf("==================================================\n");
    printf("\t\tTokens\n");
    printf("==================================================\n");
    system("cat tokens.txt");
    printf("==================================================\n");
    
    //Imprime cadena de atomos
    printf("==================================================\n");
    printf("\t\tCadena de atomos\n");
    printf("==================================================\n");
    system("cat cadena_de_atomos.txt");
    printf("\n==================================================\n");
    
    
}

int yywrap()
{
    return 1;
}

void creaArchivos()
{
    //Crea archivo de salida
    crea_archivo_tokens();
    
    //Crea tabla de simbolos
    crea_tabla_simbolos();
    
    //Crea tabla de palabras reservadas
    crea_tabla_palabras_reservadas();
    
    //Crea tabla de simbolos especiales
    crea_tabla_simbolos_especiales();
    
    //Crea tabla de cadenas
    crea_tabla_cadenas();
    
    //Crea tabla de secuencias
    crea_tabla_secuencias();
    
    //Crea tabla de operadores relacionales
    crea_tabla_operadores_relacionales();
    
    //Crea cadena de atomos
    crea_cadena_de_atomos();
    
}

void crea_archivo_tokens()
{
    archivo_tokens = fopen("tokens.txt","w");
}

void crea_tabla_simbolos()
{
    tabla_simbolos = fopen("tabla_simbolos.txt","w");
}

void crea_tabla_palabras_reservadas()
{
    tabla_palabras_reservadas = fopen("tabla_palabras_reservadas.txt","w");
    
    //Inserta a la tabla tuplas predefinidas
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "0","define","", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "1","ifdef", "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "2","if",    "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "3","elif",  "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "4","else",  "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "5","endif", "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "6","undef", "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "7","ifndef","", 0);
}

void crea_tabla_simbolos_especiales()
{
    tabla_simbolos_especiales = fopen("tabla_simbolos_especiales.txt","w");
    
    //Inserta a la tabla tuplas predefinidas
    insert(tabla_simbolos_especiales, "tabla_simbolos_especiales.txt", "0",";","", 0);
    insert(tabla_simbolos_especiales, "tabla_simbolos_especiales.txt", "1","(","", 0);
    insert(tabla_simbolos_especiales, "tabla_simbolos_especiales.txt", "2",")","", 0);
    insert(tabla_simbolos_especiales, "tabla_simbolos_especiales.txt", "3",",","", 0);
    insert(tabla_simbolos_especiales, "tabla_simbolos_especiales.txt", "4","!","", 0);

}

void crea_tabla_cadenas()
{
    tabla_cadenas = fopen("tabla_cadenas.txt","w");
}

void crea_tabla_secuencias()
{
    tabla_secuencias = fopen("tabla_secuencias.txt","w");
}

void crea_tabla_operadores_relacionales()
{
    tabla_operadores_relacionales = fopen("tabla_operadores_relacionales.txt","w");
    
    //Inserta a la tabla tuplas predefinidas
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "0","<", "", 0);
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "1","<=","", 0);
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "2",">", "", 0);
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "3",">=","", 0);
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "4","==","", 0);
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "5","!=","", 0);
}

void crea_cadena_de_atomos()
{
    archivo_cadena_de_atomos = fopen("cadena_de_atomos.txt", "w");
}

void cierraArchivos()
{
    fclose(archivo_tokens);
    fclose(tabla_simbolos);
    fclose(tabla_palabras_reservadas);
    fclose(tabla_simbolos_especiales);
    fclose(tabla_cadenas);
    fclose(tabla_secuencias);
    fclose(tabla_operadores_relacionales);
    fclose(archivo_cadena_de_atomos);
}

// Manejo de tablas

void insert(FILE *file, char* filename , char* campo1, char* campo2, char* campo3, int esToken)
{
    // Si no existe en la tabla se inserta
    if(esToken == 1 || select_campo1( file, filename, campo2) == NULL )
    {
        char *registro = (char *)malloc(sizeof(campo1) + sizeof(campo2) + sizeof(campo3));
        strcpy( registro, campo1);
        strcat( registro, "\t");
        strcat( registro, campo2);
        strcat( registro, "\t");
        strcat( registro, campo3);
        strcat( registro, "\n");
        fprintf( file, "%s", registro);
    }
}

char* select_campo1(/* FROM */ FILE *file, char* filename , /* WHERE CAMPO2 = */ char* campo2 )
{
    
    // Cerrar archivo
    fclose( file );
    
    // Abrir archivo en modo lectura
    file = fopen( filename , "r" );
    
    
    // Declaracion de variables para guardar los campos
    char *_campo1 = (char *) malloc(MAXIMA_LONGITUD_DE_CAMPO);
    char *_campo2 = (char *) malloc(MAXIMA_LONGITUD_DE_CAMPO);
    char *_campo3 = (char *) malloc(MAXIMA_LONGITUD_DE_CAMPO);
    
    // Ciclo while
    while( fscanf( file, "%200[^\t\n]\t%200[^\t\n]", _campo1, _campo2) >= 1)
        // Guarda campo1 y campo2 en _campo1 y _campo2
    {
        //Para hacer al ultimo campo opcional
        fgets( _campo3 , MAXIMA_LONGITUD_DE_CAMPO, file );                   // Se encarga del resto de la linea
        sscanf(_campo3, "\t%200[^\t]", _campo3);                             // Le quita el tabulador y guarda el campo3 en _campo3
        /*
         printf("ENTRO AL WHILE\n");
         printf("_campo1 = %s\n", _campo1);
         printf("_campo2 = %s\n", _campo2);
         printf("_campo3 = %s\n", _campo3);
         */
        if( strcmp( campo2, _campo2 ) == 0 )
        {
            return _campo1;
        }
    }
    if(feof(file))
    {
        //puts("EOF");
        //printf("No se encontró en la tabla el campo buscado");
        
    }
    else
    {
        puts("CAN NOT READ TABLE");
        printf("campo 2 = %s\n", _campo2);
        puts("");
    }
    
    
    // Cerrar arvhivo
    fclose(file);
    
    // Abrir archivo en modo escritura
    file = fopen(filename, "a+");
    
    return NULL;
    
}

// Manejo de cadenas

void removeSubstring(char *s,const char *toremove)
{
    while( (s = strstr( s, toremove ) ) )
        memmove( s, s + strlen(toremove) , 1 + strlen( s + strlen(toremove) ) );
}

// Analisis léxico

// Manejo de clases


void identificador(char identificador[])
{
    
    
    
    // Si no se encuentra la el identificador en la tabla de simbolos: se agrega cadena a la tabla de simbolos
    if( select_campo1( tabla_simbolos , "tabla_simbolos.txt" , identificador ) == NULL)
    {
        char string_de_indice_de_tabla_simbolos[20];
        indice_de_tabla_simbolos++;
        sprintf( string_de_indice_de_tabla_simbolos, "%d", indice_de_tabla_simbolos);
        insert( tabla_simbolos, "tabla_simbolos.txt" , string_de_indice_de_tabla_simbolos, identificador, "", 0);
    }
    
    // Se crea el token con la clase 0 y la posición en la tabla de simbolos
    char *posicion = select_campo1( tabla_simbolos , "tabla_simbolos.txt" , identificador );
    insert( archivo_tokens , "tokens.txt", "0", posicion, "", 1);
    
    //Agregar a cadena de atomos el atomo "a"
    fprintf(archivo_cadena_de_atomos,"a");
    
}

void constante_entera_decimal(char constante_entera_decimal[])
{
    // Se crea el token con clase 1 y valor en decimal
    insert(archivo_tokens, "tokens.txt" , "1", constante_entera_decimal, "", 1);
    
    //Agregar a cadena de atomos el atomo "k"
    fprintf(archivo_cadena_de_atomos,"k");
}

void cadena(char cadena[])
{
    
    removeSubstring( cadena , "\n" );
    // Si no se encuentra la cadena en la tabla de cadenas: se agrega cadena a la tabla de cadenas
    if( select_campo1( tabla_cadenas , "tabla_cadenas.txt" , cadena ) == NULL)
    {
        char string_de_indice_de_tabla_cadenas[20];
        indice_de_tabla_cadenas++;
        sprintf( string_de_indice_de_tabla_cadenas, "%d", indice_de_tabla_cadenas);
        insert( tabla_cadenas, "tabla_cadenas.txt" , string_de_indice_de_tabla_cadenas, cadena, "", 0);
    }
    
    // Se crea token con clase 2 y posicion en la tabla de cadenas
    char *posicion = select_campo1( tabla_cadenas , "tabla_cadenas.txt" , cadena );
    insert( archivo_tokens , "tokens.txt", "2", posicion, "", 1);
    
    //Agregar a cadena de atomos el atomo "c"
    fprintf(archivo_cadena_de_atomos,"c");
}

void palabra_reservada(char palabra_reservada[])
{
    // Guardar subcadena seguida del simbolo #
    sscanf(palabra_reservada, "#%s", palabra_reservada);
    
    // Si no se encuentra la cadena en la tabla de palabras reservada: se agrega cadena a la tabla de palabras reservadas
    if( select_campo1( tabla_palabras_reservadas , "tabla_palabras_reservadas.txt" , palabra_reservada ) == NULL)
    {
        char string_de_indice_de_tabla_palabras_reservadas[20];
        indice_de_tabla_palabras_reservadas++;
        sprintf( string_de_indice_de_tabla_palabras_reservadas, "%d", indice_de_tabla_palabras_reservadas);
        insert( tabla_palabras_reservadas, "tabla_palabras_reservadas.txt" , string_de_indice_de_tabla_palabras_reservadas, palabra_reservada, "", 0);
    }
    
    // Se crea token con clase 2 y posicion en la tabla de cadenas
    char *posicion = select_campo1( tabla_palabras_reservadas , "tabla_palabras_reservadas.txt" , palabra_reservada );
    insert( archivo_tokens , "tokens.txt", "3", posicion, "", 1);
    
    //Agregar a cadena de atomos el atomo dependiendo de la palabra reservada.
    if ((strncmp("define", palabra_reservada, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"d");
    }
    if ((strncmp("ifdef", palabra_reservada, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"f");
    }
    if ((strncmp("if", palabra_reservada, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"i");
    }
    if ((strncmp("elif", palabra_reservada, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"l");
    }
    if ((strncmp("else", palabra_reservada, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"e");
    }
    if ((strncmp("endif", palabra_reservada, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"t");
    }
    if ((strncmp("undef", palabra_reservada, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"u");
    }
    if ((strncmp("ifndef", palabra_reservada, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"n");
    }
}

void simbolo_especial(char simbolo_especial[])
{
    // Se crea el token con clase 4 y la posición en la tabla de simbolos especiales
    char *posicion = select_campo1( tabla_simbolos_especiales, "tabla_simbolos_especiales.txt" , simbolo_especial );
    insert(archivo_tokens, "tokens.txt" , "4", posicion, "", 1);
    
    //Agregar a cadena de atomos el atomo dependiendo de el simbolo especial
    if ((strncmp(";", simbolo_especial, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,";");
    }
    if ((strncmp("(", simbolo_especial, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"(");
    }
    if ((strncmp(")", simbolo_especial, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,")");
    }
    if ((strncmp(",", simbolo_especial, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,",");
    }
    if ((strncmp("!", simbolo_especial, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"!");
    }
}

void constante_entera_octal(char constante_entera_octal[])
{
    // Se crea el token con clase 5 y valor en decimal
    int value;
    char string_value[20];
    sscanf( constante_entera_octal, "%o", &value);
    sprintf( string_value, "%d", value);
    insert( archivo_tokens , "tokens.txt", "5", string_value , "", 1);
    
    //Agregar a cadena de atomos el atomo "o"
    fprintf(archivo_cadena_de_atomos,"o");
}

void secuencia(char secuencia[])
{
    // Si no se encuentra la cadena en la tabla de secuencias: se agrega cadena a la tabla de secuancias
    if( select_campo1( tabla_secuencias , "tabla_secuencias.txt" , secuencia ) == NULL)
    {
        char string_de_indice_de_tabla_secuencias[20];
        indice_de_tabla_secuencias++;
        sprintf( string_de_indice_de_tabla_secuencias, "%d", indice_de_tabla_secuencias);
        insert( tabla_secuencias, "tabla_secuencias.txt" , string_de_indice_de_tabla_secuencias, secuencia, "", 0);
    }
    
    // Se crea token con clase 2 y posicion en la tabla de cadenas
    char *posicion = select_campo1( tabla_secuencias , "tabla_secuencias.txt" , secuencia );
    insert( archivo_tokens , "tokens.txt", "6", posicion, "", 1);
    
    //Agregar a cadena de atomos el atomo "s"
    fprintf(archivo_cadena_de_atomos,"s"); 
}

void constante_entera_hexadecimal(char constante_entera_hexadecimal[])
{
    // Se crea el token con clase 7 y valor en decimal
    int value;
    char string_value[20];
    sscanf( constante_entera_hexadecimal, "0%[xX]%x", string_value , &value);
    sprintf( string_value, "%d", value);
    insert( archivo_tokens , "tokens.txt", "7", string_value , "", 1);
    
    //Agregar a cadena de atomos el atomo "h"
    fprintf(archivo_cadena_de_atomos,"h");
}

void operador_relacional(char operador_relacional[])
{
    // Se crea el token con clase 8 y la posición en la tabla de operadores relacionales
    char *posicion = select_campo1( tabla_operadores_relacionales, "tabla_operadores_relacionales.txt" , operador_relacional );
    insert(archivo_tokens, "tokens.txt" , "8", posicion, "", 1);
    
    //Agregar a cadena de atomos el atomo dependiendo del operador relacional
    if ((strncmp("<", operador_relacional, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"m");
    }
    if ((strncmp("<=", operador_relacional, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"g");
    }
    if ((strncmp(">", operador_relacional, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"y");
    }
    if ((strncmp(">=", operador_relacional, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"z");
    }
    if ((strncmp("==", operador_relacional, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"q");
    }
    if ((strncmp("!=", operador_relacional, -1) == 0)) {
        fprintf(archivo_cadena_de_atomos,"x");
    }
}

void error_lexico(char error_lexico[])
{
    printf("Error léxico en la linea %d\n Se encontró: %s\n", linea, yytext);
    bandera_de_error_lexico = 1;
}

// Analisis sintactico

void analisis_sintactico()
{
     
    //Abre el archivo_cadena_de_atomos. En modo lectura.
    archivo_cadena_de_atomos = fopen("cadena_de_atomos.txt", "r");
        
    //Guarda el contenido del archivo cadena de atomos en la cadena de atomos.
    fscanf(archivo_cadena_de_atomos,"%[^\n]", cadena_de_atomos);
        
    //Cierra el archivo cadena de atomos
    fclose(archivo_cadena_de_atomos);
    
    //Devuelve el primer caracter.
    getch();
    
    //Declaración de bandera de error sintactico.
    int booleano = 0;
    int *bandera_de_error_sintactico = &booleano;
    //Si no se produjeron errores durante el analisis léxico.
    if (bandera_de_error_lexico == 0) {
        //Inicia el análisis sintáctico.
        int *a = R(bandera_de_error_sintactico);
        //Se analizó correctamente.
        if (*a == 0) {
            printf("Analisis sintactico: ¡Cadena correcta!\n");
        }
        //Se analizó de manera incorrecta.
        if (*a == 1) {
            printf("Analisis sintactico: ¡Cadena incorrecta!\n");
        }
    }
}

// 1: R -> W    c.s. = { c d f u n i }
int* R(int *bandera_de_error_sintactico)
{
    if ( atomo == 'c' ||
         atomo == 'd' ||
         atomo == 'f' ||
         atomo == 'u' ||
         atomo == 'n' ||
         atomo == 'i' )
    {
        //printf("R -> W\n");
        W(bandera_de_error_sintactico);
    }
    else
    {
        printf("Error sintactico: Se esperaba una cadena, #define, #ifdef, #undef, #ifndef, #if. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

// 2: W -> cX   c.s. = { c }
// 3: W -> PX   c.s. = { d f u n i }
int* W(int *bandera_de_error_sintactico)
{
    if (atomo == 'c') {
        //printf("W -> cX\n");
        getch();
        X(bandera_de_error_sintactico);
    }
    else if ( atomo == 'd' ||
              atomo == 'f' ||
              atomo == 'u' ||
              atomo == 'n' ||
              atomo == 'i' )
    {
        //printf("W -> PX\n");
        P(bandera_de_error_sintactico);
        X(bandera_de_error_sintactico);
    }
    else 
    {
        printf("Error sintactico: Se esperaba una cadena #define, #ifdef, #undef, #ifndef, #if. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    
    }
    return bandera_de_error_sintactico;
}

///COMO HACER LA RECUPERACIÓN DE ERRORES
//si encuentro un error esas son las proposiciones que puede seguir reconociendo. buscar la siguiente directiva al preprocesador las que NO inician son el else el elif y el endif ... estas creo que si: { d f u n i }. no importa lo que haya en medio y tendria que regresar al simbolo especial de la gramatica. 
//DETALLES EN FOTOS!!!

//Fin de cadena en C implicita con \0

// 4: X -> cX   c.s. = { c }
// 5: X -> PX   c.s. = { d f u n i }
// 6: X -> €    c.s. = { -| }

int* X(int *bandera_de_error_sintactico)
{
    // 4: X -> cX   c.s. = { c }
    if( atomo == 'c')
    {
        //printf("X -> cX\n");
        atomo = getch();
        X(bandera_de_error_sintactico);
        return bandera_de_error_sintactico;
    }
    // 5: X -> PX   c.s. = { d f u n i }
    else if ( atomo == 'd' ||
              atomo == 'f' ||
              atomo == 'u' ||
              atomo == 'n' ||
              atomo == 'i' )
    {
        //printf("X -> PX\n");
        P(bandera_de_error_sintactico);
        X(bandera_de_error_sintactico);
        return bandera_de_error_sintactico;
    }
    // 6: X -> €    c.s. = { FIN DE CADENA }
    //else if(!strcmp(&atomo, "|"))
    else if (atomo == '|')
    {
        //printf("X -> €\n");
        return bandera_de_error_sintactico;
    }
    else
    {
         printf("Error sintactico: Se esperaba una cadena, #define, #ifdef, #undef, #ifndef, #if, o el fin de cadena. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);

    }
    return bandera_de_error_sintactico;
}

// 7: P -> D    c.s. = { d }
// 8: P -> F    c.s. = { f }
// 9: P -> U    c.s. = { u }
// 10: P -> N   c.s. = { n }
// 11: P -> I   c.s. = { i }
int* P(int *bandera_de_error_sintactico)
{
    if ( atomo == 'd')
    {
        //printf("P -> D\n");
        D(bandera_de_error_sintactico);
    }
    else if ( atomo == 'f')
    {
        //printf("P -> F\n");
        F(bandera_de_error_sintactico);
    }
    else if ( atomo == 'u')
    {
        //printf("P -> U\n");
        U(bandera_de_error_sintactico);
    }
    else if ( atomo == 'n')
    {
        //printf("P -> N\n");
        N(bandera_de_error_sintactico);
    }
    else if ( atomo == 'i')
    {
        //printf("P -> I\n");
        I(bandera_de_error_sintactico);
    }
    else
    {
        printf("Error sintactico: Se esperaba una #define, #ifdef, #undef, #ifndef, #if. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
        
    }
    return bandera_de_error_sintactico;
}

// 12: D -> daS     c.s. = { d }
int* D(int *bandera_de_error_sintactico)
{
    if ( atomo == 'd')
    {
        getch();
        if ( atomo == 'a')
        {
            //printf("D -> daS\n");
            getch();
            S(bandera_de_error_sintactico);
        }
        else
        {
            printf("Error sintactico: Se esperaba un identificador. Se encontró un %c\n", atomo);
            error_sintactico(bandera_de_error_sintactico);
        }
    }
    else
    {
        printf("Error sintactico: Se esperaba un #define. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

// 13: F -> faBEt   c.s. = { f }
int* F(int *bandera_de_error_sintactico)
{
    if ( atomo == 'f')
    {
        getch();
        if (atomo == 'a') {
            getch();
            B(bandera_de_error_sintactico);
            E(bandera_de_error_sintactico);
            if (atomo == 't') {
                //printf("F -> faBEt\n");
                getch();
            }
            else
            {
                printf("Error sintactico: Se esperaba un #endif. Se encontró un %c\n", atomo);
                error_sintactico(bandera_de_error_sintactico);
                }
        }
        else
        {
            printf("Error sintactico: Se esperaba un identificador. Se encontró un %c\n", atomo);
            error_sintactico(bandera_de_error_sintactico);
        }
    }
    else
    {
        printf("Error sintactico: Se esperaba un #endif. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

// 14: B -> PB      c.s. = { d f u n i }
// 15: B -> €       c.s. = { e t l }
// 16: B -> cB      c.s. = { c }
int* B(int *bandera_de_error_sintactico)
{
    if ( atomo == 'd' ||
         atomo == 'f' ||
         atomo == 'u' ||
         atomo == 'n' ||
         atomo == 'i' )
    {
        //printf("B -> PB\n");
        P(bandera_de_error_sintactico);
        B(bandera_de_error_sintactico);
        return bandera_de_error_sintactico;
    }
    else if ( atomo == 'e' ||
              atomo == 't' ||
              atomo == 'l' )
    {
        //printf("B -> €\n");
        return bandera_de_error_sintactico;
    }
    else if( atomo == 'c' )
    {
        //printf("B -> cB\n");
        getch();
        B(bandera_de_error_sintactico);
        return bandera_de_error_sintactico;
    }
    else
    {
        printf("Error sintactico: Se esperaba un #define, #ifdef, #undef, #ifndef, #if, #else, #endif, #elif, o cadena. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
        
    }
    return bandera_de_error_sintactico;
}

// 17: E -> eB      c.s. = { e }
// 18: E -> €       c.s. = { t }
int* E(int *bandera_de_error_sintactico)
{
    if ( atomo == 'e') {
        //printf("E -> eB\n");
        getch();
        B(bandera_de_error_sintactico);
    }
    else if( atomo == 't' )
    {
        //printf("E -> €\n");
        return bandera_de_error_sintactico;
    }
    else
    {
        printf("Error sintactico: Se esperaba un #else, #endif. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

// 19: U -> ua      c.s. = { u }
int* U(int *bandera_de_error_sintactico)
{
    if ( atomo == 'u' )
    {
        getch();
        if ( atomo == 'a') {
            //printf("U -> ua\n");
            getch();
        }
        else
        {
            error_sintactico(bandera_de_error_sintactico);
        }
    }
    else
    {
        printf("Error sintactico: Se esperaba un #undef, o un identificador. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
        
    }
    return bandera_de_error_sintactico;
    
}

// 20: N -> naBEt c.s. = { n }

int* N(int *bandera_de_error_sintactico)
{
    if(atomo == 'n')
    {
        atomo = getch();
        if( atomo == 'a')
        {
            getch();
        }
        else
        {
                printf("Error sintactico: Se esperaba un identificador. Se encontró un %c\n", atomo);
                error_sintactico(bandera_de_error_sintactico);
                return bandera_de_error_sintactico;
        }
        B(bandera_de_error_sintactico);
        E(bandera_de_error_sintactico);
        if(atomo == 't')
        {
            //printf("N -> naBEt\n");
            getch();
        }
        else
        {
            printf("Error sintactico: Se esperaba un #endif. Se encontró un %c\n", atomo);
            error_sintactico(bandera_de_error_sintactico);
        }
    }
    else
    {
        printf("Error sintactico: Se esperaba un #ifndef. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
     return bandera_de_error_sintactico;
}

// 21: I -> iCBLEt c.s. = { i }

int* I(int *bandera_de_error_sintactico)
{
    if(atomo == 'i')
    {
        //printf("I -> iCBLEt\n");
        getch();
        C(bandera_de_error_sintactico);
        B(bandera_de_error_sintactico);
        L(bandera_de_error_sintactico);
        E(bandera_de_error_sintactico);
        if(atomo == 't')
        {
            getch();
        }
        else
        {
            printf("Error sintactico: Se esperaba un #endif. Se encontró un %c\n", atomo);
            error_sintactico(bandera_de_error_sintactico);
        }
    }
    else 
    {
        printf("Error sintactico: Se esperaba un #if. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

// 22: L -> lCBL    c.s. = { l }
// 23: L -> €       c.s. = { t }
int* L(int *bandera_de_error_sintactico)
{
    if ( atomo == 'l') {
        //printf("L -> lCBL\n");
        getch();
        C(bandera_de_error_sintactico);
        B(bandera_de_error_sintactico);
        L(bandera_de_error_sintactico);
    }
    else if (atomo == 't')
    {
        //printf("L -> €\n");
        return bandera_de_error_sintactico;
    }
    else if (atomo == 'e')
    {
        return bandera_de_error_sintactico;
    }
    else
    {
        printf("Error sintactico: Se esperaba un #else, #endif, #elif. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

// 24: C -> (MQ)       c.s. = { ( }
int* C(int *bandera_de_error_sintactico)
{
    if ( atomo == '(')
    {
        //printf("C -> (MQ)\n");
        getch();
        M(bandera_de_error_sintactico);
        Q(bandera_de_error_sintactico);
        if (atomo == ')') {
            getch();
            return bandera_de_error_sintactico;
        }
        else
        {
            printf("Error sintactico: Se esperaba un ). Se encontró un %c\n", atomo);
            error_sintactico(bandera_de_error_sintactico);
        }
    }
    else
    {
        printf("Error sintactico: Se esperaba un (. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

// 25: M -> a       c.s. = { a }
// 26: M -> K       c.s. = { k o h }
int* M(int *bandera_de_error_sintactico)
{
    if (atomo == 'a') {
        //printf("M -> a\n");
        getch();
    }
    else if ( atomo == 'k' ||
              atomo == 'o' ||
              atomo == 'h' )
    {
        //printf("M -> K\n");
        K(bandera_de_error_sintactico);
    }
    else
    {
        printf("Error sintactico: Se esperaba un identificador, constante entera, octal, hexadecimal. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

// 27: K -> k       c.s. = { k }
// 28: K -> o       c.s. = { o }
// 29: K -> h       c.s. = { h }
int* K(int *bandera_de_error_sintactico)
{
    if (atomo == 'k') {
        //printf("K -> k\n");
        getch();
    }
    else if (atomo == 'o') {
        //printf("K -> o\n");
        getch();
    }
    else if (atomo == 'h') {
        //printf("K -> h\n");
        getch();
    }
    else
    {
        printf("Error sintactico: Se esperaba un identificador, constante entera, octal, hexadecimal. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

// 30: Q -> €       c.s. = { ) }
// 31: Q -> OM      c.s. = { m g y z q x }
int* Q(int *bandera_de_error_sintactico)
{
    if (atomo == ')') {
        //printf("Q -> €\n");
        return bandera_de_error_sintactico;
    }
    else if (atomo == 'm' ||
             atomo == 'g' ||
             atomo == 'y' ||
             atomo == 'z' ||
             atomo == 'q' ||
             atomo == 'x' ) {
        //printf("Q -> OM\n");
        O(bandera_de_error_sintactico);
        M(bandera_de_error_sintactico);
    }
    else 
    {
        printf("Error sintactico: Se esperaba un ), <, <=, >, >=, ==, !=. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

// 32: O -> m       c.s. = { m }
// 33: O -> g       c.s. = { g }
// 34: O -> y       c.s. = { y }
// 35: O -> z       c.s. = { z }
// 36: O -> q       c.s. = { q }
// 37: O -> x       c.s. = { x }
int* O(int *bandera_de_error_sintactico)
{
    if ( atomo == 'm')
    {
        //printf("O -> m\n");
        getch();
    }
    if ( atomo == 'g')
    {
        //printf("O -> g\n");
        getch();
    }
    if ( atomo == 'y')
    {
        //printf("O -> y\n");
        getch();
    }
    if ( atomo == 'z')
    {
        //printf("O -> z\n");
        getch();
    }
    if ( atomo == 'q')
    {
        //printf("O -> q\n");
        getch();
    }
    if ( atomo == 'x')
    {
        //printf("O -> x\n");
        getch();
    }
    if (atomo == 'a' || atomo == 'k' ) {
        return bandera_de_error_sintactico;
    }
    else
    {
        printf("Error sintactico: Se esperaba un <, <=, >, >=, ==, !=, identificador, o constante entera decimal. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

// 38: S -> K       c.s. = { k o h }
// 39: S -> s       c.s. = { s }
int* S(int *bandera_de_error_sintactico)
{
    if (atomo == 'k' ||
        atomo == 'o' ||
        atomo == 'h' )
    {
        //printf("S -> K\n");
        K(bandera_de_error_sintactico);
    }
    else if (atomo == 's') {
        //printf("S -> s\n");
        getch();
    }
    else 
    {
        printf("Error sintactico: Se esperaba una constante entera, decimal, octal o una secuencia. Se encontró un %c\n", atomo);
        error_sintactico(bandera_de_error_sintactico);
    }
    return bandera_de_error_sintactico;
}

char getch()
{
    indice_de_caracter_de_cadena_de_atomos++;
    //printf("\ncadena_de_atomos[%d] = %c\n", indice_de_caracter_de_cadena_de_atomos, cadena_de_atomos[indice_de_caracter_de_cadena_de_atomos]);
    atomo = cadena_de_atomos[indice_de_caracter_de_cadena_de_atomos];
    return cadena_de_atomos[indice_de_caracter_de_cadena_de_atomos];
}

int* error_sintactico(int *bandera_de_error_sintactico)
{
    *bandera_de_error_sintactico = 1;
    
     //Descartar simbolos hasta que se encuentre una palabra reservada o el fin de cadena.
        while (1) {
            //Si se encuentra alguno de estos atomos volver a comenzar el analisis sintáctico.
            if (atomo == 'd' ||
                atomo == 'f' ||
                atomo == 'u' ||
                atomo == 'n' ||
                atomo == 'i')
                break;
            //Si se encuentra el fin de cadena dejar de buscar.
            if (atomo == '|' )
            {
                return bandera_de_error_sintactico;
            }
            getch();
        }
    
    //Declaración de nueva bandera de error
    int booleano = 0;
    int *_bandera_de_error_sintactico = &booleano;
    
    //Llamada al simbolo inicial.
    R(_bandera_de_error_sintactico);
    
    return bandera_de_error_sintactico;
}