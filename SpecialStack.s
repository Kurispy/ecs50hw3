.equ csize, $5 #chunk size (must be > 4)

.data

tos:
  .long 0

fmt:
  .string "%x\n"

.globl tos

.text

.globl _start
_start:

initstack:
  pushl %ebp
  movl %esp, %ebp
  
  movl csize, (%esp)
  call malloc
  movl 8(%eax), tos
  movl $0, (%eax) #move 0 to lowest address
  movl $-1, 4(%eax) #move -1 to second lowest address
  movl csize, %ebx
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
  movl 4(%esp), %ebx #move m into ebx
  movl tos, %eax
  movl %ebx, (%eax) #push m onto special stack

  movl %ebp, %esp
  popl %ebp
  ret

overflow:
  movl csize, (%esp)
  call malloc
  addl $4, tos #tos now point to highest element in chunk
  movl tos, %ecx
  addl $8, %ecx #ecx now points to end of old chunk
  movl %eax, (%ecx) #set highest element in old chunk to address of new chunk
  movl %ecx, (%eax) #set lowest element in new chunk to address of highest element in old chunk

  movl %ebp, %esp
  popl %ebp
  ret

popstack:
  pushl %ebp
  movl %esp, %ebp
  
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
  movl -4(%ecx), %edi
  movl %edi, (%ecx)
  movl %esi, -4(%ecx)

  movl %ebp, %esp
  popl %ebp
  ret

printstack:
  pushl %ebp
  movl %esp, %ebp

  movl tos, %ecx
  movl 4(%esp), %ebx #ebx = n
psloop:
  cmpl $-1, (%ecx) #check if we need to go to previous chunk
  jnz psnounderflow
  subl $4, %ecx
  movl (%ecx), %ecx #ecx = highest element of previous chunk
  subl $8, %ecx #ecx now points to next printable element
psnounderflow:
  pushl (%ecx)
  pushl $fmt
  call printf
  subl $4, %ecx #decrement special stack pointer
  decl %ebx #decrement n
  jnz psloop

  movl %ebp, %esp
  popl %ebp
  ret
