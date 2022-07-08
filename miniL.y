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
  /* put your types here */
int num_val;
char* id_val;
}

%error-verbose
%start prog_start
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE FOR DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET RETURN
%token <id_val> IDENT
%token <num_val> NUMBER
%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD

/* %left could have been paired like this: %left MULT DIV MODE ADD SUB*/

%locations 
/*^^^ wtf is this for/doing? */

/* %start program */

%%

prog_start: functions { printf("prog_start -> functions\n"); }
	| error {yyerrok; yyclearin;} 
	;

functions: /*empty*/{printf("functions -> epsilon\n");}
	| function functions {printf("functions -> function functions\n");}
	;

function: FUNCTION Ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("funtion -> FUNCTION Ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
	;

declarations: /*empty*/ {printf("declarations -> epsilon\n");}
	| declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declaration\n");}
	| declaration error {yyerrok;}
	;

declaration: identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
	| identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declatations -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER\n", $5);}
	;

identifiers: Ident {printf("identifiers -> Ident\n");}
	| Ident COMMA identifiers {printf("identifiers -> Ident COMMA identifiers\n");}
	;

Ident: IDENT {printf("Ident -> IDENT %s\n", $1);}
	;

statements: /*empty*/ {printf("statements -> epsilon\n");}
	| statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
	| statement error {yyerrok;}
	;

statement: var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
	| IF bool_expr THEN statements ENDIF {printf("statement -> IF bool_exp THEN statements ENDIF\n");}
	| IF bool_expr THEN statements ELSE statements ENDIF {printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF\n");}
	| WHILE bool_expr BEGINLOOP statements ENDLOOP {printf("statements -> WHILE bool_exp BEGINLOOP statements ENDLOOP\n");}
	| DO BEGINLOOP statements ENDLOOP WHILE bool_expr {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp\n");}
	| FOR var ASSIGN NUMBER SEMICOLON bool_expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP {printf("FOR var ASSIGN NUMBER %d SEMICOLON bool_exp SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP\n", $4);}
	| READ var {printf("statement -> READ var\n");}
	| WRITE var {printf("statement -> WRITE var\n");}
	| CONTINUE {printf("statement -> CONTINUE\n");}
	| RETURN expression {printf("statement -> RETURN expression\n");}
	;

bool_expr: relation_exprs {printf("bool_exp -> relation_exprs\n");}
	| bool_expr OR relation_exprs {printf("bool_exp -> bool_exp OR relation_exprs\n");}
	;

relation_exprs:	relation_expr
	      	{printf("relation_exprs -> relation_expr\n");}
		| relation_exprs AND relation_expr {printf("relation_exprs -> relation_expres AND relation_expr\n");}
		;

relation_expr:	NOT ece {printf("relation_expr -> NOT ece\n");}
		| ece {printf("relation_expr -> ece\n");}
		| TRUE {printf("relation_expr -> TRUE\n");}
		| FALSE {printf("relation_expr -> FALSE\n");}
		| L_PAREN bool_expr R_PAREN {printf("relation_expr -> LPAREN bool_exp RPAREN\n");}
		;

ece:		expression comp expression {printf("ece -> expression comp expression\n");}
		;

comp:		EQ {printf("comp -> EQ\n");}
		| NEQ {printf("comp -> NEQ\n");}
		| LT {printf("comp -> LT\n");}
		| GT {printf("comp -> GT\n");}
		| LTE {printf("comp -> LTE\n");}
		| GTE {printf("comp -> GTE\n");}
		;

expression:	multi_expr addSubExpr {printf("expression -> multi_exp addSubExpr\n");}
		| error {yyerrok;}
		;

addSubExpr:	/*empty*/ {printf("addSubExpr -> epsilon\n");}
		| ADD expression {printf("addSubExpr -> ADD expression\n");}
		| SUB expression {printf("addSubExpr -> SUB expression\n");}
		;

multi_expr:	term {printf("multi_expr -> term\n");}
		| term MULT multi_expr {printf("multi_expr -> term MULT multi_expr\n");}
		| term DIV multi_expr {printf("multi_expr -> term DIV multi_expr\n");}
		| term MOD multi_expr {printf("multi_expr -> term MOD multi_expr\n");}
		;

term:		SUB var {printf("term -> SUB var\n");}
		| var {printf("term -> var\n");}
		| SUB NUMBER {printf("term -> SUB NUMBER %d\n", $2);}
		| NUMBER {printf("term -> NUMBER %d\n", $1);}
		| L_PAREN expression R_PAREN {printf("term -> L_PAREN expression RPAREN\n");}
		| Ident L_PAREN expression expressionLoop R_PAREN {printf("term -> Ident L_PAREN expression expressionLoop RPAREN\n");}
		;

expressionLoop:	/*empty*/
	      	{printf("expressionLoop -> epsilon\n");}
	      	| COMMA expression expressionLoop {printf("exprssionLoop -> COMMA expression expressionLoop\n");}
		;

var:		Ident {printf("var -> Ident\n");}
		| Ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> Ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET L_SQUARE_BRACKET expression R_SQUARE_BACKET\n");}
		| Ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> Ident L_SQSUARE_BRACKET expression R_SQUARE_BRACKET\n");}
		;



  /* write your rules here */

%% 

int main(int argc, char **argv) {
   if (argc > 1) {
	yyin = fopen(argv[1], "r");
	if (yyin == NULL) {
		printf("syntax: %s filename", argv[0]);
	}
   }
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */
	printf("Error: Line %d, position %d: %s \n", currLine, currPos, msg);
}
