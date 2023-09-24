/**
 * @Author: Dušan Kolář
 * @Year:   2023
 * Copyright (c) 2023
 * Licence: GLP 3.0
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string.h>
#include <stdarg.h>

#include "cLexico.h"

#define KWLEN  12

static char fName[10240] = "";
static unsigned char wasE = 0;
static unsigned char exitOnE = 0;

char *keywords[KWLEN] = {
    "off",
    "on",
    "print",
    "procedure",
    "run",
    "set",
    "signal",
    "start",
    "stop",
    "until",
    "wait",
    "while",
};

unsigned keycodes[KWLEN] = {
   
    OFF,
    ON,
    PRINT,
    PROCEDURE,
    RUN,
    SET,
    SIGNL,
    START,
    STOP,
    UNTIL,
    WAIT,
    WHILE,
};

void prError(unsigned short lineno, char *format, ...) {
  va_list ap;

  wasE = 1;

  va_start(ap,format);
  fprintf(stderr,"%s (%u): ",fName,lineno);
  vfprintf(stderr,format,ap);
  fflush(stderr);
  va_end(ap);

  if (exitOnE) exit(1);
}
int yywrap(void) { return 1; }
%}

LETTER    ([_a-zA-Z])

DIGIT     ([0-9])
DIGITS    ({DIGIT}+)

STRING    (\"[^\"]*\")

IDENT     ({LETTER}({LETTER}|{DIGIT})*)

COMMA     ([,])
SEMIC     ([;])
DOT       ([\.])

WSPC      ([ \t\f\r])
WSPCS     ({WSPC}+)

LINESEP   ([\n])

%%

{WSPC}              ; /* nothing to do, white space */

{STRING}            {return CADENA;}

{IDENT}             {
                        unsigned i = 0;
                        int r=-1;

                        

                        while (i<KWLEN && r<0) {
                            if ((r=strcmp(keywords[i],yytext))==0) {
                                //printf("Keyword detected... %s [%u]{%s}\n",yytext,keycodes[i],keywords[i]);
                                return keycodes[i];
                            }
                            i++;
                        }

                        // printf("Identifier detected... %s\n",yytext);

                        //yyStr(yylval)=sdup(yytext);

                        return IDENT;
                    }

{LINESEP}           {
                        ++yylineno;
                    }

{DIGITS}            {
                        /*long int li;
                        sscanf(yytext,"%ld",&li);
                        yyInt(yylval) = li;
                        */
                        return INT;
                    }

{COMMA}             return yytext[0];

{SEMIC}             return yytext[0];

{DOT}               return yytext[0];

.                   {
                        prError(yylineno,"Unexpected character in input: %c [%d]\n",yytext[0],yytext[0],NULL);
                    }

%%

// no code here

/* -- EOF -- */
