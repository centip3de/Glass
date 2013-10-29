.PHONY: clean all dev 

all: bin/intr

dev:
	ln -sf build.sh .git/post-checkout
	ln -sf build.sh .git/post-merge

bin/intr:
	mkdir -p bin
	dmd src/Backend/Interpreter/*.d -of"$@"
	rm bin/intr.o

clean:
	rm -rf bin

