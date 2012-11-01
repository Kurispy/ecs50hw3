.data # data section
# set EAX here
LUA:
  .long 6 #lua
  .long 4 #lca
  .long 1 #ca...
  .long 1
  .long 5
  .long 1

p:
  .long 0 #pLUA
  .long 3 #request index
  .long 1  #what to write 0 or 1
# EAX Set 

l_UA:
  .long 0 #(%eax)

l_CA:
  .long 0 #(%eax) + 4

CA:
  .long 0 #(%eax) + 8

index:
  .long 0 #%eax + 4

writeValue:
  .long 0 #%eax + 8, must be 0 or 1

iCA:
  .long 0

temp:
  .long 0


.text # code section

.globl _start
_start:

call init

call readsa

call writesa

done:
  movl %eax, %eax

#eax-edx, esi, edi
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

  #set writeValue to EDX
  movl 8(%eax), %ebx
  movl %ebx, writeValue

  movl %eax, %edi
  movl l_CA, %eax
  movl $2, %ecx
  idivl %ecx 
  movl %eax, %esi # %esi is now l_CA / 2
  movl %edi, %eax
  movl $0, %edi

  ret

readsa:  
  movl $0, %ebx # EBX will serve as the current index for CA
rsal:
  movl (%eax), %ecx
  addl $8, %ecx #ECX = CA
  movl (%ecx, %ebx, 8), %ecx #go to CA[2*j]
  cmpl %ecx, 4(%eax) #first part of if i>=ca[2*j]
  jl jump_for #jump if CA < index
  movl %ecx, %edx #store for CA[2*j] + CA[2*j+1]
  
	
	movl (%eax), %ecx
  addl $8, %ecx #ECX = CA
	movl 4(%ecx, %ebx, 8), %ecx #go to CA[2*j+1]
  addl %edx, %ecx
	cmpl %ecx, 4(%eax) #second part of if
	jge jump_for #jump to iteration if >=0
	movl $1, %ebp #store 1 in %ebp if correct
	ret

jump_for:
	incl %ebx #j++
	cmpl %ebx, %esi # is j < length_CA / 2 ?
	jnz rsal #exit loop when j=l_CA
	movl $0, %ebp #else store 0 in %ebp
	ret

writesa: 
    #store what to write into EDX
    movl 8(%eax), %edx
    call readsa  #see if there is a 1 at that requested INDEX
    cmpl %edx, %ebp
    jne continue #do nothing if writevalue and readsa are equal
    ret

continue:
    cmpl $0, 4(%eax)
    jnz goRightEnd
    cmpl $1, %edx
    jnz goLeftWrite0
    call checkRight
    cmpl $0, %ebx
    jnz lw1cR1
    call lw1cR0
    ret

goLeftWrite0:
    call checkRight
    cmpl $0, %ebx
    jnz lw0cR1
    call lw0cR0
    ret

goRightEnd:
    movl %edi, temp
    movl (%eax), %edi
    decl (%edi)
    movl (%edi), %ebx #check if need register
    cmpl 4(%eax), %ebx
    movl temp, %edi
    jnz goMid
    cmpl $1, %edx
    jnz goRightWrite0
    call checkLeft
    cmpl $0, %ecx
    jnz rw1cL1
    call rw1cL0
    ret
    
goRightWrite0:
    call checkLeft
    cmpl $0, %ecx
    jnz rw0cL1
    call rw0cL0
    ret

goMid:
    cmpl $1, %edx
    jnz goMidWrite0
    call checkLeft
    call checkRight
    cmpl %ebx, %ecx
    jnz goMidcL0cR1
    call checkLeft
    cmpl $0, %ecx
    jnz mw1cL1cR1
    call mw1cL0cR0
    ret

goMidcL0cR1:
    call checkLeft
    cmpl $0, %ecx
    jnz goMidcL1cR0
    call checkRight
    cmpl $1, %ebx
    jz mw1cL0cR1
    ret

goMidcL1cR0:
    call checkLeft
    cmpl $1, %ecx
    jnz goMidWrite0
    call checkRight
    cmpl $0, %ebx
    jz mw1cL1cR0
    ret

goMidWrite0:
    call checkLeft
    call checkRight
    cmpl %ebx, %ecx
    jnz goMidw0cL0cR1
    call checkLeft
    cmpl $0, %ecx
    jnz mw0cL1cR1
    call mw0cL0cR0
    ret
    
goMidw0cL0cR1:
    call checkLeft
    cmpl $0, %ecx
    jnz goMidw0cL1cR0
    call checkRight
    cmpl $1, %ebx
    jz mw0cL0cR1
    ret

goMidw0cL1cR0:
    call checkLeft
    cmpl $1, %ecx
    jnz done
    call checkRight
    cmpl $0, %ebx
    jz mw0cL1cR0
    ret

# l = left; r= right; m = middle; w = write value; cL = checkLeft; cR = checkRight

lw1cR0:

  movl (%eax), %ebx
  addl $4, %ebx
  addl $2, (%ebx)
  call shiftRight
  movl (%eax), %ebx
  addl $8, %ebx
  movl $0, (%ebx)
  movl $1, 4(%ebx)
  ret

lw1cR1:
  movl (%eax), %ebx
  addl $8, %ebx
  movl $0, (%ebx)
  incl 4(%ebx)
  ret

lw0cR0:
  call shiftLeft
  ret

lw0cR1:
  movl (%eax), %ebx
  addl $8, %ebx
  movl $1, (%ebx)
  decl 4(%ebx)
  ret

rw1cL0:
  movl (%eax), %ebx
  addl $4, %ebx
  addl $2, (%ebx)
  movl (%eax), %ebx
  addl $8, %ebx
  movl (%eax), %ecx
  movl 4(%ecx), %ecx 
  movl (%eax), %edx
  movl (%edx), %edx 
  decl %edx
  movl %edx, -8(%ebx, %ecx, 4)
  movl $1, -4(%ebx, %ecx, 4)
  ret

rw1cL1:
  movl (%eax), %ebx
  addl $8, %ebx
  movl (%eax), %ecx
  movl 4(%ecx), %ecx 
  incl -4(%ebx, %ecx, 4)
  ret

rw0cL0:
  movl (%eax), %ecx
  addl $4, %ecx 
  subl $2, (%ecx)
  ret

rw0cL1:
  movl (%eax), %ebx
  addl $8, %ebx
  movl (%eax), %ecx
  movl 4(%ecx), %ecx 
  decl -4(%ebx, %ecx, 4)
  ret

mw1cL0cR0:
  movl (%eax), %ecx
  addl $4, %ecx 
  addl $2, (%ecx)
  call whereAmI #sets iCA
  call shiftRight #uses iCA
  movl (%eax), %ebx
  addl $8, %ebx
  movl %edi, %ecx
  movl 4(%eax), %edx
  addl %edx, (%ebx, %ecx, 4)
  movl $1, 4(%ebx, %ecx, 4)
  ret

mw1cL1cR1:
  call whereAmI #sets iCA
  movl (%eax), %ebx
  addl $8, %ebx
  movl %edi, %ecx
  movl 4(%ebx, %ecx, 4), %eax
  addl %eax, -4(%ebx, %ecx, 4)
  incl -4(%ebx, %ecx, 4)
  addl $2, %edi
  call shiftLeft #uses iCA
  movl (%eax), %ecx
  addl $4, %ecx 
  subl $2, (%ecx)
  ret

mw1cL0cR1:
  call whereAmI #sets iCA
  movl (%eax), %ebx
  addl $8, %ebx
  movl %edi, %ecx
  decl (%ebx, %ecx, 4)
  incl 4(%ebx, %ecx, 4)
  ret

mw1cL1cR0:
  call whereAmI #sets iCA
  movl (%eax), %ebx
  addl $8, %ebx
  movl %edi, %ecx
  incl -4(%ebx, %ecx, 4)
  ret

mw0cL0cR0:
  call whereAmI #sets iCA
  call shiftLeft #uses iCA
  movl (%eax), %ecx
  addl $4, %ecx 
  subl $2, (%ecx)
  ret

mw0cL1cR1:
  addl $2, l_CA
  call whereAmI #sets iCA
  call shiftRight #uses iCA
  movl (%eax), %ebx
  addl $8, %ebx
  movl %edi, %ecx
  movl -4(%ebx, %ecx, 4), %edx #edx will be used to store temp values
  addl -8(%ebx, %ecx, 4), %edx
  movl %edx, temp
  movl 4(%eax), %edx
  movl %edx, -4(%ebx, %ecx, 4)
  decl -4(%ebx, %ecx, 4)
  movl -8(%ebx, %ecx, 4), %edx 
  subl %edx, -4(%ebx, %ecx, 4)
  movl 4(%eax), %edx
  movl %edx, (%ebx, %ecx, 4)
  incl (%ebx, %ecx, 4)
  movl temp, %edx
  movl %edx, 4(%ebx, %ecx, 4)
  movl (%ebx, %ecx, 4), %edx
  subl %edx, 4(%ebx, %ecx, 4)
  ret

mw0cL0cR1:
  call whereAmI #sets iCA
  movl (%eax), %ebx
  addl $8, %ebx
  movl %edi, %ecx
  incl (%ebx, %ecx, 4)
  decl 4(%ebx, %ecx, 4)
  ret

mw0cL1cR0:
  call whereAmI #sets iCA
  movl (%eax), %ebx
  addl $8, %ebx
  movl %edi, %ecx
  decl -4(%ebx, %ecx, 4)
  ret

#Subroutine Section (EDI = iCA)

shiftRight:
  movl %esi, temp
  movl (%eax), %ebx
  movl 4(%ebx), %ebx #ebx = l_CA
  decl %ebx
  movl %edi, %ecx
  addl $2, %ecx
  movl (%eax), %edx
  addl $8, %edx
sRLoop:
  movl -8(%edx, %ebx, 4), %esi
  movl %esi, (%edx, %ebx, 4)
  decl %ebx
  cmpl %ecx, %ebx #i >= iCA
  jge sRLoop
  movl temp, %esi
  ret

shiftLeft:
  movl %esi, temp
  movl %edi, %ebx #ebx = counter
  movl (%eax), %ecx
  addl $4, %ecx 
  decl (%ecx)
  movl (%eax), %edx
  addl $8, %edx
sLLoop:
  movl (%edx, %ebx, 4), %esi
  movl %esi, -8(%edx, %ebx, 4)
  decl %ebx
  cmpl %ebx, %ecx #i <= l_CA - 3
  jle sLLoop
  movl temp, %esi
  ret
  
checkRight:
  incl 4(%eax)
  movl %ecx, temp
  call readsa
  decl 4(%eax)
  cmpl $1, %ebp
  movl temp, %ecx
  je cR1
  movl $0, %ebx
  ret
cR1:
  movl $1, %ebx
  ret

checkLeft:
  decl 4(%eax)
  movl %ebx, temp
  call readsa
  incl 4(%eax)
  cmpl $1, %ebp
  movl temp, %ebx
  je cL1
  movl $0, %ecx
  ret
cL1:
  movl $1, %ecx
  ret

whereAmI:
  movl %esi, temp
  movl $0, %ebx #ebx = counter
  movl (%eax), %ecx
  addl $4, %ecx 
  decl (%ecx)
  movl (%eax), %edx
  addl $8, %edx
wAILoop:
  movl (%edx, %ebx, 4), %esi
  addl 4(%edx, %ebx, 4), %esi
  cmpl 4(%edx), %esi
  jl wAII
  addl $2, %ebx
  cmpl %ebx, %ecx # i < l_CA
  jl wAILoop
  #subl $2, %edx
  movl %edx, %edi #NEEDS LOOKING AT
  movl temp, %esi
  ret
wAII:
  movl %ebx, %edi
  movl temp, %esi
  ret














