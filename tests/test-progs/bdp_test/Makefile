# This is a general solution for a makefile

CC=aarch64-linux-gnu-g++
CFLAGS=-c -ansi -std=c++11 -Wall -O3
LDFLAGS=-static -I"../../../../include"
EXECUTABLE=bdp
SOURCES=bdp_test.cpp
OBJECTS=$(SOURCES:.c=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.c.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -rf *.o *.~ $(EXECUTABLE) *.gch
