# Autograder results for mp1_tsamu3 at 2024-02-02 17:25:24
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
==7304== Memcheck, a memory error detector
==7304== Copyright (C) 2002-2022, and GNU GPL'd, by Julian Seward et al.
==7304== Using Valgrind-3.19.0 and LibVEX; rerun with -h for copyright info
==7304== Command: ./auto_u
==7304== 
Test: Starting MP1 Test
Add: Starting Null pointer test
Add: Success, returns -1 on NULL

Add: Starting negative location test
==7304== Invalid write of size 1
==7304==    at 0x10A744: ??? (mp1.S:45)
==7304==    by 0x109862: main (mp1_autograder.c:76)
==7304==  Address 0x96ba028 is not stack'd, malloc'd or (recently) free'd
==7304== 
==7304== 
==7304== Process terminating with default action of signal 11 (SIGSEGV)
==7304==  Access not within mapped region at address 0x96BA028
==7304==    at 0x10A744: ??? (mp1.S:45)
==7304==    by 0x109862: main (mp1_autograder.c:76)
==7304==  If you believe this happened as a result of a stack
==7304==  overflow in your program's main thread (unlikely but
==7304==  possible), you can try to increase the size of the
==7304==  main thread stack using the --main-stacksize= flag.
==7304==  The main thread stack size used in this run was 8388608.
==7304== 
==7304== HEAP SUMMARY:
==7304==     in use at exit: 16 bytes in 1 blocks
==7304==   total heap usage: 1 allocs, 0 frees, 16 bytes allocated
==7304== 
==7304== 16 bytes in 1 blocks are definitely lost in loss record 1 of 1
==7304==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==7304==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==7304==    by 0x10A776: ??? (mp1.S:188)
==7304==    by 0x109862: main (mp1_autograder.c:76)
==7304== 
==7304== LEAK SUMMARY:
==7304==    definitely lost: 16 bytes in 1 blocks
==7304==    indirectly lost: 0 bytes in 0 blocks
==7304==      possibly lost: 0 bytes in 0 blocks
==7304==    still reachable: 0 bytes in 0 blocks
==7304==         suppressed: 0 bytes in 0 blocks
==7304== 
==7304== For lists of detected and suppressed errors, rerun with: -s
==7304== ERROR SUMMARY: 2 errors from 2 contexts (suppressed: 0 from 0)
```
## Autograder output log:
```
Test: Starting MP1 Test
Add: Starting Null pointer test
Add: Success, returns -1 on NULL

Add: Starting negative location test
Program exit code: 139
```
