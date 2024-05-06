bison -d parser.y
flex lexer.l
g++ parser.tab.c parser.tab.h lex.yy.c -o parser
./parser < "$1"