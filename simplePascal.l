%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "y.tab.h"
#define T_eof      0

int line_number_com = 0;
int line_number_str = 0;
char str_buf[1000];
void yyerror (char const *);
%}

%option caseless

%x COMMENT STRING1

D [0-9]
L [a-z]
W [ \t\r\n]

id "_"?[a-zA-Z]+([a-zA-Z0-9]|"_")*

%%

"{" 				BEGIN(COMMENT);
<COMMENT>[^}\n]+
<COMMENT>\n 		++line_number_com;
<COMMENT><<EOF>> 	yyerror("EOF in comment");
<COMMENT>"}" 		BEGIN(INITIAL);


\"							{ strcpy(str_buf,""); BEGIN(STRING1);}
<STRING1>\" 				{ BEGIN(INITIAL); return STRING;}
<STRING1>(\\\n|\\\r\n|\\) 	{ /* nothing */ }
<STRING1>(\\.|[^"\\]) 		{ strcat(str_buf,yytext);}
<STRING1>(\n|\r\n) 			{ printf("new line without \\"); }
<STRING1><<EOF>> 			{ printf("End of string without closing it"); }


"program" 	{ return PROGRAM; }
"const" 	{ return CONST; }
"type" 		{ return TYPE; }
"array" 	{ return ARRAY; }
"set" 		{ return SET; }
"of" 		{ return OF; }
"record" 	{ return RECORD; }
"var" 		{ return VAR; }
"forward" 	{ return FORWARD; }
"function" 	{ return FUNCTION; }
"procedure" { return PROCEDURE; }
"integer" 	{ return INTEGER; }
"real" 		{ return REAL; }
"boolean" 	{ return BOOLEAN; }
"char" 		{ return CHAR; }
"begin" 	{ return BEGINN; }
"end" 		{ return END; }
"if" 		{ return IF; }
"then" 		{ return THEN; }
"else" 		{ return ELSE; }
"while" 	{ return WHILE; }
"do" 		{ return DO; }
"for" 		{ return FOR; }
"downto" 	{ return DOWNTO; }
"to" 		{ return TO; }
"with" 		{ return WITH; }
"read" 		{ return READ; }
"write" 	{ return WRITE; }

"(" 	{ return LPAREN; }
")" 	{ return RPAREN; }
";" 	{ return SEMI; }
"." 	{ return DOT; }
"," 	{ return COMMA; }
"=" 	{ return EQU; }
":" 	{ return COLON; }
"[" 	{ return LBRACK; }
"]" 	{ return RBRACK; }
":=" 	{ return ASSIGN; }
".." 	{ return DOTDOT; }

">"|">="|"<"|"<="|"<>" 	{ return RELOP; }
[+-] 					{ return ADDOP; }
"or" 					{ return OROP; }
[*\/] 					{ return MULDIVANDOP; }
"mod"|"div"|"and" 		{ return MULDIVANDOP; }
"not" 					{ return NOTOP; }
"in" 					{ return INOP; }


0|[1-9][0-9]* 			{ return ICONST; }
"0H"[1-9A-F]+[0-9A-F]* 	{ return ICONST; }
"0B1"[01]* 				{ return ICONST; }

[0-9]*"."[0-9]+("E"[+-]?[0-9]+)? 	{ return RCONST; }
[0-9]+("E"[+-]?[0-9]+) 				{ return RCONST; }
"0H"([0-9A-F]*"."[0-9A-F]+) 		{ return RCONST; }
"0B"([01]*"."[01]+) 				{ return RCONST; }

"TRUE"|"FALSE" 	{ return BCONST; }

\'.\' 								{ return CCONST; }
\\"n"|\\"f"|\\"t"|\\"r"|\\"b"|\\"v"	{ return CCONST; }

\'([^']|\'\')*\' { return STRING; }

{id} 	{ return ID; }

{W}+ 	{ /* nothing */ }

<<EOF>> { return T_eof; }

%%
