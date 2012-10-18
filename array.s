.data # data section
# set EAX here

#
l_UA:
  .long (%eax)

l_CA:
  .long (%eax) + 4 

CA:
  .long (%eax) + 8

index:
  .long %eax + 4

movl (l_CA), %eax
idivl $2 # %eax is now l_CA / 2

movl $0, %ebx # EBX will serve as the current index for CA
  

.text # code section

.globl _start
_start:
  

# (%eax) = address of length of UA; (%eax) + 4 = address of length of CA; (%eax) + 8 = address of CA; %eax + 4 = index

readsa:  
  movl CA, %ecx #temp
	incl (%ecx, %ebx, 16) #go to CA[2*j]
	cmpl %ecx, index #first part of if i>=ca[2*j]
	jl jump_for #jump if CA < index
	
	movl CA, %ecx #temp
	addl $8, %ecx #ca[2*j+1]
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

  
  

writea:
  
done:


