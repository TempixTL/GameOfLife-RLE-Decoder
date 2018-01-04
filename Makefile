CC = clang
CFLAGS = -fobjc-arc
FILES = main.m RLEDecoder.m GLPattern.m
OUT = main

default:
	$(CC) $(CFLAGS) $(FILES) -o $(OUT)

clean:
	$(RM) $(OUT)
