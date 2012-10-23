.data # data section
# set EAX here
LUA:
  .long 6 #lua
  .long 4 #lca
  .long 1 #ca...
  .long 2
  .long 5
  .long 1

p:
  .long 0 #pLUA
  .long 11 #request index
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

call writesa

done:

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

  movl 8(%eax), %ebx
  movl %ebx, writeValue

  movl l_CA, %eax
  movl $2, %ecx
  idivl %ecx # %eax is now l_CA / 2

  #set writeValue to EDX
  movl 8(%eax), %ebx
  movl %ebx, writeValue

  movl $1, %ebx # EBX will serve as the current index for CA

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

writesa: 
    #store what to write into EDX

    call readsa  #see if there is a 1 at that requested INDEX
    movl writeValue, %edx
    cmpl %edx, %ebp
    je done #do nothing if writevalue and readsa are equal

    cmpl $0, index
    jnz goRightEnd
    cmpl $1, %edx
    jnz goLeftWrite0
    call checkRight
    cmpl $0, %ebx
    jnz lw1cR1
    call lw1cR0

goLeftWrite0:
    call checkRight
    cmpl $0, %ebx
    jnz lw0cR1
    call lw0cR0

goRightEnd:
    movl l_UA, %eax
    movl %ebx, -4(%eax) #check if need register
    cmpl index, %ebx
    jnz goMid
    cmpl $1, %edx
    jnz goRightWrite0
    call checkLeft
    cmpl $0, %ecx
    jnz rw1cL1
    call rw1cL0
    
goRightWrite0:
    call checkLeft
    cmpl $0, %ecx
    jnz rw0cL1
    call rw0cL0

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

goMidcL0cR1:
    call checkLeft
    cmpl $0, %ecx
    jnz goMidcL1cR0
    call checkRight
    cmpl $1, %ebx
    jz mw1cL0cR1

goMidcL1cR0:
    call checkLeft
    cmpl $1, %ecx
    jnz goMidWrite0
    call checkRight
    cmpl $0, %ebx
    jz mw1cL1cR0

goMidWrite0:
    call checkLeft
    call checkRight
    cmpl %ebx, %ecx
    jnz goMidw0cL0cR1
    call checkLeft
    cmpl $0, %ecx
    jnz mw0cL1cR1
    call mw0cL0cR0
    
goMidw0cL0cR1:
    call checkLeft
    cmpl $0, %ecx
    jnz goMidw0cL1cR0
    call checkRight
    cmpl $1, %ebx
    jz mw0cL0cR1

goMidw0cL1cR0:
    call checkLeft
    cmpl $1, %ecx
    jnz done
    call checkRight
    cmpl $0, %ebx
    jz mw0cL1cR0
    jmp done

# l = left; r= right; m = middle; w = write value; cL = checkLeft; cR = checkRight

lw1cR0:
  addl $2, l_CA
  call shiftRight
  movl CA, %eax
  movl $0, (%eax)
  movl $1, 4(%eax)
  ret

lw1cR1:
  movl CA, %eax
  movl $0, (%eax)
  incl 4(%eax)
  ret

lw0cR0:
  call shiftLeft
  ret

lw0cR1:
  movl CA, %eax
  movl $1, (%eax)
  decl 4(%eax)
  ret

rw1cL0:
  addl $2, l_CA
  movl CA, %ebx
  movl l_CA, %ecx
  movl l_UA, %edx
  decl %edx
  movl %edx, -8(%ebx, %ecx, 4)
  movl $1, -4(%ebx, %ecx, 4)
  ret

rw1cL1:
  movl CA, %ebx
  movl l_CA, %ecx
  incl -4(%ebx, %ecx, 4)
  ret

rw0cL0:
  subl $2, l_CA
  ret

rw0cL1:
  movl CA, %ebx
  movl l_CA, %ecx
  decl -4(%ebx, %ecx, 4)
  ret

mw1cL0cR0:
  addl $2, l_CA
  call whereAmI #sets iCA
  call shiftRight #uses iCA
  movl CA, %ebx
  movl iCA, %ecx
  movl index, %edx
  addl %edx, (%ebx, %ecx, 4)
  movl $1, 4(%ebx, %ecx, 4)
  ret

mw1cL1cR1:
  call whereAmI #sets iCA
  movl CA, %ebx
  movl iCA, %ecx
  addl 4(%ebx, %ecx, 4), -4(%ebx, %ecx, 4)
  incl 4(%ebx, %ecx, 4)
  addl $2, iCA
  call shiftLeft #uses iCA
  subl $2, l_CA
  ret

mw1cL0cR1:
  call whereAmI #sets iCA
  movl CA, %ebx
  movl iCA, %ecx
  decl (%ebx, %ecx, 4)
  incl 4(%ebx, %ecx, 4)
  ret

mw1cL1cR0:
  call whereAmI #sets iCA
  movl CA, %ebx
  movl iCA, %ecx
  incl -4(%ebx, %ecx, 4)
  ret

mw0cL0cR0:
  call whereAmI #sets iCA
  call shiftLeft #uses iCA
  subl $2, l_CA
  ret

mw0cL1cR1:
  addl $2, l_CA
  call whereAmI #sets iCA
  call shiftRight #uses iCA
  movl CA, %ebx
  movl iCA, %ecx
  movl -4(%ebx, %ecx, 4), %edx #edx will be used to store temp values
  addl -8(%ebx, %ecx, 4), %edx
  movl %edx, temp
  movl index, %edx
  movl %edx, -4(%ebx, %ecx, 4)
  decl -4(%ebx, %ecx, 4)
  movl -8(%ebx, %ecx, 4), %edx 
  subl %edx, -4(%ebx, %ecx, 4)
  movl index, %edx
  movl %edx, (%ebx, %ecx, 4)
  incl (%ebx, %ecx, 4)
  movl temp, %edx
  movl %edx, 4(%ebx, %ecx, 4)
  movl (%ebx, %ecx, 4), %edx
  subl %edx, 4(%ebx, %ecx, 4)
  ret

mw0cL0cR1:
  call whereAmI #sets iCA
  movl CA, %ebx
  movl iCA, %ecx
  incl (%ebx, %ecx, 4)
  decl 4(%ebx, %ecx, 4)
  ret

mw0cL1cR0:
  call whereAmI #sets iCA
  movl CA, %ebx
  movl iCA, %ecx
  decl -4(%ebx, %ecx, 4)
  ret

#Subroutine Section

shiftRight:
  movl l_CA, %ebx #ebx = counter
  subl $3, %ebx
  movl iCA, %ecx
sRLoop:
  movl (CA, %ebx, 4), %edx
  movl %edx, 8(CA, %ebx, 4)
  incl %ebx
  cmpl %ebx, %ecx #i >= iCA
  jge sRLoop
  ret

shiftLeft:
  movl iCA, %ebx #ebx = counter
  movl l_CA, %ecx
  subl $3, %ecx
sLLoop:
  movl 8(CA, %ebx, 4), %edx
  movl %edx, (CA, %ebx, 4)
  decl %ebx
  cmpl %ebx, %ecx #i <= l_CA - 3
  jle sLLoop
  ret
  
checkRight:
  incl index
  call readsa
  decl index
  cmpl $1, %ebp
  je cR1
  movl $0, %ebx
  ret
cR1:
  movl $1, %ebx
  ret

checkLeft:
  decl index
  call readsa
  incl index
  cmpl $1, %ebp
  je cL1
  movl $0, %ecx
  ret
cL1:
  movl $1, %ecx
  ret

whereAmI:
  movl $0, %ebx #ebx = counter
  movl l_CA, %ecx
wAILoop:
  movl (CA, %ebx, 4), %edx
  addl 4(CA, %ebx, 4), %edx
  cmpl index, %edx
  jl wAII
  addl $2, %ebx
  cmpl %ebx, %ecx # i < l_CA
  jl wAILoop
  subl $2, %ecx
  movl %ecx, iCA
  ret
wAII:
  movl %ebx, iCA
  ret














