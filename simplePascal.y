%{
#include <stdio.h>
#include <stdlib.h>

int yylex();
int yyparse();
void yyerror (char const *);
%}

%token 	/* key-words */
		PROGRAM CONST TYPE ARRAY SET OF RECORD VAR FORWARD FUNCTION PROCEDURE
		INTEGER REAL BOOLEAN CHAR BEGINN END IF THEN ELSE WHILE DO FOR DOWNTO
		TO WITH READ WRITE
		
		/* identifiers */
		ID
		
		/* simple constants */
		ICONST RCONST BCONST CCONST
		
		/* operators */
		RELOP ADDOP OROP MULDIVANDOP NOTOP INOP
		
		/* strings */
		STRING
		
		/* other lexical units */
		LPAREN RPAREN SEMI DOT COMMA EQU COLON LBRACK RBRACK ASSIGN DOTDOT
		

%left COMMA SEMI
%right ASSIGN
%left OROP
%left ID FORWARD
%left MULDIVANDOP
%left EQU
%left RELOP
%left ADDOP
%left NOTOP
%left INOP
%left LPAREN RPAREN LBRACK RBRACK DOTDOT

%nonassoc THEN 
%nonassoc ELSE
%nonassoc COLON

%%

program	: header declarations subprograms comp_statement DOT
		;

header	: PROGRAM ID SEMI
		;

declarations: constdefs typedefs vardefs
			;

constdefs	: CONST constant_defs SEMI
			| /* nothing */
			;

constant_defs	: constant_defs SEMI ID EQU expression
				| ID EQU expression
				;

expression	: expression RELOP expression
			| expression EQU expression
			| expression INOP expression
			| expression OROP expression
			| expression ADDOP expression
			| expression MULDIVANDOP expression
			| ADDOP expression
			| NOTOP expression
			| variable
			| ID LPAREN expressions RPAREN
			| constant
			| LPAREN expression RPAREN
			| setexpression
			;

variable: ID
		| variable DOT ID
		| variable LBRACK expressions RBRACK
		;
			
expressions	: expressions COMMA expression
			| expression
			;

constant: ICONST
		| RCONST
		| BCONST
		| CCONST
		;

setexpression	: LBRACK elexpressions RBRACK
				| LBRACK RBRACK
				;

elexpressions	: elexpressions COMMA elexpression
				| elexpression
				;

elexpression: expression DOTDOT expression
			| expression
			;

typedefs: TYPE type_defs SEMI
		| /* nothing */
		;

type_defs	: type_defs SEMI ID EQU type_def
			| ID EQU type_def
			;

type_def: ARRAY LBRACK dims RBRACK OF typename
		| SET OF typename
		| RECORD fields END
		| LPAREN identifiers RPAREN
		| limit DOTDOT limit
		;

dims: dims COMMA limits
	| limits
	;

limits	: limit DOTDOT limit
		| ID
		;

limit	: ADDOP ICONST
		| ADDOP ID
		| ICONST
		| CCONST
		| BCONST
		| ID
		;

typename: standard_type
		| ID
		;

standard_type	: INTEGER
				| REAL
				| BOOLEAN
				| CHAR
				;

fields	: fields SEMI field
		| field
		;

field	: identifiers COLON typename
		;

identifiers	: identifiers COMMA ID
			| ID
			;

vardefs	: VAR variable_defs SEMI
		| /* nothing */
		;

variable_defs	: variable_defs SEMI identifiers COLON typename
				| identifiers COLON typename
				;

subprograms	: subprograms subprogram SEMI
			| /* nothing */
			;
			
subprogram	: sub_header SEMI FORWARD
			| sub_header SEMI declarations subprograms comp_statement
			;

sub_header	: FUNCTION ID formal_parameters COLON standard_type
			| PROCEDURE ID formal_parameters
			| FUNCTION ID
			;

formal_parameters	: LPAREN parameter_list RPAREN
					| /* nothing */
					;

parameter_list	: parameter_list SEMI pass identifiers COLON typename
				| pass identifiers COLON typename
				;

pass: VAR
	| /* nothing */
	;

comp_statement	: BEGINN statements END
				;

statements	: statements SEMI statement
			| statement
			;

statement: 	assignment
			| if_statement
			| while_statement
			| for_statement
			| with_statement
			| subprogram_call
			| io_statement
			| comp_statement
			| /* nothing */
			;

assignment	: variable ASSIGN expression
			| variable ASSIGN STRING
			;

if_statement: IF expression THEN statement
			| IF expression THEN statement ELSE statement
			;

while_statement	: WHILE expression DO statement
				;

for_statement	: FOR ID ASSIGN iter_space DO statement
				;
				
iter_space	: expression TO expression
			| expression DOWNTO expression
			;

with_statement	: WITH variable DO statement
				;

subprogram_call	: ID
				| ID LPAREN expressions RPAREN
				;

io_statement: READ LPAREN read_list RPAREN
			| WRITE LPAREN write_list RPAREN
			;

read_list	: read_list COMMA read_item
			| read_item
			;

read_item	: variable
			;

write_list	: write_list COMMA write_item
			| write_item
			;

write_item	: expression
			| STRING
			;
			
%%

void yyerror (char const *msg)
{
  fprintf(stderr, "SimplePascal: %s\n", msg);
  exit(1);
}

int main ()
{
  return yyparse();
}