.data # data section
# set EAX here
LUA:
  .long 9 #lua
  .long 4 #lca
  .long 1 #ca...
  .long 2
  .long 5
  .long 3

rparam:
  .long 0 #pLUA
  .long 7 #request index

wparam:
  .long 
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
  movl CA, %ecx
  movl (%ecx, %ebx, 8), %ecx #go to CA[2*j]
	cmpl %ecx, index #first part of if i>=ca[2*j]
	jl jump_for #jump if CA < index
  movl %ecx, %edx #store for CA[2*j] + CA[2*j+1]
  
	
	movl CA, %ecx #temp
	movl 4(%ecx, %ebx, 8), %ecx #go to CA[2*j+1]
  addl %edx, %ecx
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