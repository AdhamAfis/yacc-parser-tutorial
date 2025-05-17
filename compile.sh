#!/bin/bash

# Exit on error
set -e

echo "=== YACC Calculator Example Compilation ==="

# Check for required tools
echo "Checking for required tools..."

# Determine which tools are available
YACC_CMD=""
LEX_CMD=""
CC_CMD="gcc"

# Check for YACC/Bison
if command -v bison &> /dev/null; then
    YACC_CMD="bison"
    echo "Found bison: $(which bison)"
elif command -v yacc &> /dev/null; then
    YACC_CMD="yacc"
    echo "Found yacc: $(which yacc)"
else
    echo "Error: Neither yacc nor bison found. Please install one of them."
    exit 1
fi

# Check for LEX/Flex
if command -v flex &> /dev/null; then
    LEX_CMD="flex"
    echo "Found flex: $(which flex)"
elif command -v lex &> /dev/null; then
    LEX_CMD="lex"
    echo "Found lex: $(which lex)"
else
    echo "Error: Neither lex nor flex found. Please install one of them."
    exit 1
fi

# Check for C compiler
if ! command -v $CC_CMD &> /dev/null; then
    echo "Error: C compiler ($CC_CMD) not found. Please install a C compiler."
    exit 1
fi
echo "Found C compiler: $(which $CC_CMD)"

# Try to use Homebrew-installed bison/flex if available
if [ -d "/opt/homebrew/opt/bison/bin" ]; then
    echo "Using Homebrew's bison"
    YACC_CMD="/opt/homebrew/opt/bison/bin/bison"
fi

if [ -d "/opt/homebrew/opt/flex/bin" ]; then
    echo "Using Homebrew's flex"
    LEX_CMD="/opt/homebrew/opt/flex/bin/flex"
fi

# Generate parser files
echo -e "\n=== Generating parser files ==="
if [ "$YACC_CMD" = "yacc" ]; then
    $YACC_CMD -d calc.y || {
        echo "Failed to generate parser files with yacc. Trying with Homebrew bison..."
        if [ -x "/opt/homebrew/opt/bison/bin/bison" ]; then
            /opt/homebrew/opt/bison/bin/bison -d -o y.tab.c calc.y
        else
            echo "Error: yacc failed and Homebrew bison not available"
            exit 1
        fi
    }
else
    $YACC_CMD -d calc.y -o y.tab.c
fi
echo "Generated y.tab.c and y.tab.h"

# Generate lexer file
echo -e "\n=== Generating lexer file ==="
$LEX_CMD calc.l || {
    echo "Failed to generate lexer file with $LEX_CMD. Trying with Homebrew flex..."
    if [ -x "/opt/homebrew/opt/flex/bin/flex" ]; then
        /opt/homebrew/opt/flex/bin/flex calc.l
    else
        echo "Error: lex/flex failed and Homebrew flex not available"
        exit 1
    fi
}
echo "Generated lex.yy.c"

# Compile everything together
echo -e "\n=== Compiling the calculator ==="
$CC_CMD -o calculator y.tab.c lex.yy.c -ll || {
    echo "Compilation failed with -ll. Trying without library flags..."
    $CC_CMD -o calculator y.tab.c lex.yy.c || {
        echo "Error: Compilation failed"
        exit 1
    }
}
echo "Generated calculator executable"

echo -e "\n=== Compilation complete! ==="
echo "Run the calculator with: ./calculator"
echo "Enter expressions like '2 + 3 * 4' and press Enter to evaluate."
echo "Press Ctrl+D to exit the calculator." 