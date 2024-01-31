# Autograder results for mp1_tsamu3 at 2024-01-31 00:25:42
This report was generated automatically by the autograder for tsamu3 using the commitID `b646d54` <br> <br>
**Disclaimer: This report is not your official grade. This is a experimental tool that is provided to you to help you debug your code. 
    Please do not use this as a reference for your grade, as it may not be accurate as it is not offical support yet.**
## Compilation
### Compilation failed, output log:
```
cc -Wall -g -c -D_USERSPACE -o mp1_userspace.o mp1_userspace.c
cc -Wall -g -D_USERSPACE -c -o mp1_autograder_u.o mp1_autograder.c
as -g -L mp1.S -o mp1_u.o
mp1.S: Assembler messages:
mp1.S:74: Error: bad expression
mp1.S:74: Error: found 'j', expected: ')'
mp1.S:74: Error: junk `jumptable(,%esi,4))' after expression
mp1.S:74: Error: operand size mismatch for `mov'
make: *** [Makefile:19: mp1_u.o] Error 1
```
