
-include config.mk

COMPAT_DIR ?= /dev/null
LLAMA_DIR ?= /dev/null
WITH_EDITOR_DIR ?= /dev/null
TRANSIENT_DIR ?= /dev/null
MAGIT_DIR ?= /dev/null

LOAD_PATH = -L $(COMPAT_DIR) -L $(LLAMA_DIR) -L $(WITH_EDITOR_DIR) \
	    -L $(TRANSIENT_DIR)  -L $(MAGIT_DIR)
BATCH = emacs -Q --batch $(LOAD_PATH)

all: magit-imerge.elc magit-imerge-autoloads.el

.PHONY: test
test: magit-imerge.elc
	@$(BATCH) -L . -l magit-imerge-tests.el \
	--eval "(ert-run-tests-batch-and-exit '(not (tag interactive)))"

.PHONY: clean
clean:
	$(RM) *.elc magit-imerge-autoloads.el

%.elc: %.el
	@$(BATCH) -f batch-byte-compile $<

%-autoloads.el: %.el
	@$(BATCH) --eval \
	"(let ((make-backup-files nil)) \
	   (if (fboundp 'loaddefs-generate) \
	       (loaddefs-generate default-directory \"$@\" \
				  (list \"magit-imerge-tests.el\")) \
	     (update-file-autoloads \"$(CURDIR)/$<\" t \"$(CURDIR)/$@\")))"
