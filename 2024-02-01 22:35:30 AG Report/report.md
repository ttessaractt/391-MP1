# Autograder results for mp1_tsamu3 at 2024-02-01 22:35:27
This report was generated automatically by the autograder for tsamu3 using the commitID `b26e725` <br> <br>
**Disclaimer: This report is not your official grade. This is a experimental tool that is provided to you to help you debug your code. 
    Please do not use this as a reference for your grade, as it may not be accurate and its not officially supported yet.**
## Compilation
**Compilation succeeded**
## Error output log:
Crashed: ./auto_u crashed for mp1_tsamu3
Most likely, you have a segmentation fault in your code, make sure to handle null cases. Please check your code.
## Valgrind output log:
```
==8118== Memcheck, a memory error detector
==8118== Copyright (C) 2002-2022, and GNU GPL'd, by Julian Seward et al.
==8118== Using Valgrind-3.19.0 and LibVEX; rerun with -h for copyright info
==8118== Command: ./auto_u
==8118== 
Test: Starting MP1 Test
Add: Starting Null pointer test
==8118== Source and destination overlap in memcpy(0x10, 0x0, 79171624)
==8118==    at 0x4847DDA: memcpy (vg_replace_strmem.c:1120)
==8118==    by 0x109638: mp1_copy_from_user (mp1_userspace.c:144)
==8118==    by 0x10A78B: ??? (mp1.S:207)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118== 
==8118== Invalid read of size 4
==8118==    at 0x4847E52: memcpy (vg_replace_strmem.c:1120)
==8118==    by 0x109638: mp1_copy_from_user (mp1_userspace.c:144)
==8118==    by 0x10A78B: ??? (mp1.S:207)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==  Address 0x4b81024 is 4 bytes before a block of size 16 alloc'd
==8118==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==8118==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==8118==    by 0x10A778: ??? (mp1.S:187)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==    by 0x1097E9: main (mp1_autograder.c:64)
==8118== 
==8118== Invalid read of size 4
==8118==    at 0x4847E64: memcpy (vg_replace_strmem.c:1120)
==8118==    by 0x109638: mp1_copy_from_user (mp1_userspace.c:144)
==8118==    by 0x10A78B: ??? (mp1.S:207)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==  Address 0x4b81020 is 8 bytes before a block of size 16 alloc'd
==8118==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==8118==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==8118==    by 0x10A778: ??? (mp1.S:187)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==    by 0x1097E9: main (mp1_autograder.c:64)
==8118== 
==8118== Invalid read of size 4
==8118==    at 0x4847E6A: memcpy (vg_replace_strmem.c:1120)
==8118==    by 0x109638: mp1_copy_from_user (mp1_userspace.c:144)
==8118==    by 0x10A78B: ??? (mp1.S:207)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==  Address 0x4b8101c is 12 bytes before a block of size 16 alloc'd
==8118==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==8118==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==8118==    by 0x10A778: ??? (mp1.S:187)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==    by 0x1097E9: main (mp1_autograder.c:64)
==8118== 
==8118== Invalid read of size 4
==8118==    at 0x4847E70: memcpy (vg_replace_strmem.c:1120)
==8118==    by 0x109638: mp1_copy_from_user (mp1_userspace.c:144)
==8118==    by 0x10A78B: ??? (mp1.S:207)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==  Address 0x4b81018 is 16 bytes before a block of size 16 alloc'd
==8118==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==8118==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==8118==    by 0x10A778: ??? (mp1.S:187)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==    by 0x1097E9: main (mp1_autograder.c:64)
==8118== 
==8118== Invalid read of size 4
==8118==    at 0x4847E5B: memcpy (vg_replace_strmem.c:1120)
==8118==    by 0x109638: mp1_copy_from_user (mp1_userspace.c:144)
==8118==    by 0x10A78B: ??? (mp1.S:207)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==  Address 0x4b81014 is 20 bytes before a block of size 16 alloc'd
==8118==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==8118==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==8118==    by 0x10A778: ??? (mp1.S:187)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==    by 0x1097E9: main (mp1_autograder.c:64)
==8118== 
==8118== Invalid write of size 4
==8118==    at 0x4847E61: memcpy (vg_replace_strmem.c:1120)
==8118==    by 0x109638: mp1_copy_from_user (mp1_userspace.c:144)
==8118==    by 0x10A78B: ??? (mp1.S:207)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==  Address 0x4b81024 is 4 bytes before a block of size 16 alloc'd
==8118==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==8118==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==8118==    by 0x10A778: ??? (mp1.S:187)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==    by 0x1097E9: main (mp1_autograder.c:64)
==8118== 
==8118== Invalid write of size 4
==8118==    at 0x4847E67: memcpy (vg_replace_strmem.c:1120)
==8118==    by 0x109638: mp1_copy_from_user (mp1_userspace.c:144)
==8118==    by 0x10A78B: ??? (mp1.S:207)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==  Address 0x4b81020 is 8 bytes before a block of size 16 alloc'd
==8118==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==8118==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==8118==    by 0x10A778: ??? (mp1.S:187)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==    by 0x1097E9: main (mp1_autograder.c:64)
==8118== 
==8118== Invalid write of size 4
==8118==    at 0x4847E6D: memcpy (vg_replace_strmem.c:1120)
==8118==    by 0x109638: mp1_copy_from_user (mp1_userspace.c:144)
==8118==    by 0x10A78B: ??? (mp1.S:207)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==  Address 0x4b8101c is 12 bytes before a block of size 16 alloc'd
==8118==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==8118==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==8118==    by 0x10A778: ??? (mp1.S:187)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==    by 0x1097E9: main (mp1_autograder.c:64)
==8118== 
==8118== Invalid write of size 4
==8118==    at 0x4847E74: memcpy (vg_replace_strmem.c:1120)
==8118==    by 0x109638: mp1_copy_from_user (mp1_userspace.c:144)
==8118==    by 0x10A78B: ??? (mp1.S:207)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==  Address 0x4b81018 is 16 bytes before a block of size 16 alloc'd
==8118==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==8118==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==8118==    by 0x10A778: ??? (mp1.S:187)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==    by 0x1097E9: main (mp1_autograder.c:64)
==8118== 
==8118== Invalid write of size 1
==8118==    at 0x10A744: ??? (mp1.S:43)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==  Address 0x96ba028 is not stack'd, malloc'd or (recently) free'd
==8118== 
==8118== 
==8118== Process terminating with default action of signal 11 (SIGSEGV)
==8118==  Access not within mapped region at address 0x96BA028
==8118==    at 0x10A744: ??? (mp1.S:43)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==  If you believe this happened as a result of a stack
==8118==  overflow in your program's main thread (unlikely but
==8118==  possible), you can try to increase the size of the
==8118==  main thread stack using the --main-stacksize= flag.
==8118==  The main thread stack size used in this run was 8388608.
==8118== 
==8118== HEAP SUMMARY:
==8118==     in use at exit: 16 bytes in 1 blocks
==8118==   total heap usage: 1 allocs, 0 frees, 16 bytes allocated
==8118== 
==8118== 16 bytes in 1 blocks are definitely lost in loss record 1 of 1
==8118==    at 0x4840660: malloc (vg_replace_malloc.c:381)
==8118==    by 0x109689: mp1_malloc (mp1_userspace.c:159)
==8118==    by 0x10A778: ??? (mp1.S:187)
==8118==    by 0x1094ED: __mp1_ioctl (mp1_userspace.c:102)
==8118==    by 0x1097E9: main (mp1_autograder.c:64)
==8118== 
==8118== LEAK SUMMARY:
==8118==    definitely lost: 16 bytes in 1 blocks
==8118==    indirectly lost: 0 bytes in 0 blocks
==8118==      possibly lost: 0 bytes in 0 blocks
==8118==    still reachable: 0 bytes in 0 blocks
==8118==         suppressed: 0 bytes in 0 blocks
==8118== 
==8118== For lists of detected and suppressed errors, rerun with: -s
==8118== ERROR SUMMARY: 23 errors from 12 contexts (suppressed: 0 from 0)
```
## Autograder output log:
```
Test: Starting MP1 Test
Add: Starting Null pointer test
Program exit code: 139
```
