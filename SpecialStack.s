.equ csize, 17 #chunk size (must be > 4)

.data

tos:
  .long 0
  
fmt:
  .string "%x\n"


.text

.globl tos
.globl initstack
.globl pushstack
.globl popstack
.globl swapstack
.globl printstack

initstack:
  pushl %ebp
  movl %esp, %ebp
  
  movl $csize, %ebx
  movl $4, %eax
  imull %ebx
  pushl %eax

  call malloc
  movl %eax, %ebx
  addl $4, %ebx
  movl %ebx, tos #tos points to first -1 in stack chunk
  movl $0, (%eax) #move 0 to lowest address
  movl $-1, 4(%eax) #move -1 to second lowest address
  movl $csize, %ebx
  subl $2, %ebx
  movl $-1, (%eax, %ebx, 4) #move -1 to second highest address
  movl $0, 4(%eax, %ebx, 4) #move 0 to highest address
  
  movl %ebp, %esp
  popl %ebp

  ret

pushstack:
  pushl %ebp
  movl %esp, %ebp

  addl $4, tos #increment special stack
  movl tos, %ebx
  cmpl $-1, (%ebx) #check if element = -1
  jz overflow
  movl 8(%esp), %ebx #move m into ebx
  movl tos, %ecx
  movl %ebx, (%ecx) #push m onto special stack

  movl %ebp, %esp
  popl %ebp

  ret

overflow:
  movl $csize, %ebx
  movl $4, %eax
  imull %ebx
  pushl %eax
  call malloc
  
  movl tos, %ebx
  movl $-1, (%ebx)
  addl $4, tos #tos now point to highest element in chunk
  movl tos, %ecx
  movl %eax, (%ecx) #set highest element in old chunk to address of new chunk
  movl %ecx, (%eax) #set lowest element in new chunk to address of highest element in old chunk
  movl $-1, 4(%eax) #move -1 to second lowest address
  movl $csize, %ebx
  subl $2, %ebx
  movl $-1, (%eax, %ebx, 4) #move -1 to second highest address
  movl $0, 4(%eax, %ebx, 4) #move 0 to highest address
  
  addl $8, %eax
  movl 12(%esp), %ebx
  movl %ebx, (%eax)
  movl %eax, tos
  movl %ebp, %esp
  popl %ebp
  ret

popstack:
  pushl %ebp
  movl %esp, %ebp

  movl tos, %ebx
  cmpl $-1, (%ebx)
  jz psunderflow
  movl (%ebx), %eax #return *tos via eax
  subl $4, tos
  movl tos, %ebx
  cmpl $-1, (%ebx)
  jz prechunk #jump if first element in chunk in being popped
  movl 8(%esp), %ebx 
  movl $0, (%ebx)
  
  movl %ebp, %esp
  popl %ebp
  ret

prechunk:
  subl $4, tos
  movl tos, %ebx
  cmpl $0, (%ebx)  
  jz firstchunk   
  movl (%ebx), %ebx
  movl %ebx, tos
  subl $8, tos #tos now points to last piece of data in the previous chunk 
  movl 8(%esp), %ebx 
  movl $0, (%ebx)
  
  movl %ebp, %esp
  popl %ebp
  ret

firstchunk:
  addl $4, tos 
  
  movl 8(%esp), %ebx 
  movl $0, (%ebx)
  
  movl %ebp, %esp
  popl %ebp
  ret
   
psunderflow:
  movl 8(%esp), %ebx 
  movl $1, (%ebx)
  
  movl %ebp, %esp
  popl %ebp
  ret

swapstack:
  pushl %ebp
  movl %esp, %ebp

  movl tos, %ecx
  movl %ecx, %esi #esi holds address of lowest element in chunk if there is underflow 
  subl $4, %ecx
  cmpl $-1, (%ecx) #check if element is the first in the chunk
  jnz ssnounderflow
  subl $4, %ecx
  movl (%ecx), %ecx #ecx = highest element of previous chunk
  subl $8, %ecx #ecx now points to next printable element
  movl (%ecx), %edi
  movl (%esi), %ebx
  movl %ebx, (%ecx)
  movl %edi, (%esi)

  movl %ebp, %esp
  popl %ebp
  ret  

ssnounderflow:
  movl (%ecx), %esi
  movl 4(%ecx), %edi
  movl %edi, (%ecx)
  movl %esi, 4(%ecx)

  movl %ebp, %esp
  popl %ebp
  ret

printstack:
  
  pushl %ebp
  movl %esp, %ebp



  movl tos, %ecx
  movl 8(%esp), %ebx #ebx = n
psloop:
  pushl %ecx

  pushl (%ecx)
  pushl $fmt
  call printf
  addl $8, %esp
  popl %ecx
  
  subl $4, %ecx

  cmpl $-1, (%ecx) #check if we need to go to previous chunk
  jnz psnounderflow
  subl $4, %ecx
  movl (%ecx), %ecx #ecx = highest element of previous chunk
  subl $8, %ecx #ecx now points to next printable element
psnounderflow:
  
  decl %ebx #decrement n

  jnz psloop

  movl %ebp, %esp
  popl %ebp
  ret
