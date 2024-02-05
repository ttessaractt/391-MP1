# Autograder results for mp1_tsamu3 at 2024-02-05 12:20:20
This report was generated automatically by the autograder for tsamu3 using the commitID `20ad69a` <br> <br>
**Disclaimer: This report is not your official grade. This is a experimental tool that is provided to you to help you debug your code. 
    Please do not use this as a reference for your grade, as it may not be accurate and its not officially supported yet.**
## Compilation
**Compilation succeeded**
## Valgrind output log:
```
==17067== Memcheck, a memory error detector
==17067== Copyright (C) 2002-2022, and GNU GPL'd, by Julian Seward et al.
==17067== Using Valgrind-3.19.0 and LibVEX; rerun with -h for copyright info
==17067== Command: ./auto_u
==17067== 
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
Tasklet: Success

Sync: Starting sync test
Sync: Success, copy_from_user called in Add
Sync: Success

Find: Starting find test
Find: Success, copy_to_user called
Find: Error, copy_from_user not called
Find: Finds the correct struct

Find: Starting NULL pointer test
Find: Success, returns -1 on NULL

Find: Starting big positive location test
Find: Success, returns -1 on positive high location

Remove: Starting remove test
Remove: Removing sync char
Remove: Success, removed sync char

Remove: Try to find sync char after removing
Remove|Find: Edge case Success
Remove: Program ends with correct Sync Char Success

Remove: Remove all structs
Remove: Success, removes all structs

Test: Add score: 7.0 / 7.0
Test: Tasklet score: 7.0 / 7.0
Test: Remove score: 6.0 / 6.0
Test: Sync score: 6.0 / 6.0
Test: Find score: 5.0 / 6.0
Test: Total score w\o the negative conditions for failure to meet specs: 31.0 / 32.0
==17067== 
==17067== HEAP SUMMARY:
==17067==     in use at exit: 0 bytes in 0 blocks
==17067==   total heap usage: 1,318 allocs, 1,318 frees, 3,499,696 bytes allocated
==17067== 
==17067== All heap blocks were freed -- no leaks are possible
==17067== 
==17067== For lists of detected and suppressed errors, rerun with: -s
==17067== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
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
Tasklet: Success

Sync: Starting sync test
Sync: Success, copy_from_user called in Add
Sync: Success

Find: Starting find test
Find: Success, copy_to_user called
Find: Error, copy_from_user not called
Find: Finds the correct struct

Find: Starting NULL pointer test
Find: Success, returns -1 on NULL

Find: Starting big positive location test
Find: Success, returns -1 on positive high location

Remove: Starting remove test
Remove: Removing sync char
Remove: Success, removed sync char

Remove: Try to find sync char after removing
Remove|Find: Edge case Success
Remove: Program ends with correct Sync Char Success

Remove: Remove all structs
Remove: Success, removes all structs

Test: Add score: 7.0 / 7.0
Test: Tasklet score: 7.0 / 7.0
Test: Remove score: 6.0 / 6.0
Test: Sync score: 6.0 / 6.0
Test: Find score: 5.0 / 6.0
Test: Total score w\o the negative conditions for failure to meet specs: 31.0 / 32.0
Program exit code: 0
```
## Ktest predictions:
Check Autograder output log for correct copy_to/from_user implementations<br>
Check Valgrind output log for memory leaks<br>
<br>
### Ktest predictions: Likely to pass assuming utest passes above<br>
