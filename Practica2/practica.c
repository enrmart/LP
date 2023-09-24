#include <stdlib.h> 
#include "lex.yy.c"

//Practica Realizada por
//Francisco Cura Martin
//Carlos Garcia Miguel
//Enrique Martin Calvo

int preanalisis;

void parea (int token) {
	if (preanalisis == token) {
		preanalisis = yylex();
	}else if (preanalisis!=0 && preanalisis!=token ) {
		//Modo Panico 
		printf ("Linea %d,Componente léxico inesperado en %s\n", yylineno,yytext);
		preanalisis=yylex();
		parea(token);
	}else if (preanalisis==0 && preanalisis!=token){
		//Indica el final del analisis por llegar al final del fichero  
        printf("Se alcanzó el fin de archivo. Análisis sintáctico fallido.\n");
        exit(EXIT_FAILURE);
    }
}


void sign_opt(){
	if(preanalisis==SIGNL){
		parea(SIGNL);
		parea(IDENT);
	}else if(preanalisis==IDENT){
		parea(IDENT);
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba SIGNL o IDENT y recibió %s\n ", yylineno,yytext);
		parea(preanalisis);
		sign_opt();
	}
}

void on_off(){
	if(preanalisis==ON){
		parea(ON);
	}else if(preanalisis==OFF){
		parea(OFF);
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba ON u OFF y recibió %s\n ", yylineno,yytext);
		parea(preanalisis);
		on_off();
	}
}

void until_while(){
	if(preanalisis==UNTIL){
		parea(UNTIL);
	}else if(preanalisis==WHILE){
		parea(WHILE);
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba UNTIL o WHILE y recibió %s\n ",yylineno,yytext);	
		parea(preanalisis);
		until_while();
	}
}

void command(){
	if(preanalisis==WAIT){
		parea(WAIT);
		until_while();
		sign_opt();
	}else if(preanalisis==START){
		parea(START);
		parea(IDENT);
		parea(INT);
	}else if(preanalisis==STOP){
		parea(STOP);
		parea(IDENT);
	}else if(preanalisis==SET){
		parea(SET);
		on_off();
		parea(IDENT);
	}else if(preanalisis==PRINT){
		parea(PRINT);
		parea(CADENA);
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba WAIT o START o STOP o SET o PRINT y recibió %s\n ",yylineno, yytext);
		parea(preanalisis);
		command();
	}
}


void proc_body2(){
	if(preanalisis==','){
		parea(',');
		command();
		proc_body2();
	}else if(preanalisis==';'){
		//No hacemos nada porque es el epsilon
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba , o Epsilon y recibió %s\n ",yylineno,yytext);
		parea(preanalisis);
		proc_body2();
	}
}

void proc_body(){
	if(preanalisis==WAIT || preanalisis==START ||preanalisis==STOP|| preanalisis==SET || preanalisis==PRINT){
		command();
		proc_body2();
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba WAIT o START o STOP o SET o PRINT y recibió %s\n ",yylineno, yytext);
		parea(preanalisis);
		proc_body();
	}
}


void proc_head(){
	if(preanalisis==PROCEDURE){
		parea(PROCEDURE);
		parea(IDENT);
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba PROCEDURE y recibió %s\n ", yylineno,yytext);
		parea(preanalisis);
		proc_head();
	}
}


void proc(){
	if(preanalisis==PROCEDURE){
		proc_head();
		proc_body();
		parea(';');
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba PROCEDURE y recibió %s\n ", yylineno,yytext);
		parea(preanalisis);
		proc();
	}
}


void proc_lst(){
	if (preanalisis == PROCEDURE ) {
		proc();
		proc_lst();
	}else if(preanalisis==RUN){
		//No se hace nada porque es el epsilon 
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba PROCEDURE o RUN y recibió %s\n ", yylineno,yytext);
		parea(preanalisis);
		proc_lst();
	}
}



void body_command(){
	if (preanalisis == RUN) {
		parea(RUN);
		parea(IDENT);
	}else if(preanalisis==WAIT || preanalisis==START ||preanalisis==STOP|| preanalisis==SET || preanalisis==PRINT ){
		command();
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba RUN o WAIT o START o STOP o SET o PRINT y recibió %s\n ",yylineno, yytext);
		parea(preanalisis);
		body_command();
	}
}

void body2(){
	if(preanalisis==','){
		parea(',');
		body_command();
		body2();
	}else if(preanalisis=='.'){
		//Caso epsilon no hacer nada 
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba , o epsilon y recibió %s\n ",yylineno,yytext);
		parea(preanalisis);
		body2();
	}
}


void body (){
	if (preanalisis == RUN) {
		body_command();
		body2();
	}else if(preanalisis==WAIT || preanalisis==START ||preanalisis==STOP|| preanalisis==SET || preanalisis==PRINT){
		body_command();
	}else{
		printf ("Linea %d,Componente lexico inesperado, esperaba RUN o WAIT o START o STOP o SET o PRINT y recibió %s\n ",yylineno, yytext);
		parea(preanalisis);
		body();
	}
}

void prog () {
	proc_lst();
	body();
	parea('.');
}

void main(){
	preanalisis = yylex();
	prog();
	printf ("OK\n");
}
