# Autograder results for mp1_tsamu3 at 2024-02-02 21:41:59
This report was generated automatically by the autograder for tsamu3 using the commitID `6bf4375` <br> <br>
**Disclaimer: This report is not your official grade. This is a experimental tool that is provided to you to help you debug your code. 
    Please do not use this as a reference for your grade, as it may not be accurate and its not officially supported yet.**
## Compilation
**Compilation succeeded**
## Error output log:
Crashed: ./auto_u crashed for mp1_tsamu3
Most likely, you have a segmentation fault in your code, make sure to handle null cases. Please check your code.
## Valgrind output log:
```
==28328== Memcheck, a memory error detector
==28328== Copyright (C) 2002-2022, and GNU GPL'd, by Julian Seward et al.
==28328== Using Valgrind-3.19.0 and LibVEX; rerun with -h for copyright info
==28328== Command: ./auto_u
==28328== 
Test: Starting MP1 Test
Add: Starting Null pointer test
Add: Success, returns -1 on NULL

Add: Starting negative location test
==28328== Invalid write of size 1
==28328==    at 0x10A744: ??? (mp1.S:45)
==28328==    by 0x109862: main (mp1_autograder.c:76)
==28328==  Address 0x96ba028 is not stack'd, malloc'd or (recently) free'd
==28328== 
==28328== 
==28328== Process terminating with default action of signal 11 (SIGSEGV)
==28328==  Access not within mapped region at address 0x96BA028
==28328==    at 0x10A744: ??? (mp1.S:45)
==28328==    by 0x109862: main (mp1_autograder.c:76)
==28328==  If you believe this happened as a result of a stack
==28328==  overflow in your program's main thread (unlikely but
==28328==  possible), you can try to increase the size of the
==28328==  main thread stack using the --main-stacksize= flag.
==28328==  The main thread stack size used in this run was 8388608.
==28328== 
==28328== HEAP SUMMARY:
==28328==     in use at exit: 16 bytes in 1 blocks
==28328==   total heap usage: 1 allocs, 0 frees, 16 bytes allocated
==28328== 
==28328== 16 bytes in 1 blocks are definitely lost in loss record 1 of 1
==28328==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==28328==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==28328==    by 0x10A776: ??? (mp1.S:188)
==28328==    by 0x109862: main (mp1_autograder.c:76)
==28328== 
==28328== LEAK SUMMARY:
==28328==    definitely lost: 16 bytes in 1 blocks
==28328==    indirectly lost: 0 bytes in 0 blocks
==28328==      possibly lost: 0 bytes in 0 blocks
==28328==    still reachable: 0 bytes in 0 blocks
==28328==         suppressed: 0 bytes in 0 blocks
==28328== 
==28328== For lists of detected and suppressed errors, rerun with: -s
==28328== ERROR SUMMARY: 2 errors from 2 contexts (suppressed: 0 from 0)
```
## Autograder output log:
```
Test: Starting MP1 Test
Add: Starting Null pointer test
Add: Success, returns -1 on NULL

Add: Starting negative location test
Program exit code: 139
```
