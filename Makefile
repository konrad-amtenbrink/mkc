CC = gcc
SOURCES=src/main.m
FRAMEWORKS:= -framework Foundation -framework IOBluetooth
LIBRARIES:= -lobjc
CFLAGS=-Wall -Werror -v $(SOURCES)
LDFLAGS=$(LIBRARIES) $(FRAMEWORKS)
OUT=-o bin/mk

all: $(SOURCES) $(OUT)

$(OUT): $(OBJECTS)
	$(CC) -o $(OBJECTS) $@ $(CFLAGS) $(LDFLAGS) $(OUT)

.m.o: 
	$(CC) -c -Wall $< -o $@
