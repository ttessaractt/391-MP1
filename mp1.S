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
        pushl %eax
        pushl %ebx
        pushl %ecx
        pushl %edx
        xor %eax, %eax
        xor %ebx, %ebx
        xor %ecx, %ecx
        xor %edx, %edx
        movl mp1_list_head, %edx        # move head of list to esi
        cmpl $0, %edx
        je TASKLET_LIST_DONE
        call TASKLET_LOOP                     # call loop that cycles through linked list
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        leave
        ret

TASKLET_LOOP: # loop for tasklet
        cmpl $0, %edx                   # check if ptr to struct is NULL
        je TASKLET_LIST_DONE

        cmpw $0, COUNTDOWN(%edx)        # compare countdown to 0
        je TASKLET_COUNTDOWN_ZERO                         # if countdown is 0, jump
        decw COUNTDOWN(%edx)            # decrement countdown
        cmpw $0, COUNTDOWN(%edx)        # compare countdown to 0
        je TASKLET_COUNTDOWN_ZERO                         # if countdown is 0, jump
        movl NEXT(%edx), %edx           # go to next struct in list
        jne TASKLET_LOOP                      # if there is still more list, continue loop

TASKLET_COUNTDOWN_ZERO: # if countdown is 0
        cmpw $0, STATUS(%edx)       # compare status to 0
        je TASKLET_STATUS_OFF                  # if status is 0
        jne TASKLET_STATUS_ON                  # if status is 1

TASKLET_STATUS_OFF: # is status == 0
        movb ON_CHAR(%edx), %cl       # set cl to ON_CHAR
        movw LOCATION(%edx), %ax       # move LOCATION to eax
        imulw $2, %ax, %ax              # location *2
        pushl %edx
        call mp1_poke           # change character
        popl %edx
        movw $1, STATUS(%edx)       # set STATUS to 1
        movw ON_LENGTH(%edx), %bx       # store ON_LENGTH in bx
        movw %bx, COUNTDOWN(%edx)      # set COUNTDOWN to ON_LENGTH
        movl NEXT(%edx), %edx     # go to NEXT struct in list
        jmp TASKLET_LOOP              # if there is still more list, continue loop

TASKLET_STATUS_ON: # if status == 1
        movb OFF_CHAR(%edx), %cl       # set cl to OFF_CHAR
        movw LOCATION(%edx), %ax       # move LOCATION  to eax
        imulw $2, %ax, %ax              # location *2
        pushl %edx
        call mp1_poke           # change character
        popl %edx
        movw $0, STATUS(%edx)       # set STATUS to 0
        movw OFF_LENGTH(%edx), %bx       # store OFF_LENGTH in bx
        movw %bx, COUNTDOWN(%edx)      # set COUNTDOWN to OFF_LENGTH
        movl NEXT(%edx), %edx     # go to NEXT struct in list
        jmp TASKLET_LOOP              # if there is still more list, continue loop

TASKLET_LIST_DONE:
        # popl %eax       # remove return addr
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        leave
        ret

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
| edx
| ecx
| ebx
| eax
| old ebp       %ebp+-0  |   
-------------------------- 
| return address %ebp+4  |
| arg            %ebp+8  |
| command number %ebp+12 |
| old stack      %ebp+16 | <- old EBP
*/
pushl %ebp              # save old base ptr
movl %esp, %ebp         # set stack frame, ebp = esp

pushl %eax
pushl %ebx
pushl %ecx
pushl %edx
xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx


# if arg is 0, error
movl 24(%esp), %edx      # get addr of arg (*from) from stack
cmpl $0, %edx         # check if *from is 0
je ERROR                # if *from == 0, error

# allocate memory
pushl $16        # push size to stack
call mp1_malloc # call malloc, void ptr for memory allocated stored in %eax
popl %ecx
cmpl $0, %eax         # check if eax is NULL, check if pointer (not what it points to) is NULL (aka 0)
je ERROR                # memory wasnt able to be allocated, error


# copy struct

movl %eax, %ebx         # save eax (*to) in ebx, ebx = eax = (*to)
pushl $16       # push n (size to copy)
pushl 28(%esp)       # push *from, arg
pushl %eax       # push *to, space allocated in malloc
call mp1_copy_from_user # copy struct from arg to memory allocated
popl %ecx
popl %ecx
popl %ecx

cmpl $0, %eax   # compare for checking if eax != 0, check if all memory was able to be copied
jne ERROR_FREE   # if eax != 0, error + free memory

movl 24(%esp), %edx
movw LOCATION(%edx), %ax
cmpw $1999, %ax        # check if location is < 80*25-1
jg ERROR_FREE           # if location > 80*25-1, error + free memory

cmpw $0, %ax        # check if location is > 0
jl ERROR_FREE           # if location < 0, error + free memory

pushl %ecx      # save ecx
/*
copy struct
%ebx = ptr to new struct
%ecx = temp varible
%edx = ptr to old struct
*/
movw %ax, LOCATION(%ebx)        # copy LOCATION to new struct  

movb ON_CHAR(%edx), %cl         # get ON_CHAR from old struct
movb %cl, ON_CHAR(%ebx)         # copy ON_CHAR to new struct

movb OFF_CHAR(%edx), %cl        # get OFF_CHAR from old struct
movb %cl, OFF_CHAR(%ebx)        # copy OFF_CHAR to new struct

movw ON_LENGTH(%edx), %cx        # get ON_LENGTH from old struct
movw %cx, ON_LENGTH(%ebx)        # copy ON_LENGTH to new struct

movw OFF_LENGTH(%edx), %cx      # get OFF_LENGTH from old struct
movw %cx, OFF_LENGTH(%ebx)      # copy OFF_LENGTH to new struct

movw ON_LENGTH(%edx), %cx       # get ON_LENGTH from old struct
movw %cx, COUNTDOWN(%ebx)       # copy COUNTDOWN to new struct
   
movw $1, STATUS(%ebx)           # set STATUS in new struct to 1

# add new struct to linked list
movl mp1_list_head, %edi        # get old mp1_list_head
movl %edi, NEXT(%ebx)           # set NEXT to the old  mp1_list_head

# change head of list
movl %ebx, mp1_list_head        # set new mp1_list_head

popl %ecx

# call mp1_poke
pushl %edx               # mp1_poke clobbers edx so save

movb ON_CHAR(%ebx), %cl       # %cl = on char
imulw $2, %ax, %ax              # location *2

call mp1_poke           # call mp1_poke  
popl %edx                # return edx

        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        # popl %ebp
        movl $0, %eax           # function successful, return 0
        leave
        ret
       
mp1_ioctl_remove:
# preserve regs
# call LL_SEARCH
# location to search for on top of stack
# result in eax, 0 for found, -1 if not found

# remove element from list before freeing
        leave
        ret
       
mp1_ioctl_find:
# takes ptr to struct
# validate that ptr points to an actual structure
# extract location from given struct
        # malloc struct
        # copy_from_user
        # get location
        # free memory
# search list for matching struct (LL_SEARCH, returns -1 in eax if not found, or location in eax if found)
# use mp1_copy_to_user to copy entire struct to the ptr at the beginning of the function
# if error (similar error handling to add) return -1, else return 0




pushl %ebp              # save old base ptr
movl %esp, %ebp         # set stack frame, ebp = esp
pushl %eax
pushl %ebx
pushl %ecx
pushl %edx
xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx

# validate ptr points to actual struct
movl 4(%ebp), %edx      # get addr of arg (*from) from stack
cmpl $0, %edx         # check if *from is 0
je ERROR                # if *from == 0, error

# get location
pushl %edx      # push addr of struct to stack
call GET_LOCATION       # get location (stored in eax)
popl %edx       # take addr off stack

# error check location
cmpw $1999, %ax        # check if location is < 80*25-1
jg ERROR           # if location > 80*25-1, error + free memory
cmpw $0, %ax        # check if location is > 0
jl ERROR           # if location < 0, error + free memory

# search linked list
pushl %eax              # push location to stack for search
call LL_SEARCH          # call linked list search
popl %ecx               # pop location off stack

# check if location was found
cmpl $-1, %eax  # check if location was not found
je ERROR        # location not found, error
movl %eax, %ebx # move addr of struct to ebx

# copy to user
pushl $16       # push n (size to copy)
pushl %eax       # push *from, addr of struct with matching location
pushl %edx       # push *to, addr that was passed in
call mp1_copy_to_user
popl %ecx
popl %ecx
popl %ecx

cmpl $0, %eax   # compare for checking if eax != 0, check if all memory was able to be copied
jne ERROR   # if eax != 0, error + free memory

# clean up
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        popl %ebp
        leave
        ret

GET_LOCATION: # helper function to get location from struct in user space
# takes addr of struct from stack (pushed in caller)
# returns location from struct (in %ax)
/*
%eax = 
%ebx =
%ecx = garbage
%edx = addr of struct
*/
# extract location from given struct
        # malloc struct
        # copy_from_user
        # get location
        # free memory
pushl %ebp              # save old base ptr
movl %esp, %ebp         # set stack frame, ebp = esp
# pushl %eax
pushl %ebx
pushl %ecx
pushl %edx
xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx

movl 4(%ebp), %edx      # get addr of struct from stack

# malloc struct
pushl $16        # push size to stack
call mp1_malloc # call malloc, void ptr for memory allocated stored in %eax
popl %ecx
cmpl $0, %eax         # check if eax is NULL, check if pointer (not what it points to) is NULL (aka 0)
je ERROR                # memory wasnt able to be allocated, error

# copy struct
movl %eax, %ebx         # save eax (*to) in ebx, ebx = eax = (*to)
pushl $16       # push n (size to copy)
pushl %edx       # push *from, arg
pushl %eax       # push *to, space allocated in malloc
call mp1_copy_from_user # copy struct from arg to memory allocated
popl %ecx
popl %ecx
popl %ecx

cmpl $0, %eax   # compare for checking if eax != 0, check if all memory was able to be copied
jne ERROR_FREE   # if eax != 0, error + free memory

movw LOCATION(%edx), %ax        # get location

call mp1_free(%ebx)  # free memory
# clean up
        popl %edx
        popl %ecx
        popl %ebx
        # popl %eax
        # popl %ebp
        leave
        ret

mp1_ioctl_sync:
# log arg (passed in) is actually 2 short (2-byte) arg's, 1st in upper 16 bits, 2nd in lower 16
# exract 2 arg's
# function sync's 2 existing locations on screen
# sync 2nd char to 1st char
# search linked list for both locations
# copy on_length, off_length, countdown, & status from 1 to 2
# call mp1_poke on either on_char or off_char (depending on status) for 2nd location
# return 0 on success and -1 on failure (similar error handling to add)

# location 1 = %cx
# location 2 = %bx

pushl %ebp              # save old base ptr
movl %esp, %ebp         # set stack frame, ebp = esp
pushl %eax
pushl %ebx
pushl %ecx
pushl %edx
xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx
# get arg
movl 4(%ebp), %edx      # get arg from stack
# get location 1 & validate
movl %edx, %ecx         # move 
shr $16, %ecx           # roate 16 bits to get location 1 from upper 16 bits
cmpw $1999, %cx        # check if location 1 is < 80*25-1
jg ERROR           # if location 1 > 80*25-1, error + free memory
cmpw $0, %cx        # check if location 1 is > 0
jl ERROR           # if location 1 < 0, error + free memory

# get location 2 & validate
movw %dx, %bx          # get location 2 from lower 16 bits
cmpw $1999, %bx        # check if location 2 is < 80*25-1
jg ERROR           # if location 2 > 80*25-1, error + free memory
cmpw $0, %bx        # check if location 2 is > 0
jl ERROR          # if location 2 < 0, error + free memory

# search for 1st location in linked list
pushl %ecx              # push location to stack for search
call LL_SEARCH          # call linked list search
popl %edx               # pop location off stack
movl %eax, %ecx         # store addr of struct 1 in ebx

# search for 2nd location in linked list
pushl %ebx              # push location to stack for search
call LL_SEARCH          # call linked list search
popl %edx               # pop location off stack
movl %eax, %ebx         # store addr of struct 2 in ecx

# copy timing info (on_length, off_length, countdown, status) from 1st to 2nd
movw ON_LENGTH(%ecx), %dx        # get ON_LENGTH from 1 
movw %dx, ON_LENGTH(%ebx)        # copy ON_LENGTH to 2

movw OFF_LENGTH(%ecx), %dx      # get OFF_LENGTH from 1
movw %dx, OFF_LENGTH(%ebx)      # copy OFF_LENGTH to 2

movw COUNTDOWN(%ecx), %dx       # get COUNTDOWN from 1
movw %dx, COUNTDOWN(%ebx)       # copy COUNTDOWN to 2

movw STATUS(%ecx), %dx       # get STATUS from 1
movw %dx, STATUS(%ebx)       # copy STATUS to 2

# call mp1_poke on ON_CHAR or OFF_CHAR depending on STATUS
cmpw $0, STATUS(%ebx)       # compare status to 0
je SYNC_STATUS_OFF                  # if status is 0
jne SYNC_STATUS_ON                  # if status is 1

        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        # popl %ebp
        ret


SYNC_STATUS_ON:         # status is on (=1) for 2nd location in sync
        movb ON_CHAR(%ebx), %cl       # set cl to ON_CHAR
        movw LOCATION(%ebx), %ax       # move LOCATION to eax
        imulw $2, %ax, %ax              # location *2
        pushl %edx
        call mp1_poke           # change character
        popl %edx

        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        # popl %ebp
        leave 
        ret

SYNC_STATUS_OFF:        # status is off (=0) for 2nd location in sync
        movb OFF_CHAR(%ebx), %cl       # set cl to ON_CHAR
        movw LOCATION(%ebx), %ax       # move LOCATION to eax
        imulw $2, %ax, %ax              # location *2
        pushl %edx
        call mp1_poke           # change character
        popl %edx

        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        # popl %ebp
        leave 
        ret

ERROR: # eax = -1
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        # popl %ebp
        movl $-1, %eax          # return -1
        leave
        ret

ERROR_FREE: # error but memory needs to be freed
        pushl %ebx       # push addr to free
        call mp1_free   # free memory
        popl %ebx        # remove from stack
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        # popl %ebp
        movl $-1, %eax  # return -1
        leave
        ret

LL_SEARCH:      # linked list search function
# pass in location on stack from caller
# start at mp1_list_head
# if it matches return addr in eax
# if next reaches NULL (0) return -1 in eax

# save regs
pushl %ebp              # save old base ptr
movl %esp, %ebp         # set stack frame, ebp = esp
# protect callee saved regs here (do all)
pushl %ebx
pushl %ecx
pushl %edx
xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx
/*
stack
--------------------------------
edx             ebp -12
ecx             ebp -8
ebx             ebp -4
--------------------------------
old ebp         ebp +- 0<- new ebp
location        ebp + 4
old stack       ebp + 6
*/
movw 4(%ebp), %cx              # pop location (to search for) from stack into cx
movl mp1_list_head, %ebx        # move head of list to ebx
movl $-1, %eax                  # defult return value is -1, will be changed to 0 if found
jmp LOOP1       # jump to while loop

# tear down
        popl %edx
        popl %ecx
        popl %ebx
        # popl %ebp
        movl $-1, %ebx  # not found, %ebx = -1
        leave
        ret

LOOP1:  # loop for linked list search
        cmpw %cx, LOCATION(%ebx)         # compare location and location from list
        je FOUND                # they are equal so jump to found
        movl NEXT(%ebx), %ebx     # go to NEXT struct in list
        cmpl $0, %ebx           # compare ebx to 0
        jne LOOP1               # if ebx != 0, continue loop
        ret                     # if ebx == 0, aka end of linked list return

FOUND:
        movl %ebx, %eax           # set eax since the struct was found
        popl %edx
        popl %ecx
        popl %ebx
        # popl %ebp
        leave
        ret

jumptable:
        .long mp1_ioctl_add, mp1_ioctl_remove, mp1_ioctl_find, mp1_ioctl_sync
.end





