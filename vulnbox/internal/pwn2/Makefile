.PHONY: all
clean:
	rm -f main main.db
compile:
	gcc -fno-stack-protector -z execstack -no-pie -fno-PIE lib/sqlite3.c main.c -o main
run:
	./main
.PHONY: all
all: compile run