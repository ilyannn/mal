TARGETS=step0_repl

all: $(TARGETS)
	xcodebuild -alltargets
	for target in $(targets); do mv $(TOP)build/Release/$$target . ; done

$(TARGETS): %: 
	xcodebuild -target $@
	mv build/Release/$@ .

clean:
	rm -rf build
	rm -f $(TARGETS)