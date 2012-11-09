SpecialStack: stackcalls.o SpecialStack.o
	gcc -Wall -g -o SpecialStack stackcalls.o SpecialStack.o

stackcalls.o: stackcalls.c
	gcc -Wall -g -c stackcalls.c

SpecialStack.o: SpecialStack.s
	gcc -Wall -g -c SpecialStack.s

clean:
	rm -f *.o 
