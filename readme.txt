yacc -dv simplePascal.y
flex simplePascal.l
gcc lex.yy.c y.tab.c zyywrap.c

a <SimplePascaltest1.p
a <SimplePascaltest2.p