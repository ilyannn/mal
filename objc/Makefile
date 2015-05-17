TARGETS=step0_repl step1_read_print step2_eval step3_env step4_if_fn_do

all: $(TARGETS)
	xcodebuild -alltargets
	for target in $(targets); do mv $(TOP)build/Release/$$target . ; done

$(TARGETS): %: 
	xcodebuild -target $@
	mv build/Release/$@ .

clean:
	rm -rf build
	rm -f $(TARGETS)