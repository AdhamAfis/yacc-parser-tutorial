%{
#include <stdio.h>
#include <stdlib.h>
int yylex();
void yyerror(const char *s);
%}

%token NUMBER
%token PLUS MINUS TIMES DIVIDE
%token LPAREN RPAREN
%left PLUS MINUS
%left TIMES DIVIDE

%%
input:    /* empty */
        | input line
        ;

line:     '\n'
        | expr '\n'  { printf("Result: %d\n", $1); }
        | error '\n' { yyerrok; }
        ;

expr:     NUMBER            { $$ = $1; }
        | expr PLUS expr    { $$ = $1 + $3; }
        | expr MINUS expr   { $$ = $1 - $3; }
        | expr TIMES expr   { $$ = $1 * $3; }
        | expr DIVIDE expr  { 
            if ($3 == 0) {
                yyerror("Division by zero");
                $$ = 0;
            } else {
                $$ = $1 / $3;
            }
        }
        | LPAREN expr RPAREN { $$ = $2; }
        ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Simple Calculator\n");
    printf("Enter expressions with numbers, +, -, *, /, and parentheses.\n");
    printf("Press Ctrl+D to exit.\n");
    yyparse();
    return 0;
} 