# Autograder results for mp1_tsamu3 at 2024-02-04 16:26:32
This report was generated automatically by the autograder for tsamu3 using the commitID `b791c69` <br> <br>
**Disclaimer: This report is not your official grade. This is a experimental tool that is provided to you to help you debug your code. 
    Please do not use this as a reference for your grade, as it may not be accurate and its not officially supported yet.**
## Compilation
**Compilation succeeded**
## Error output log:
Crashed: ./auto_u crashed for mp1_tsamu3
Most likely, you have a segmentation fault in your code, make sure to handle null cases. Please check your code.
## Valgrind output log:
```
==10673== Memcheck, a memory error detector
==10673== Copyright (C) 2002-2022, and GNU GPL'd, by Julian Seward et al.
==10673== Using Valgrind-3.19.0 and LibVEX; rerun with -h for copyright info
==10673== Command: ./auto_u
==10673== 
Test: Starting MP1 Test
Add: Starting Null pointer test
Add: Success, returns -1 on NULL

Add: Starting negative location test
Add: Success, returns -1 on negative location
Add: Success, copy_from_user called

Add: Starting high positive location test
Add: Success, returns -1 on high positive location

Add: Adding frame0.txt and frame1.txt
Add: Success

Tasklet: Starting tasklet
Tasklet: Error, doesn't change frames

Sync: Starting sync test
Sync: Success, copy_from_user called in Add
Sync: Success

Find: Starting find test
==10673== Source and destination overlap in memcpy(0x4b84b60, 0x4b84b60, 16)
==10673==    at 0x4847DDA: memcpy (vg_replace_strmem.c:1120)
==10673==    by 0x109652: mp1_copy_from_user (mp1_userspace.c:146)
==10673==    by 0x10ABA2: ??? (mp1.S:495)
==10673==    by 0x10AB2F: ??? (mp1.S:412)
==10673==    by 0x109515: __mp1_ioctl (mp1_userspace.c:106)
==10673==    by 0x109D36: main (mp1_autograder.c:200)
==10673== 
==10673== Invalid read of size 2
==10673==    at 0x10ABAF: ??? (mp1.S:503)
==10673==    by 0x10AB2F: ??? (mp1.S:412)
==10673==    by 0x109515: __mp1_ioctl (mp1_userspace.c:106)
==10673==    by 0x109D36: main (mp1_autograder.c:200)
==10673==  Address 0x0 is not stack'd, malloc'd or (recently) free'd
==10673== 
==10673== 
==10673== Process terminating with default action of signal 11 (SIGSEGV)
==10673==  Access not within mapped region at address 0x0
==10673==    at 0x10ABAF: ??? (mp1.S:503)
==10673==    by 0x10AB2F: ??? (mp1.S:412)
==10673==    by 0x109515: __mp1_ioctl (mp1_userspace.c:106)
==10673==    by 0x109D36: main (mp1_autograder.c:200)
==10673==  If you believe this happened as a result of a stack
==10673==  overflow in your program's main thread (unlikely but
==10673==  possible), you can try to increase the size of the
==10673==  main thread stack using the --main-stacksize= flag.
==10673==  The main thread stack size used in this run was 8388608.
==10673== 
==10673== HEAP SUMMARY:
==10673==     in use at exit: 1,584 bytes in 99 blocks
==10673==   total heap usage: 104 allocs, 5 frees, 10,232 bytes allocated
==10673== 
==10673== 16 bytes in 1 blocks are definitely lost in loss record 1 of 3
==10673==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==10673==    by 0x1096A3: mp1_malloc (mp1_userspace.c:161)
==10673==    by 0x10AB8D: ??? (mp1.S:485)
==10673==    by 0x10AB2F: ??? (mp1.S:412)
==10673==    by 0x109515: __mp1_ioctl (mp1_userspace.c:106)
==10673==    by 0x109D36: main (mp1_autograder.c:200)
==10673== 
==10673== 1,552 bytes in 97 blocks are indirectly lost in loss record 2 of 3
==10673==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==10673==    by 0x1096A3: mp1_malloc (mp1_userspace.c:161)
==10673==    by 0x10A9FE: ??? (mp1.S:217)
==10673==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==10673==    by 0x10A7D1: add_frames (mp1_autograder.c:483)
==10673==    by 0x109A30: main (mp1_autograder.c:126)
==10673== 
==10673== 1,568 (16 direct, 1,552 indirect) bytes in 1 blocks are definitely lost in loss record 3 of 3
==10673==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==10673==    by 0x1096A3: mp1_malloc (mp1_userspace.c:161)
==10673==    by 0x10A9FE: ??? (mp1.S:217)
==10673==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==10673==    by 0x109BDF: main (mp1_autograder.c:167)
==10673== 
==10673== LEAK SUMMARY:
==10673==    definitely lost: 32 bytes in 2 blocks
==10673==    indirectly lost: 1,552 bytes in 97 blocks
==10673==      possibly lost: 0 bytes in 0 blocks
==10673==    still reachable: 0 bytes in 0 blocks
==10673==         suppressed: 0 bytes in 0 blocks
==10673== 
==10673== For lists of detected and suppressed errors, rerun with: -s
==10673== ERROR SUMMARY: 4 errors from 4 contexts (suppressed: 0 from 0)
```
## Autograder output log:
```
Test: Starting MP1 Test
Add: Starting Null pointer test
Add: Success, returns -1 on NULL

Add: Starting negative location test
Add: Success, returns -1 on negative location
Add: Success, copy_from_user called

Add: Starting high positive location test
Add: Success, returns -1 on high positive location

Add: Adding frame0.txt and frame1.txt
Add: Success

Tasklet: Starting tasklet
Tasklet: Error, doesn't change frames

Sync: Starting sync test
Sync: Success, copy_from_user called in Add
Sync: Success

Find: Starting find test
Find: Success, copy_from_user called
Find: Error, copy_to_user not called
Find: Error, does not return correct struct

Find: Starting NULL pointer test
Program exit code: 139
```
## Ktest predictions:
Check Autograder output log for correct copy_to/from_user implementations<br>
Check Valgrind output log for memory leaks<br>
Valgrind detected memory issues, please check the valgrind log for more details<br> <br>
### Ktest predictions: Highly likely to fail<br>
