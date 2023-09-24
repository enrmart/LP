%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>


#define MENSAJE_ERROR "No ha sido posible reservar memoria\n"

//Estructuras de datos
typedef struct nodo {
    char* op;
    struct nodo *siguiente;
} Nodo;

//Variables 
int LOCP = 0, LOCC = 0, LOCW = 0;
int n1 = 0, n2 = 0, N1 = 0, N2 = 0;
int flagLin=0;

//Funciones y metodos 
Nodo *operadores=NULL;
Nodo *operandos=NULL;
void anadirAPalabra(Nodo **, char*);
bool enColeccion( Nodo**,char*);
int main(int, char**);
%}

letra [a-zA-Z]
digito [0-9]
digitos	{digito}+
fraccion [.]{digitos}
exponente [eE][+-]?{digitos}
id {letra}({letra}|{digito})*
punto_flotante {digitos}{fraccion}{exponente}?


palabra_clave int|short|long|double|float|boolean|byte|char|String
operador {palabra_clave}|"++"|"--"|"+"|"-"|"!"|"~"|"*"|"/"|"%"|"<"|">"|"<="|">="|"=="|"!="|"&"|"^"|"|"|"&&"|"||"|"?"|":"|"="|"+="|"-="|"*="|"/="|"%="|"&="|"^⁼"|"|="|","|"."|";"|"("|")"|"{"|"}"|"["|"]"

operando "null"|"true"|"false"|"abstract"|"continue"|"for"|"new"|"switch"|"assert"|"default"|"goto"|"package"|"synchronized"|"do"|"if"|"private"|"this"|"break"|"implements"|"protected"|"throw"|"else"|"import"|"public"|"throws"|"case"|"enum"|"instanceof"|"return"|"transient"|"catch"|"extends"|"try"|"final"|"interface"|"static"|"void"|"class"|"finally"|"strictfp"|"volatile"|"const"|"native"|"super"|"while"|{id}|{digitos}|{punto_flotante}|{letra}+

%x COMENTARIO_ML COMENTARIO_L

linea_blanco ^[ \t]*\n

%%
"/*"                    {BEGIN COMENTARIO_ML;flagLin=0;}						//Comentarios multilinea 
<COMENTARIO_ML>"*/"        LOCC++;BEGIN INITIAL;
<COMENTARIO_ML>\n          LOCC++;
<COMENTARIO_ML>.    		;
<COMENTARIO_ML>{operando}   ;
<COMENTARIO_ML>{operador}   ;

"//"                       {BEGIN COMENTARIO_L;LOCC++;flagLin=0;}			//Comentario una linea JAVA 
<COMENTARIO_L>\n            BEGIN INITIAL;
<COMENTARIO_L>.	            ;
<COMENTARIO_L>{operando}	;
<COMENTARIO_L>{operador}	;


{operador} {	
				if(strcmp(yytext, "(") == 0){				
				   if(enColeccion(&operadores,yytext) == false){
						anadirAPalabra(&operadores, yytext);
						n1++;
						anadirAPalabra(&operadores, ")");		//Se añade el par () entero 
                   		}
					N1++;
				}else if(strcmp(yytext, "{") == 0){			
                   		if(enColeccion(&operadores,yytext) == false){
					anadirAPalabra(&operadores, yytext);
					n1++;
                        		anadirAPalabra(&operadores, "}");		//Se añade el par {} entero 
					}
                    		N1++;
                		}else if(strcmp(yytext, "[") == 0){			
                    		if(enColeccion(&operadores,yytext) == false){
					anadirAPalabra(&operadores, yytext);
                        		n1++;
                        		anadirAPalabra(&operadores, "]");		//Se añade el par [] entero 
					}
                    		N1++;
                		}else{
				if(enColeccion(&operadores,yytext) == false){
					anadirAPalabra(&operadores,yytext);			
					n1++;
				} 
				
				if(strcmp(yytext,")")!= 0 && strcmp(yytext,"}") != 0 && strcmp(yytext,"]") != 0) //Si es el caso de alguno de los pares no hay que sumar mas en operadores encontrados
						N1++;
				}
				if(!flagLin){
					LOCP++;
					flagLin=1;
				}

				
			}

{operando} {	
				if(enColeccion(&operandos,yytext) == false){
					anadirAPalabra(&operandos,yytext);		//Añadimos el operando a su propia lista 
					n2++;		         	
				}
				N2++;	
				if(!flagLin){
					LOCP++;
					flagLin=1;
				}
			}


{linea_blanco} LOCW++;

\n {flagLin=0;}

%%

void anadirAPalabra(Nodo **inicio, char* palabra) {
    Nodo *nodo = (Nodo*) malloc(sizeof(Nodo));					//Creacion del nodo que se va annadir al la lista
    if (nodo == NULL) {
        printf(MENSAJE_ERROR);
        exit(-1);
    }
    nodo->op = (char*) malloc(yyleng);				//Creacion del Operando/Operador de la posicion de la lista 
    if (nodo->op == NULL) {
        printf(MENSAJE_ERROR);
        exit(-1);
    }
    strcpy(nodo->op, palabra);
    nodo->siguiente = NULL;

    if (*inicio == NULL) {
        *inicio = nodo;											//Si es el primer nodo se le considera el inicio
    } else {
        Nodo *actual = *inicio;
        while (actual->siguiente != NULL) {						//Se comprueba cual de los nodos esta libre para asignarle en la lista
            actual = actual->siguiente;
        }
        actual->siguiente = nodo;
    }
}

bool enColeccion(Nodo **inicio,char* palabra){
	
	Nodo *actual = *inicio;

	while(actual!=NULL){
		if(strcmp(actual->op,palabra) == 0){				//Se comprueba toda la lista para ver si el Operador/Operando se encuentra en la lista
			return true;
		}
		actual=actual->siguiente;
	}

	return false;
}

int main(int argc, char** argv){
	
	if(argc > 1){
		yyin = fopen(argv[1], "r");
	}
	else{
		printf("Formato: ./nombre-del-compilado nombre-del-fichero-a-leer.java\n");
		return 1;
	}
	yylex();
	printf("LOCP: %d, LOCC: %d, LOCW: %d \n", LOCP, LOCC, LOCW);
	
	float nPequena = n1 + n2;
	float nGrande = N1 + N2;
	float logBase2 = log2(nPequena);
	float volumen = nGrande * logBase2;
	float dificultad = n1/2.0;
	dificultad = dificultad * N2;
	dificultad = dificultad/n2;
	float esfuerzo = dificultad * volumen;
	
	printf("numero de operadores diferentes: %d, numero de operandos diferentes: %d, numero total de operadores: %d, numero total de operandos: %d, esfuerzo de Halstead: %f\n ", n1, n2, N1, N2, esfuerzo);	
	return 0;

}
