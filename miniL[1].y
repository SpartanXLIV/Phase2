    /* cs152-miniL phase2 */
%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char *msg);
extern int currLine;
extern int currPos;
FILE * yyin;
%}

%union{
int num_val;
char* id_val;

}

%error-verbose
%start prog_start
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE FOR DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET RETURN
%token ENUM
%token <id_val> IDENT
%token <num_val> NUMBER
%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD


/* %start program */

%% 

prog_start: functions { printf("prog_start -> functions \n"); }
        ;  

functions:  /*empty*/{printf("functions -> epsilon\n"); }
        | function functions {printf("functions -> function functions\n"); }
        ;

function:       FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
        ;

declarations: /*empty*/ {printf("declarations -> epsilon\n"); }
        | declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON\n");}
        ;

declaration:    identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
        | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER\n", $5);}
        | identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN");}
        ;

identifiers:    ident {printf("identifiers -> ident\n");}
        | ident COMMA identifiers {printf("identifiers -> ident COMMA identifiers\n");}
        ;

ident:  IDENT {printf("ident -> IDENT %s \n", $1);}
        ;

statements:     /*empty*/ {printf("statements -> epsilon\n");}
        | statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
        ;

statement:      var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
        | IF bool_exp THEN statements ENDIF {printf("statement -> IF bool_exp THEN statements ENDIF\n");}
        | IF bool_exp THEN statements ELSE statements ENDIF {printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF");}
        | WHILE bool_exp BEGINLOOP statements ENDLOOP {printf("statement-> WHILE bool_exp BEGINLOOP statements ENDLOOP\n");}
        | DO BEGINLOOP statements ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp\n");}
        | FOR var varLoop ASSIGN NUMBER SEMICOLON bool_exp SEMICOLON var varLoop ASSIGN expression BEGINLOOP statements ENDLOOP {printf(" FOR vars ASSIGN NUMBER SEMICOLON bool_exp SEMICOLON vars ASSIGN expression BEGINLOOP statements ENDLOOP\n");}
        | READ var varLoop {printf("statement -> READ vars\n");}
        | WRITE var varLoop {printf("statement -> WRITE vars\n");}
        | CONTINUE {printf("statement -> CONTINUE\n");}
        | RETURN expression {printf("statement -> RETURN expression\n");}
        ;

bool_exp:       relation_and_exp {printf("bool_exp -> relation_and_exp\n");}
        | relation_and_exp OR bool_exp {printf("bool_exp -> relation_and_exp OR bool_exp\n");}
        ;

relation_and_exp:       relation_exp {printf("relation_and_exp -> relation_exp\n");}
        | relation_exp AND relation_and_exp {printf("relation_and_exp -> relation_exp AND relation_and_exp\n");}
        ;

relation_exp:   expression comp expression {printf("relation_exp -> expression comp expression\n");}
        | TRUE {printf("relation_exp -> TRUE\n");}
        | FALSE {printf("relation_exp -> FALSE\n");}
        | L_PAREN bool_exp R_PAREN {printf("relation_exp -> L_PAREN bool_exp R_PAREN\n");}
        | NOT expression comp  expression {printf("relation_exp -> NOT expression comp expression\n");}
        | NOT TRUE {printf("relation_exp -> NOT TRUE\n");}
        | NOT FALSE {printf("relation_exp -> NOT FALSE\n");}
        | NOT L_PAREN bool_exp R_PAREN {printf("relation_exp -> NOT L_PAREN bool_exp R_PARENT\n");}
        ;

comp:           EQ {printf("comp -> EQ\n");}
        | NEQ {printf("comp -> NEQ\n");}
        | LT {printf("comp -> LT\n");}
        | GT {printf("comp -> GT\n");}
        | LTE {printf("comp -> LTE\n");}
        | GTE {printf("comp -> GTE\n");}
        ;

expression:     mult_exp {printf("expression -> mult_exp\n");}
        | mult_exp ADD expression {printf("expression -> mult_exp ADD expression\n");}
        | mult_exp SUB expression {printf("expression -> mult_exp SUB expression\n");}
        ;

mult_exp: term {printf("mult_exp -> term\n");}
        | term MULT mult_exp {printf("mult_exp -> term MULT mult_exp\n");}
        | term DIV mult_exp {printf("mult_exp -> term DIV mult_exp\n");}
        | term MOD mult_exp {printf("mult_exp -> term MOD mult_exp\n");}
        ;

term:   var {printf("term -> var\n");}
        | NUMBER {printf("term -> NUMBER %d\n", $1);}
        | L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
        | SUB var {printf("term -> SUB var\n");}
        | SUB NUMBER {printf("term -> SUB NUMBER %d\n", $2);}
        | SUB L_PAREN expression R_PAREN {printf("term -> SUB L_PAREN expression R_PAREN\n");}
        | ident L_PAREN expressions R_PAREN {printf("term -> ident L_PAREN expressions R_PAREN\n");}
        ;

var:    ident {printf("var -> ident\n");}
        | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
        ;

varLoop:           /*empty*/ {printf("vars -> epsilon\n");}
        | COMMA var varLoop {printf("vars -> var COMMA vars\n");}
        ;

expressions:    /*empty*/ {printf("expressions -> epsilon\n");}
        | expression COMMA expressions {printf("expressions -> expression COMMA expressions\n");}
        ;



%% 

int main(int argc, char **argv) {
   if(argc > 1)
   {
        yyin = fopen(argv[1], "r");
        if(yyin == NULL)
        {
                printf("syntax: %s filename", argv[0]);
        }
   }
   yyparse();
   return 0;
}

void yyerror(const char *msg) 
{
    /* implement your error handling */
    printf("Error: Line %d, position %d: %s \n", currLine, currPos, msg);
}