%{
#include <stdio.h>
#include "y.tab.h"
#include <stdlib.h>
%}

%%
[0-9]+        { yylval = atoi(yytext); return NUMBER; }
"+"           { return PLUS; }
"-"           { return MINUS; }
"*"           { return TIMES; }
"/"           { return DIVIDE; }
"("           { return LPAREN; }
")"           { return RPAREN; }
[ \t]+        { /* Skip whitespace */ }
[\n]          { return '\n'; }
.             { printf("Unrecognized character: %s\n", yytext); }
%%

int yywrap() {
    return 1;
} 