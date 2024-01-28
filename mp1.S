
.data					# section declaration

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

.text					# section declaration

# Export the function symbol names

.global mp1_rtc_tasklet
.global mp1_ioctl

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
	ret

mp1_ioctl:      # dispacher function
#  uses cmd to determine which of the 4 functions to jump to
# int mp1_ioctl (unsigned long arg, unsigned long cmd)
pushl %ebp              # save old base ptr
movl %esp, %ebp         # set stack frame, ebp = esp

# protect callee saved regs here (do all)
pushl %esi
/*
| %esi          %ebp -4|
| %ebp          %ebp +-0|
-------------------------- 
| return address %ebp+4 | <- ESP (at start)
| arg            %ebp+8  | 
| command number %ebp+12 |
| old stack      %ebp+16 | 
*/
# move cmd from stack to register
movl 8(%esp), %esi      # move cmd from stack to esi
# compare to check if <0 or >3
cmpl $3, %esi           # if esi > 3
jg ERROR              # if esi > 3 jump to default (unsigned)
cmpl $0, %esi           # if esi < 0
jl ERROR              # if esi < 0 jump to default (unsigned)
# jmp *jumptable(,%esi,4) # jumps to core functions based on esi (cmd)
# set esp to jumptable *jumptable(,%esi,4)
        # jump table
        # arg will be first on stack it is ready to use by core functions
movl (*jumptable(,%esi,4)), 4(%ebp)        # store the label (based on cmd) in return address
popl %esi       # restore stack
popl %ebp       # restore stack
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
# call mp1_poke (with correct parameters)

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
/*
-------------------------- callee (?)
| %esi          %ebp-4   |
| %ebp           %ebp+-0  |
-------------------------- caller
| return address %ebp+4  | <- ESP (at start)
| arg            %ebp+8  | 
| command number %ebp+12 |
| old stack      %ebp+16 | <- old EBP
*/
# push caller preserved
# malloc: void* mp1_malloc(unsigned long size), size = 16 (?)
# copy: unsigned long mp1_copy_from_user (void *to, const void *from, unsigned long n)

push $16        # push size to stack
call mp1_malloc # call malloc
# if eax = NULL return -1
add $4, %esp    # clean up stack, remove 16 

# copy struct
# if eax != 0, return -1
# if arg (location) not in bounds, return -1
# add struct values

	ret
        
mp1_ioctl_remove:
	ret
        
mp1_ioctl_find:
	ret

mp1_ioctl_sync:
	ret

ERROR: # eax = -1
        ret

jumptable:
        .long mp1_ioctl_add, mp1_ioctl_remove, mp1_ioctl_find, mp1_ioctl_sync
.end
