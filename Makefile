ecs50hw2.out : main.o 
	g++ -ansi -Wall -g -o ecs50hw2.out  main.o 

main.o : main.cpp 
	g++ -ansi -Wall -g -c  main.cpp

clean:
	rm -f ecs50hw2.out main.o 