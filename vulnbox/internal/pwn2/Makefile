.PHONY: all
clean:
	rm -f main main.db
compile:
	gcc -fno-stack-protector lib/sqlite3.c main.c -o main
run:
	./main
.PHONY: all
all: compile run