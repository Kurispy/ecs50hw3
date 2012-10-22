.data # data section
# set EAX here
LUA:
  .long 5 #lua
  .long 2 #lca
  .long 1 #ca...
  .long 2

p:
  .long 0 #pLUA
  .long 2 #request index
# EAX Set

l_UA:
  .long 0 #(%eax)

l_CA:
  .long 0 #(%eax) + 4

CA:
  .long 0 #(%eax) + 8

index:
  .long 0 #%eax + 4

.text # code section

.globl _start
_start:

init:
  movl $LUA, %ebx
  movl %ebx, p
  movl $p, %eax

  movl (%eax), %ebx
  movl (%ebx), %ebx
  movl %ebx, l_UA
  
  movl (%eax), %ebx
  movl 4(%ebx), %ebx 
  movl %ebx, l_CA

  movl (%eax), %ebx
  addl $8, %ebx
  movl %ebx, CA

  movl 4(%eax), %ebx
  movl %ebx, index

  movl l_CA, %eax
  movl $2, %ecx
  idivl %ecx # %eax is now l_CA / 2

  movl $0, %ebx # EBX will serve as the current index for CA

readsa:  
  movl CA, %ecx #temp
	incl (%ecx, %ebx, 8) #go to CA[2*j]
	cmpl %ecx, index #first part of if i>=ca[2*j]
	jl jump_for #jump if CA < index
	
	movl CA, %ecx #temp
	addl $4, %ecx #ca[2*j+1]
	cmpl %ecx, index #second part of if
	jge jump_for #jump to iteration if >=0
	movl $1, %ebp #store 1 in %ebp if correct
	ret

jump_for:
	incl %ebx #j++
	cmpl %ebx, %eax # is j < length_CA / 2 ?
	jnz readsa #exit loop when j=l_CA
	movl $0, %ebp #else store 0 in %ebp
	ret
  
done:
