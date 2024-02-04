# Autograder results for mp1_tsamu3 at 2024-02-03 22:12:00
This report was generated automatically by the autograder for tsamu3 using the commitID `e133797` <br> <br>
**Disclaimer: This report is not your official grade. This is a experimental tool that is provided to you to help you debug your code. 
    Please do not use this as a reference for your grade, as it may not be accurate and its not officially supported yet.**
## Compilation
**Compilation succeeded**
## Error output log:
Crashed: ./auto_u crashed for mp1_tsamu3
Most likely, you have a segmentation fault in your code, make sure to handle null cases. Please check your code.
## Valgrind output log:
```
==7265== Memcheck, a memory error detector
==7265== Copyright (C) 2002-2022, and GNU GPL'd, by Julian Seward et al.
==7265== Using Valgrind-3.19.0 and LibVEX; rerun with -h for copyright info
==7265== Command: ./auto_u
==7265== 
Test: Starting MP1 Test
Add: Starting Null pointer test
Add: Success, returns -1 on NULL

Add: Starting negative location test
Add: Success, returns -1 on negative location

Add: Starting high positive location test
Add: Success, returns -1 on high positive location

Add: Adding frame0.txt and frame1.txt
Add: Success

Tasklet: Starting tasklet
==7265== Invalid write of size 1
==7265==    at 0x10A744: ??? (mp1.S:45)
==7265==    by 0x48921B7: ??? (in /usr/lib/i386-linux-gnu/libc.so.6)
==7265==    by 0x487C2C4: (below main) (libc_start_call_main.h:58)
==7265==  Address 0x4c396be is 617,550 bytes inside an unallocated block of size 4,056,440 in arena "client"
==7265== 
Tasklet: Error, doesn't change frames

Sync: Starting sync test
Sync: Error, does not sync correctly

Find: Starting find test
Find: Error, does not return correct struct

Find: Starting NULL pointer test
Find: Error, returns success on NULL

Find: Starting big positive location test
Find: Error, returns success on positive high location

Remove: Starting remove test
Remove: Removing sync char
Remove: Success, removed sync char

Remove: Try to find sync char after removing
Remove|Find: Error, Remove does not remove struct or find doesn't return -1 on failure

Remove: Error, remove does not remove struct

Remove: Remove all structs
Remove: Success, removes all structs

Test: Add score: 7.0 / 7.0
Test: Tasklet score: 0.0 / 7.0
Test: Remove score: 2.0 / 6.0
Test: Sync score: 0.0 / 6.0
Test: Find score: 0.0 / 6.0
Test: Total score w\o the negative conditions for failure to meet specs: 9.0 / 32.0
==7265== 
==7265== HEAP SUMMARY:
==7265==     in use at exit: 1,584 bytes in 99 blocks
==7265==   total heap usage: 1,310 allocs, 1,211 frees, 3,473,864 bytes allocated
==7265== 
==7265== 16 bytes in 1 blocks are definitely lost in loss record 1 of 3
==7265==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==7265==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==7265==    by 0x10A7F8: ??? (mp1.S:175)
==7265==    by 0x1097E9: main (mp1_autograder.c:64)
==7265== 
==7265== 1,552 bytes in 97 blocks are indirectly lost in loss record 2 of 3
==7265==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==7265==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==7265==    by 0x10A7F8: ??? (mp1.S:175)
==7265==    by 0x10A5F7: add_frames (mp1_autograder.c:433)
==7265==    by 0x1099B1: main (mp1_autograder.c:113)
==7265== 
==7265== 1,568 (16 direct, 1,552 indirect) bytes in 1 blocks are definitely lost in loss record 3 of 3
==7265==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==7265==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==7265==    by 0x10A7F8: ??? (mp1.S:175)
==7265==    by 0x109B56: main (mp1_autograder.c:153)
==7265== 
==7265== LEAK SUMMARY:
==7265==    definitely lost: 32 bytes in 2 blocks
==7265==    indirectly lost: 1,552 bytes in 97 blocks
==7265==      possibly lost: 0 bytes in 0 blocks
==7265==    still reachable: 0 bytes in 0 blocks
==7265==         suppressed: 0 bytes in 0 blocks
==7265== 
==7265== For lists of detected and suppressed errors, rerun with: -s
==7265== ERROR SUMMARY: 2570 errors from 3 contexts (suppressed: 0 from 0)
```
## Autograder output log:
```
Test: Starting MP1 Test
Add: Starting Null pointer test
Add: Success, returns -1 on NULL

Add: Starting negative location test
Add: Success, returns -1 on negative location

Add: Starting high positive location test
Add: Success, returns -1 on high positive location

Add: Adding frame0.txt and frame1.txt
Add: Success

Tasklet: Starting tasklet
Program exit code: 139
```
