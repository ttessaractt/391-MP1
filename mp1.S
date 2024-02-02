.data                                   # section declaration


        # Useful offset constants for accessing members of a
        # struct mp1_blink_struct structure
        LOCATION   = 0    
        ON_CHAR    = 2
        OFF_CHAR   = 3
        ON_LENGTH  = 4
        OFF_LENGTH = 6
        COUNTDOWN  = 8
        STATUS     = 10
        NEXT       = 12


        STRUCT_SIZE = 16

# Pointer to head of list (initialized to NULL)
mp1_list_head:
        .long   0


.text                                   # section declaration

# Export the function symbol names

.global mp1_rtc_tasklet
.global mp1_ioctl
.global mp1_poke
.global mp1_ioctl_add
.global mp1_copy_from_user

# void mp1_poke(void);
#
# Interface: Register-based arguments (not C-style)
#    Inputs: %cl  - The byte you wish to write
#            %eax - Offset from the start of video memory that you wish
#                   to write to
#   Outputs: Text-mode video screen is written to at location %eax with
#            the byte in %cl
# Registers: Clobbers EDX
mp1_poke:
       
        movl    vmem_base_addr(,1),%edx
        movb    %cl,(%edx,%eax,1)
        ret

mp1_rtc_tasklet:
# walk down mp1_list_head and examine each struct
# decrements countdown
# if countdown is zero look at status
# if status == 1
        # on char is displayed, swap to off char & make status 0
        # countdown = off_length
# if status == 0
        # off char is displayed, swap to on char & make status 1
        # countdown = on_length
# call mp1_poke with new char
# go to next struct in linked list

# return 0 once it is done
        # movl mp1_list_head, %esi        # move head of list to esi
        # call T_LOOP                     # call loop that cycles through linked list
        # movl $0, %eax                   # return 0
        ret
/*
T_LOOP: # loop for tasklet
        decl 8(%esi)            # decrement countdown
        cmpl $0, 8(%esi)        # compare countdown to 0
        je ZERO                 # if countdown is 0, jump
        movl 12(%esi), %esi     # go to next struct
        cmpl $0, %esi           # check if entire list has been done
        jne T_LOOP              # if there is still more list, continue loop
        ret

ZERO: # if countdown is 0
        cmpl $0, 10(%esi)       # compare status to 0
        je OFF                  # if status is 0
        jne ON                  # if status is 1
OFF: # is status == 0
        push %ebx
        movl 8(%esi), %ebx      # set ebx to countdown
        movb 2(%esi), %cl       # set cl to on_char
        movl (%esi), %eax       # move location (?) to eax
        call mp1_poke           # change character
        movl $1, 10(%esi)       # set status to 1
        movl 4(%esi), %ebx   # set countdown to on_length
        movl 12(%esi), %esi     # go to next struct
        cmpl $0, %esi           # check if entire list has been done
        pop %ebx
        jne T_LOOP              # if there is still more list, continue loop
ON: # if status == 1
        push %ebx
        movl 8(%esi), %ebx      # set ebx to countdown
        movb 3(%esi), %cl       # set cl to off_char
        movl (%esi), %eax       # move location (?) to eax
        call mp1_poke           # change character
        movl $0, 10(%esi)       # set status to 0
        movl 6(%esi), %ebx   # set countdown to off_length
        movl 12(%esi), %esi     # go to next struct
        cmpl $0, %esi           # check if entire list has been done
        pop %ebx
        jne T_LOOP              # if there is still more list, continue loop
*/
mp1_ioctl:      # dispacher function
#  uses cmd to determine which of the 4 functions to jump to
# int mp1_ioctl (unsigned long arg, unsigned long cmd)

/*
--------------------------
| return address %esp | <- ESP (at start)
| arg            %esp+4  |
| command number %esp+8 |
| old stack      %esp+12 |
*/
# move cmd from stack to register
movl 8(%esp), %eax      # move cmd from stack to esi
# compare to check if <0 or >3
cmpl $3, %eax           # if esi > 3
ja ERROR              # if esi > 3 jump to default (unsigned)
cmpl $0, %eax           # if esi < 0
jb ERROR              # if esi < 0 jump to default (unsigned)
# jmp *jumptable(,%esi,4) # jumps to core functions based on esi (cmd)
# set esp to jumptable *jumptable(,%esi,4)
        # jump table
        # arg will be first on stack it is ready to use by core functions   
# popl %esi       # restore stack
# popl %ebp       # restore stack
jmp *jumptable(,%eax,4)
ret     # pop top of stack off (core function) and jump

/* end of function stack
| arg            | <- ESP
| command number |
| old stack      |
*/
mp1_ioctl_add: # add a mp1_blink_struct to the head of the linked list
# int mp1_ioctl_add(unsigned long arg)
# arg is a (user level) ptr to a mp1_blink_struct struct

# dynamically allocate memory using mp1_malloc to store copy of structure
# use mp1_copy_from_user to copy entire struct
# countdown = on_length
# status = 1
# fill out all struct parts (including next)
# insert struct at head of linked list using mp1_list_head ptr
# call mp1_poke (with correct parameters

/*
should return 0 if works
should return -1 if
        - memory allocation error (mp1_malloc returns NULL)
        - if mp1_copy_from_user returns anything other than 0
        - if location not in valid range (0 to 80*25-1)
must prevent memory leaks, free all malloc'd memory
*/
# push ____ push last parameter first
# push ____ push 2nd parameter
# push ____ push first parameter last
# call myFunc
# add $12, %esp (12 = 4*# of parameters)
# pushl %ebp              # save old base ptr
# movl %esp, %ebp         # set stack frame, ebp = esp

# protect callee saved regs here (do all)
# pushl %esi
/*

-------------------------- caller
| return address %ebp+4  |
| arg            %ebp+8  |
| command number %ebp+12 |
| old stack      %ebp+16 | <- old EBP
*/
# push caller preserved
# malloc: void* mp1_malloc(unsigned long size), size = 16 (?)
# copy: unsigned long mp1_copy_from_user (void *to, const void *from, unsigned long n)
# save shit ?

# if arg is 0, error
leal 4(%esp), %edx
cmpl $0, (%edx)
je ERROR
# cmpl $1999, %edx        # check if location is < 80*25-1
# ja ERROR

pushl $16        # push size to stack
call mp1_malloc # call malloc, void ptr for memory allocated stored in %eax
popl %ecx
# popl %ecx
# popl %ecx
cmpl $0, %eax         # check if eax is NULL, (eax needs to be dereferenced for cmp to work, in ()'s )
je ERROR
# cmpl $0, %eax   # compare for checking if mp1_malloc returns NULL (0 in x86)
# je ERROR        # if ptr is NULL, error
# popl %ebx
# leal -4(%ebp), %esp    # clean up stack, remove 16
# je ERROR        # if ptr is NULL, error

# save %eax ?

# copy struct
# movl 8(%ebp), %ecx        # pop arg off stack
# movl %eax, %ebx
# pushl %eax       # push *to, space allocated in malloc
# pushl 4(%esp)       # push *from, arg
# pushl $16       # push n (size to copy)
movl %eax, %ebx         # save eax (*to) in ebx
pushl $16       # push n (size to copy)
pushl %eax       # push *to, space allocated in malloc
pushl 12(%esp)       # push *from, arg
call mp1_copy_from_user # copy struct to memory allocated
popl %ecx
popl %ecx
popl %ecx
cmpl $0, %eax   # compare for checking if eax != 0, check if all memory was able to be copied
jne ERROR_FREE   # if eax != 0, error + free memory
# leal -12(%ebp), %esp   # clean up stack, remove inputs to mp1_copy_from_user
# if arg (location)(from stack) not in bounds, return -1 + free memory
/*cmpl $1999, %edx        # check if location is < 80*25-1
ja ERROR_FREE           # if arg > 80*25-1, error + free memory
cmpl $0, %edx           # check if location is > 0
jb ERROR_FREE           # if arg < 0, error + free memory
*/
# add struct values
# push %ebx

/*
        LOCATION   = 0    
        ON_CHAR    = 2
        OFF_CHAR   = 3
        ON_LENGTH  = 4
        OFF_LENGTH = 6
        COUNTDOWN  = 8
        STATUS     = 10
        NEXT       = 12

new countdown = old on length
new status = 1
new next = old mp1_list_head
new mp1_list_head = location

%eax = ptr to new that changes
%ebx = ptr to new (location)
%ecx = 
%edx = ptr to from
*/

pushl %ecx
pushl %eax
# edx is ptr to from, ebx it ptr to to, ecx is intermediate, eax is ptr to to that changes
# movl %edx, %ebx         # copy location = arg (assuming arg is top of stack)
leal 2(%edx), %ecx      # store addr of on_char to be copied
leal 2(%ebx), %eax      # store addr of on_char to copy to
movl (%ecx), %eax   # eax = addr(on_char) = M[ecx], copy on_char

leal 3(%edx), %ecx      
leal 3(%ebx), %eax      
movl (%ecx), %eax
leal 4(%edx), %ecx      
leal 4(%ebx), %eax      
movl (%ecx), %eax
leal 6(%edx), %ecx      
leal 6(%ebx), %eax      
movl (%ecx), %eax

leal 4(%edx), %ecx      
leal 8(%ebx), %eax      
movl (%ecx), %eax
    
leal 10(%ebx), %eax      
movl $1, %eax

    
leal 12(%ebx), %eax      
movl mp1_list_head, %eax
movl %ebx, mp1_list_head

popl %eax
popl %ecx
/*
movl 8(%ebx), %ebx      # move on lenth to ebx
movl 4(%ecx), %ebx      # countdown = on length
movl %ebx, 2(%eax)
movl 2(%ecx), %ebx        # on char = arg (on char)
movl %ebx, 3(%eax)
movl 3(%ecx), %ebx        # off char = arg(off char)
movl %ebx, 4(%eax)
movl 4(%ecx), %ebx        # on length = arg(on length)
movl %ebx, 6(%eax)
movl 6(%ecx), %ebx        # off length = arg (off length)
movl $1, 10(%eax)       # status = 1
movl %ebx, 12(%eax)
movl mp1_list_head, %ebx     # next = prev mp_list_head
movl %eax, mp1_list_head  # make struct head of list
*/
# popl %ebx
# call mp1_poke
# to use mp1_poke make call with :
# %eax offset from the start of video memory
# %cl ASCII code of character to write

movl %ebx, %eax
pushl %edx               # mp1_poke clobbers edx so save
movb 2(%ebx), %cl       # %cl = on char
call mp1_poke           # call mp1_poke  
popl %edx                # return edx

movl $0, %eax           # function successful, return 0

        ret
       
mp1_ioctl_remove:
# preserve regs
# call LL_SEARCH
# location to search for on top of stack
# result in eax, 0 for found, -1 if not found

# remove element from list before freeing

        ret
       
mp1_ioctl_find:
# takes ptr to struct
# validate that ptr points to an actual structure
# extract location from given struct
# search list for matching struct (LL_SEARCH, returns -1 in eax if not found, or location in eax if found)
# use mp1_copy_to_user to copy entire struct to the ptr at the beginning of the function
# if error (similar error handling to add) return -1, else return 0
        ret


mp1_ioctl_sync:
# arg is actually 2 2-byte arg's, 1st in upper 16 bits, 2nd in lower 16
# exract 2 arg's
# function sync's 2 existing locations on screen
# sync 2nd char to 1st char
# search linked list for both locations
# copy on_length, off_length, countdown, & status from 1 to 2
# call mp1_poke on either on_char or off_char (depending on status) for 2nd location
# return 0 on success and -1 on failure (similar error handling to add)
        ret


ERROR: # eax = -1
        movl $-1, %eax          # return -1
        # leave
        ret

ERROR_FREE: # error but memory needs to be freed
        pushl %eax       # push addr to free
        call mp1_free   # free memory
        popl %eax        # remove from stack
        movl $-1, %eax  # return -1
        ret

LL_SEARCH:      # linked list search function
# pass in location on stack from caller
# start at mp1_list_head
# if it matches return ebx in eax
# if next reaches NULL (0) return -1 in eax

# save regs
pushl %ebp              # save old base ptr
movl %esp, %ebp         # set stack frame, ebp = esp
# protect callee saved regs here (do all)
pushl %esi
pushl %ebx
pushl %ecx

/*
stack
--------------------------------
ecx             ebp -12
ebx             ebp -8
esi             ebp -4
--------------------------------
old ebp         ebp +- 0<- new ebp
arg             ebp + 4
old stack       ebp + 6
*/
movl 4(%ebp), %ecx              # pop location (to search for) from stack into ecx
movl mp1_list_head, %ebx        # move head of list to ebx
movl $-1, %eax                  # defult return value is -1, will be changed to 0 if found
jmp LOOP1       # jump to while loop

# tear down
popl %ecx
popl %ebx
popl %esi
        leave
        ret

LOOP1:  # loop for linked list search
        cmpl %ecx, %ebx         # compare location and list
        je FOUND                # they are equal so jump to found
        movl 12(%ebx), %ebx     # set ebx to the next location in the linked list
        cmpl $0, %ebx           # compare ebx to 0
        jne LOOP1               # if ebx != 0, continue loop
        ret                     # if ebx == 0, return

FOUND:
        movl %ebx, %eax           # set eax since the struct was found
        ret

jumptable:
        .long mp1_ioctl_add, mp1_ioctl_remove, mp1_ioctl_find, mp1_ioctl_sync
.end





