#include <stdlib.h>
#include <stdio.h>

extern void initstack(void);
extern void pushstack(int m);
extern int popstack(int *errcode);
extern void swapstack(void);
extern void printstack(int n);

int main(void)
{
	int x, *errcode, y;
	y = 1;
	errcode = &y;
	
	initstack();
	x = popstack(errcode);


	
	return 0;
}

