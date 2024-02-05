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
        pushl %ebp              # save old base ptr
        movl %esp, %ebp         # set stack frame, ebp = esp
        
        pushl %ebx
        pushl %esi
        pushl %edi
        xor %eax, %eax
        xor %ebx, %ebx
        xor %ecx, %ecx
        xor %edx, %edx
        xor %esi, %esi
        movl mp1_list_head, %esi        # move head of list to esi
        cmpl $0, %esi
        je TASKLET_LIST_DONE
        jmp TASKLET_LOOP                     # call loop that cycles through linked list
        popl %edi
        popl %esi
        popl %ebx
        leave
        ret

TASKLET_LOOP: # loop for tasklet
        # movl %edi, %esi
        cmpl $0, %esi                   # check if ptr to struct is NULL
        je TASKLET_LIST_DONE
        
        cmpw $0, COUNTDOWN(%esi)        # compare countdown to 0
        je TASKLET_COUNTDOWN_ZERO                         # if countdown is 0, jump
        # jl ERROR
        decl COUNTDOWN(%esi)            # decrement countdown
        # subl $1, COUNTDOWN(%esi)

        cmpw $0, COUNTDOWN(%esi)        # compare countdown to 0
        je TASKLET_COUNTDOWN_ZERO                         # if countdown is 0, jump

        movl NEXT(%esi), %esi           # go to next struct in list
        jne TASKLET_LOOP                      # if there is still more list, continue loop
        ret

TASKLET_COUNTDOWN_ZERO: # if countdown is 0
        cmpw $0, STATUS(%esi)       # compare status to 0
        je TASKLET_STATUS_OFF                  # if status is 0
        jne TASKLET_STATUS_ON                  # if status is 1

TASKLET_STATUS_OFF: # is status == 0
        movb ON_CHAR(%esi), %cl       # set cl to ON_CHAR
        movw LOCATION(%esi), %ax       # move LOCATION to eax
        imulw $2, %ax, %ax              # location *2
        pushl %esi
        pushl %edx
        call mp1_poke           # change character
        popl %edx
        popl %esi
        movw $1, STATUS(%esi)       # set STATUS to 1
        movw ON_LENGTH(%esi), %bx       # store ON_LENGTH in bx
        movw %bx, COUNTDOWN(%esi)      # set COUNTDOWN to ON_LENGTH
        movl NEXT(%esi), %esi     # go to NEXT struct in list
        cmpl $0, %esi                   # check if ptr to struct is NULL
        je TASKLET_LIST_DONE
        jmp TASKLET_LOOP              # if there is still more list, continue loop

TASKLET_STATUS_ON: # if status == 1
        movb OFF_CHAR(%esi), %cl       # set cl to OFF_CHAR
        movw LOCATION(%esi), %ax       # move LOCATION  to eax
        imulw $2, %ax, %ax              # location *2
        pushl %esi
        pushl %edx
        call mp1_poke           # change character
        popl %edx
        popl %esi
        movw $0, STATUS(%esi)       # set STATUS to 0
        movw OFF_LENGTH(%esi), %bx       # store OFF_LENGTH in bx
        movw %bx, COUNTDOWN(%esi)      # set COUNTDOWN to OFF_LENGTH
        movl NEXT(%esi), %esi     # go to NEXT struct in list
        cmpl $0, %esi                   # check if ptr to struct is NULL
        je TASKLET_LIST_DONE
        jmp TASKLET_LOOP              # if there is still more list, continue loop

TASKLET_LIST_DONE:
        popl %edi
        popl %esi
        popl %ebx
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

pushl %ebx
pushl %esi
pushl %edi

xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx


# if arg is 0, error
movl 8(%ebp), %edx      # get addr of arg (*from) from stack
# movl 32(%esp), %edx      # get addr of arg (*from) from stack
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
pushl 8(%ebp)       # push *from, arg
# pushl 36(%esp)       # push *from, arg
pushl %eax       # push *to, space allocated in malloc
call mp1_copy_from_user # copy struct from arg to memory allocated
popl %ecx
popl %ecx
popl %ecx

cmpl $0, %eax   # compare for checking if eax != 0, check if all memory was able to be copied
jne ERROR_FREE   # if eax != 0, error + free memory

movl 8(%ebp), %edx
# movl 32(%esp), %edx
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

        popl %edi
        popl %esi
        popl %ebx
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
pushl %ebp              # save old base ptr
movl %esp, %ebp         # set stack frame, ebp = esp
pushl %ebx
pushl %esi
pushl %edi
xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx

movw 8(%ebp), %bx       # get location from stack
# validate location
cmpw $1999, %bx        # check if location is < 80*25-1
jg ERROR           # if location > 80*25-1, error + free memory
cmpw $0, %bx        # check if location is > 0
jl ERROR           # if location < 0, error + free memory

# search linked list
pushl %ebx              # push location to stack for search
call LL_SEARCH          # call linked list search
popl %edi               # pop location off stack

movl %ecx, %esi         # move node before to esi, starts at 0
movl %edx, %edi              # move node to be removed to edi, starts at mp1_list_head
# check if location was found
cmpl $-1, %edi  # check if location was not found
je ERROR        # location not found, error
# movl %eax, %ecx # move addr of struct to ecx

# remove from list
cmpl mp1_list_head, %edi        # check if node found is head of list
je REMOVE_HEAD                  # if it is head jump to that removal
cmpl $0, %edi
je REMOVE_HEAD

movl NEXT(%edi), %ebx           # get next ptr from node to be removed
movl %ebx, NEXT(%esi)           # connect the nodes without node to be removed 

# free memory
pushl %edi
call mp1_free
popl %edi

# clean up      
        popl %edi
        popl %esi
        popl %ebx
        movl $0, %eax   # return 0
        leave
        ret

REMOVE_HEAD: # helper to remove node from linked list if it is the head
movl NEXT(%edi), %ebx
movl %ebx, mp1_list_head          # set new heas ptr

pushl %edi
call mp1_free                     # free memory
popl %edi
# clean up
        popl %edi
        popl %esi
        popl %ebx
        movl $0, %eax   # return 0
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
pushl %ebx
pushl %esi
pushl %edi
xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx

# validate ptr points to actual struct
movl 8(%ebp), %esi      # get addr of arg (*from) from stack
cmpl $0, %esi         # check if *from is 0
je ERROR                # if *from == 0, error

# get location
movw LOCATION(%esi), %bx
# pushl %edx      # push addr of struct to stack
# call GET_LOCATION       # get location (stored in eax)
# popl %edx       # take addr off stack

# error check location
cmpw $1999, %bx        # check if location is < 80*25-1
jg ERROR           # if location > 80*25-1, error + free memory
cmpw $0, %bx        # check if location is > 0
jl ERROR           # if location < 0, error + free memory

# search linked list
pushl %ebx              # push location to stack for search
call LL_SEARCH          # call linked list search
popl %ebx               # pop location off stack

# check if location was found
cmpl $-1, %edx  # check if location was not found
je ERROR        # location not found, error
movl %edx, %edi # move addr of struct to ebx

# copy to user
movl 8(%ebp), %esi
pushl $16       # push n (size to copy)
pushl %edi       # push *from, addr of struct with matching location
pushl %esi       # push *to, addr that was passed in
call mp1_copy_to_user
popl %edi
popl %edi
popl %edi

cmpl $0, %eax   # compare for checking if eax != 0, check if all memory was able to be copied
jne ERROR   # if eax != 0, error + free memory

# clean up
        popl %edi
        popl %esi
        popl %ebx
        # popl %ebp
        movl $0, %eax
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
pushl %esi
pushl %edi
xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx

movl 4(%ebp), %edx      # get addr of struct from stack

cmpl $0, %edx         # check if *from is 0
je ERROR                # if *from == 0, error

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

pushl %ebx
call mp1_free  # free memory
popl %ebx
# clean up
        popl %edi
        popl %esi
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

pushl %ebp              # save old base ptr
movl %esp, %ebp         # set stack frame, ebp = esp
pushl %ebx
pushl %esi
pushl %edi
xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx

# get arg
movl 8(%ebp), %esi      # get arg from stack
# get location 1 & validate
movl %esi, %ebx         # move 
shr $16, %ebx           # roate 16 bits to get location 1 from upper 16 bits
cmpw $1999, %bx        # check if location 1 is < 80*25-1
jg ERROR           # if location 1 > 80*25-1, error
cmpw $0, %bx        # check if location 1 is > 0
jl ERROR           # if location 1 < 0, error 

# search for 1st location in linked list
pushl %ebx              # push location to stack for search
call LL_SEARCH          # call linked list search
popl %edi               # pop location off stack
movl %edx, %edi         # store addr of struct 1 in ebx
cmpl $-1, %edi
je ERROR

# get location 2 & validate
movl 8(%ebp), %ebx          # get location 2 from lower 16 bits
andl $0x0000FFFF, %ebx            # zero out top 16 bits
cmpw $1999, %bx        # check if location 2 is < 80*25-1
jg ERROR           # if location 2 > 80*25-1, error + free memory
cmpw $0, %bx        # check if location 2 is > 0
jl ERROR          # if location 2 < 0, error + free memory

# search for 2nd location in linked list
pushl %edi
pushl %ebx              # push location to stack for search
call LL_SEARCH          # call linked list search
popl %edi               # pop location off stack
popl %edi
movl %edx, %esi         # store addr of struct 2 in ecx
cmpl $-1, %esi
je ERROR

# copy timing info (on_length, off_length, countdown, status) from 1st to 2nd
movw ON_LENGTH(%edi), %bx        # get ON_LENGTH from 1 
movw %bx, ON_LENGTH(%esi)        # copy ON_LENGTH to 2

movw OFF_LENGTH(%edi), %bx      # get OFF_LENGTH from 1
movw %bx, OFF_LENGTH(%esi)      # copy OFF_LENGTH to 2

movw COUNTDOWN(%edi), %bx       # get COUNTDOWN from 1
movw %bx, COUNTDOWN(%esi)       # copy COUNTDOWN to 2

movw STATUS(%edi), %bx       # get STATUS from 1
movw %bx, STATUS(%esi)       # copy STATUS to 2

# call mp1_poke on ON_CHAR or OFF_CHAR depending on STATUS
cmpw $0, STATUS(%esi)       # compare status to 0
je SYNC_STATUS_OFF                  # if status is 0
jne SYNC_STATUS_ON                  # if status is 1

        popl %edi
        popl %esi
        popl %ebx
        # popl %ebp
        ret


SYNC_STATUS_ON:         # status is on (=1) for 2nd location in sync
        movb ON_CHAR(%esi), %cl       # set cl to ON_CHAR
        movw LOCATION(%esi), %ax       # move LOCATION to eax
        imulw $2, %ax, %ax              # location *2
        pushl %edx
        call mp1_poke           # change character
        popl %edx
# clean up
        popl %edi
        popl %esi
        popl %ebx
        movl $0, %eax           # return 0 on success
        leave 
        ret

SYNC_STATUS_OFF:        # status is off (=0) for 2nd location in sync
        movb OFF_CHAR(%esi), %cl       # set cl to ON_CHAR
        movw LOCATION(%esi), %ax       # move LOCATION to eax
        imulw $2, %ax, %ax              # location *2
        pushl %edx
        call mp1_poke           # change character
        popl %edx
# clean up
        popl %edi
        popl %esi
        popl %ebx
        movl $0, %eax           # return 0 on success
        leave 
        ret

ERROR: # eax = -1
        popl %edi
        popl %esi
        popl %ebx
        # popl %ebp
        movl $-1, %eax          # return -1
        leave
        ret

ERROR_FREE: # error but memory needs to be freed
        pushl %ebx       # push addr to free
        call mp1_free   # free memory
        popl %ebx        # remove from stack
# clean up
        popl %edi
        popl %esi
        popl %ebx
        # popl %ebp
        movl $-1, %eax  # return -1
        leave
        ret

LL_SEARCH:      # linked list search function
# pass in location on stack from caller
# start at mp1_list_head
# if it matches return addr in eax
# if next reaches NULL (0) return -1 in eax
# returns addr of list item before in ecx
# save regs
pushl %ebp              # save old base ptr
movl %esp, %ebp         # set stack frame, ebp = esp
# protect callee saved regs here (do all)
# pushl %ebx
pushl %ebx
pushl %esi
pushl %edi
xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx
/*
stack
--------------------------------
edi
esi             ebp -8
ebx             ebp -4
old ebp         ebp +- 0<- new ebp
--------------------------------
return ptr      ebp +4
location        ebp + 8
old stack       ebp + 12
*/
movl 8(%ebp), %ebx              # pop location (to search for) from stack into bx
movl mp1_list_head, %esi        # move head of list to ebx
movl $0, %edi                   # previous list item starts at NULL
movl $-1, %edx                  # defult return value is -1, will be changed to 0 if found
cmpl $0, %esi
jne LOOP1       # jump to while loop

# tear down
        popl %edi
        popl %esi
        popl %ebx
        
        # popl %ebp
        movl $-1, %ecx  # not found, %ecx = -1
        leave
        ret

LOOP1:  # loop for linked list search
        cmpw %bx, LOCATION(%esi)         # compare location and location from list
        je FOUND                # they are equal so jump to found
        movl %esi, %edi         # move what is now previous location to edx
        movl NEXT(%esi), %esi     # go to NEXT struct in list
        cmpl $0, %esi           # compare addr of node to 0
        jne LOOP1               # if ebx != 0, continue loop
        je NOT_FOUND                    # if ebx == 0, aka end of linked list return

FOUND:
        movl %esi, %edx           # addr of node
        movl %edi, %ecx                 # addr of node before
        # clean up
        popl %edi
        popl %esi
        popl %ebx
        # popl %ebp
        leave
        ret
        
NOT_FOUND:
popl %edi
        popl %esi
        popl %ebx
        
        # popl %ebp
        movl $-1, %ecx  # not found, %ecx = -1
        leave
        ret

jumptable:
        .long mp1_ioctl_add, mp1_ioctl_remove, mp1_ioctl_find, mp1_ioctl_sync
.end





