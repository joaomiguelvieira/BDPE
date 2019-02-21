# This is a general solution for a makefile

CC=aarch64-linux-gnu-gcc
CFLAGS=-c -ansi -std=c99 -Wall -O0
LDFLAGS=-static -I"../../../../include"
EXECUTABLE=bdp_test
SOURCES=bdp_test.c
OBJECTS=$(SOURCES:.c=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.c.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -rf *.o *.~ $(EXECUTABLE) *.gch
