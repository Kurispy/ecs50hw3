#include <stdlib.h>
#include <stdio.h>

extern void initstack(void);
extern void pushstack(int m);
extern int popstack(int *errcode);
extern void swapstack(void);
extern void printstack(int n);

int main(void)
{
	int x, *errcode;
	initstack();
	pushstack(9);
	x = popstack(errcode);
	pushstack(5);
	swapstack();
	printstack(2);

	return 0;
}

