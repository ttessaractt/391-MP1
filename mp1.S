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

/*
void mp1_rtc_tasklet(unsigned long):

Interface: C calling convention
  Inputs: mp1_list_head - ptr to head of linked list
  Outputs: none
Registers: %ebx - holder for value to copy
           %esi - address of current node in the linked list
*/
mp1_rtc_tasklet:
        # callee sequence
        pushl %ebp              
        movl %esp, %ebp         
        pushl %ebx
        pushl %esi
        pushl %edi
        xor %eax, %eax
        xor %ebx, %ebx
        xor %ecx, %ecx
        xor %edx, %edx
        xor %esi, %esi
        movl mp1_list_head, %esi       
        cmpl $0, %esi
        je TASKLET_LIST_DONE
        jmp TASKLET_LOOP                     
        popl %edi
        popl %esi
        popl %ebx
        leave
        ret

/*
helper function for mp1_rtc_tasklet
decrements countdown, moves to next node
*/
TASKLET_LOOP:
        cmpl $0, %esi                   
        je TASKLET_LIST_DONE
        cmpw $0, COUNTDOWN(%esi)        
        je TASKLET_COUNTDOWN_ZERO                         
        decl COUNTDOWN(%esi)            
        cmpw $0, COUNTDOWN(%esi)        
        je TASKLET_COUNTDOWN_ZERO                        
        movl NEXT(%esi), %esi           
        jne TASKLET_LOOP                      
        ret

# called if COUNTDOWN == 0:
TASKLET_COUNTDOWN_ZERO: 
        cmpw $0, STATUS(%esi)       
        je TASKLET_STATUS_OFF               
        jne TASKLET_STATUS_ON                 

# called if COUNTDOWN =+ 0 && STATUS == 0
#       change relevant struct values
TASKLET_STATUS_OFF: 
        # update char
        movb ON_CHAR(%esi), %cl       
        movw LOCATION(%esi), %ax      
        imulw $2, %ax, %ax             
        pushl %esi
        pushl %edx
        call mp1_poke          
        popl %edx
        popl %esi
        # update struct
        movw $1, STATUS(%esi)       
        movw ON_LENGTH(%esi), %bx       
        movw %bx, COUNTDOWN(%esi)     
        movl NEXT(%esi), %esi     
        cmpl $0, %esi                   
        je TASKLET_LIST_DONE
        jmp TASKLET_LOOP              

# called if COUNTDOWN == 0 && STATUS == 1
#       change relevant struct values
TASKLET_STATUS_ON: 
        # update char
        movb OFF_CHAR(%esi), %cl       
        movw LOCATION(%esi), %ax       
        imulw $2, %ax, %ax              
        pushl %esi
        pushl %edx
        call mp1_poke          
        popl %edx
        popl %esi
        # update struct
        movw $0, STATUS(%esi)       
        movw OFF_LENGTH(%esi), %bx       
        movw %bx, COUNTDOWN(%esi)     
        movl NEXT(%esi), %esi     
        cmpl $0, %esi                  
        je TASKLET_LIST_DONE
        jmp TASKLET_LOOP              

# return callee-saved regs once the entire list has been visited
TASKLET_LIST_DONE:
        # clean up
        popl %edi
        popl %esi
        popl %ebx
        leave
        ret

/*
int mp1_ioctl(unsigned long arg, unsigned long cmd):

Interface: C calling convention
  Inputs: cmd - used to determine which ioctl call to make 
  Outputs: none
Registers: %eax - holder of the cmd variable used to determine ioctl call  
*/
mp1_ioctl:     
        movl 8(%esp), %eax     
        cmpl $3, %eax           
        ja ERROR              
        cmpl $0, %eax           
        jb ERROR             
        jmp *jumptable(,%eax,4)
        ret    

/*
int mp1_ioctl_add(unsigned long arg):

Interface: C calling convention
  Inputs: arg (from stack) - user level ptr to a structure
  Outputs: %eax = 0 - add succeded, struct successfully added to head of linked list
           %eax = -1 - add failed, struct was not able to be added to list/error
Registers: %eax - hold LOCATION/hold return values from function
           %ebx - ptr to new struct
           %edx - arg, ptr to struct that will be copied
           %ecx - holder for value to copy/garbage
*/
mp1_ioctl_add: 
        # callee sequence
        pushl %ebp              
        movl %esp, %ebp         
        pushl %ebx
        pushl %esi
        pushl %edi
        xor %eax, %eax
        xor %ebx, %ebx
        xor %ecx, %ecx
        xor %edx, %edx
        # NULL arg error checking
        movl 8(%ebp), %edx     
        cmpl $0, %edx        
        je ERROR              
        # allocate memory
        pushl $16       
        call mp1_malloc 
        popl %ecx
        cmpl $0, %eax         
        je ERROR                
        # copy struct + error checking
        movl %eax, %ebx         
        pushl $16    
        pushl 8(%ebp)   
        pushl %eax      
        call mp1_copy_from_user
        popl %ecx
        popl %ecx
        popl %ecx
        cmpl $0, %eax   
        jne ERROR_FREE   
        # get LOCATION + error checking
        movl 8(%ebp), %edx
        movw LOCATION(%edx), %ax
        cmpw $1999, %ax       
        jg ERROR_FREE          
        cmpw $0, %ax       
        jl ERROR_FREE           
        # copy values over to new struct
        pushl %ecx   
        movw %ax, LOCATION(%ebx)       
        movb ON_CHAR(%edx), %cl        
        movb %cl, ON_CHAR(%ebx)         
        movb OFF_CHAR(%edx), %cl      
        movb %cl, OFF_CHAR(%ebx)                
        movw ON_LENGTH(%edx), %cx        
        movw %cx, ON_LENGTH(%ebx)        
        movw OFF_LENGTH(%edx), %cx      
        movw %cx, OFF_LENGTH(%ebx)     
        movw ON_LENGTH(%edx), %cx      
        movw %cx, COUNTDOWN(%ebx)       
        movw $1, STATUS(%ebx)         
        movl mp1_list_head, %edi     
        movl %edi, NEXT(%ebx)           
        movl %ebx, mp1_list_head       
        popl %ecx
        # display character
        pushl %edx             
        movb ON_CHAR(%ebx), %cl      
        imulw $2, %ax, %ax           
        call mp1_poke        
        popl %edx               
        popl %edi
        popl %esi
        popl %ebx
        movl $0, %eax         
        leave
        ret

/*
int mp1_ioctl_remove(unsigned long arg):

Interface: C calling convention
  Inputs: arg (from stack) - integer LOCATION
  Outputs: %eax = 0 - removal success, location found in list and corresponding node removed
           %eax = -1 - removal failed, location not found/error
Registers: %ebx - hold LOCATION to be searched for, intermediate var
           %esi - hold ptr to the node before the node at LOCATION (from LL_SEARCH)
           %edi -  hold ptr to the node at LOCATION (from LL_SEARCH)
*/       
mp1_ioctl_remove:
        # callee sequence
        pushl %ebp              
        movl %esp, %ebp        
        pushl %ebx
        pushl %esi
        pushl %edi
        xor %eax, %eax
        xor %ebx, %ebx
        xor %ecx, %ecx
        xor %edx, %edx
        # get LOCATION + error checking
        movw 8(%ebp), %bx      
        cmpw $1999, %bx       
        jg ERROR           
        cmpw $0, %bx        
        jl ERROR          
        # call linked list search function + error checking
        pushl %ebx              
        call LL_SEARCH         
        popl %edi               
        movl %ecx, %esi        
        movl %edx, %edi             
        cmpl $-1, %edi  
        je ERROR        
        # check if node to be removed is head of list
        cmpl mp1_list_head, %edi        
        je REMOVE_HEAD                  
        cmpl $0, %edi
        je REMOVE_HEAD
        # remove node not at head of list + free memory
        movl NEXT(%edi), %ebx           
        movl %ebx, NEXT(%esi)         
        pushl %edi
        call mp1_free
        popl %edi
        # clean up      
        popl %edi
        popl %esi
        popl %ebx
        movl $0, %eax  
        leave
        ret

# helper function to remove + free node at head of linked list
REMOVE_HEAD: 
        movl NEXT(%edi), %ebx
        movl %ebx, mp1_list_head         
        pushl %edi
        call mp1_free                    
        popl %edi
        # clean up
        popl %edi
        popl %esi
        popl %ebx
        movl $0, %eax  
        leave
        ret

/*
int mp1_ioctl_find(unsigned long arg):

Interface: C calling convention
  Inputs: arg (from stack) - ptr to a structure, only concerned with LOCATION
  Outputs: %eax = 0 - matching LOCATION found found in linked list
           %eax = -1 - no matching LOCATION in linked list
Registers: %ebx - hold LOCATION to search for
           %esi - hold ptr to struct
           %edi - hold ptr to struct with matching LOCATION
*/ 
mp1_ioctl_find:
        # callee sequence
        pushl %ebp              
        movl %esp, %ebp         
        pushl %ebx
        pushl %esi
        pushl %edi
        xor %eax, %eax
        xor %ebx, %ebx
        xor %ecx, %ecx
        xor %edx, %edx
        # get arg from stack + error checking
        movl 8(%ebp), %esi    
        cmpl $0, %esi         
        je ERROR             
        # get LOCATION + error checking
        movw LOCATION(%esi), %bx
        cmpw $1999, %bx      
        jg ERROR           
        cmpw $0, %bx       
        jl ERROR          
        # call search linked list + error checking
        pushl %ebx             
        call LL_SEARCH          
        popl %ebx              
        cmpl $-1, %edx  
        je ERROR      
        movl %edx, %edi 
        # copy to user + error checking
        movl 8(%ebp), %esi
        pushl $16     
        pushl %edi      
        pushl %esi       
        call mp1_copy_to_user
        popl %edi
        popl %edi
        popl %edi
        cmpl $0, %eax  
        jne ERROR   
        # clean up
        popl %edi
        popl %esi
        popl %ebx
        movl $0, %eax
        leave
        ret

/*
int mp1_ioctl_sync(unsigned long arg):

Interface: C calling convention
  Inputs: arg (from stack) - 2 (2-byte) integers of LOCATION's on screen to sync
  Outputs: %eax = 0 - 2 LOCATION's were synched
           %eax = -1 - 2 LOCATION's were not able to be synched
Registers: %ebx - 
           %esi - 
           %edi -  
*/ 
mp1_ioctl_sync:
        # callee sequence
        pushl %ebp              
        movl %esp, %ebp         
        pushl %ebx
        pushl %esi
        pushl %edi
        xor %eax, %eax
        xor %ebx, %ebx
        xor %ecx, %ecx
        xor %edx, %edx
        # get arg + 1st location + error checking
        movl 8(%ebp), %esi     
        movl %esi, %ebx       
        shr $16, %ebx          
        cmpw $1999, %bx       
        jg ERROR          
        cmpw $0, %bx       
        jl ERROR           
        # search for 1st location in linked list + error checking
        pushl %ebx              
        call LL_SEARCH          
        popl %edi               
        movl %edx, %edi         
        cmpl $-1, %edi
        je ERROR
        # get 2nd location + error checking
        movl 8(%ebp), %ebx         
        andl $0x0000FFFF, %ebx            
        cmpw $1999, %bx        
        jg ERROR           
        cmpw $0, %bx       
        jl ERROR          
        # search for 2nd location in linked list + error checking
        pushl %edi
        pushl %ebx              
        call LL_SEARCH          
        popl %edi               
        popl %edi
        movl %edx, %esi        
        cmpl $-1, %esi
        je ERROR
        # copy timing info (on_length, off_length, countdown, status) from 1st to 2nd
        movw ON_LENGTH(%edi), %bx     
        movw %bx, ON_LENGTH(%esi)        
        movw OFF_LENGTH(%edi), %bx      
        movw %bx, OFF_LENGTH(%esi)      
        movw COUNTDOWN(%edi), %bx       
        movw %bx, COUNTDOWN(%esi)       
        movw STATUS(%edi), %bx       
        movw %bx, STATUS(%esi)       
        # call mp1_poke on ON_CHAR or OFF_CHAR depending on STATUS
        cmpw $0, STATUS(%esi)       
        je SYNC_STATUS_OFF                  
        jne SYNC_STATUS_ON                 
        # clean up
        popl %edi
        popl %esi
        popl %ebx
        ret

# helper function for sync 
# called when STATUS == 1 
SYNC_STATUS_ON:         
        # change char
        movb ON_CHAR(%esi), %cl       
        movw LOCATION(%esi), %ax      
        imulw $2, %ax, %ax              
        pushl %edx
        call mp1_poke           
        popl %edx
        # clean up
        popl %edi
        popl %esi
        popl %ebx
        movl $0, %eax          
        leave 
        ret

# called when STATUS == 0
SYNC_STATUS_OFF:      
        # change char
        movb OFF_CHAR(%esi), %cl      
        movw LOCATION(%esi), %ax      
        imulw $2, %ax, %ax              
        pushl %edx
        call mp1_poke          
        popl %edx
        # clean up
        popl %edi
        popl %esi
        popl %ebx
        movl $0, %eax
        leave 
        ret

# helper function for mp1.S
# called when there is an error in a function && no memory needs to be freed
# returns -1
ERROR: 
        popl %edi
        popl %esi
        popl %ebx
        movl $-1, %eax          
        leave
        ret

# helper function for mp1_ioct_add
# called when there is an error in a function && memory needs to be freed
ERROR_FREE: 
        pushl %ebx      
        call mp1_free   
        popl %ebx        
        # clean up
        popl %edi
        popl %esi
        popl %ebx
        movl $-1, %eax  
        leave
        ret
/*
helper function for find, sync, and remove
searches a linked list for a matching LOCATION passed in through the stack
Outputs: %ecx != -1 - the address of the node before the node that matches LOCATION
         %ecx == -1 - LOCATION was not found in linked list
         %edx != -1 - the address of the node that matches LOCATION 
         %edx == -1 - LOCATION was not found in linked list
*/
LL_SEARCH:      
        # callee sequence
        pushl %ebp            
        movl %esp, %ebp        
        pushl %ebx
        pushl %esi
        pushl %edi
        xor %eax, %eax
        xor %ebx, %ebx
        xor %ecx, %ecx
        xor %edx, %edx
        # init registers
        movl 8(%ebp), %ebx            
        movl mp1_list_head, %esi        
        movl $0, %edi                 
        movl $-1, %edx                
        cmpl $0, %esi
        jne LOOP1 
        # clean up
        popl %edi
        popl %esi
        popl %ebx
        movl $-1, %ecx  
        leave
        ret

# helper function for LL_SEARCH
# searches the list for a matching LOCATION
LOOP1: 
        # check LOCATION + error checking + go to next node
        cmpw %bx, LOCATION(%esi)         
        je FOUND               
        movl %esi, %edi        
        movl NEXT(%esi), %esi    
        cmpl $0, %esi           
        jne LOOP1              
        je NOT_FOUND                   

# called when matching LOCATION is found
FOUND:
        movl %esi, %edx         
        movl %edi, %ecx    
        # clean up            
        popl %edi
        popl %esi
        popl %ebx
        leave
        ret

# called if matching LOCATION is not found in list
NOT_FOUND:
        popl %edi
        popl %esi
        popl %ebx
        movl $-1, %ecx 
        leave
        ret

# jump table to select which ioctl to call
jumptable:
        .long mp1_ioctl_add, mp1_ioctl_remove, mp1_ioctl_find, mp1_ioctl_sync
.end





