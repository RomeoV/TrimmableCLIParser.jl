# adapted from the Runic.jl Makefile
JULIA ?= $(shell which julia)
JULIAC ?= $(shell $(JULIA) -e 'print(normpath(joinpath(Sys.BINDIR, Base.DATAROOTDIR, "julia", "juliac.jl")))')

RUNIC_FILES := $(wildcard ./src/*.jl)

main: ./src/main.jl Project.toml Manifest.toml $(RUNIC_FILES)
	$(JULIA) --project=. $(JULIAC) --verbose --output-exe $@ --experimental --trim=unsafe-warn $<

Manifest.toml: Project.toml
	$(JULIA) --project=. -e 'using Pkg; Pkg.instantiate()'
	@touch $@ # Pkg.instantiate doesn't update the mtime if there are no changes

clean:
	-rm -f main

check-julia:
	@if ! $(JULIA) --help-hidden | grep -s -q 'trim'; then \
		echo "ERROR: The configured julia binary ($(JULIA)) does not support the --trim argument."; \
		echo "       Configure the binary using the JULIA variable (e.g. \`JULIA=/path/to/julia make ...\`)"; \
		echo "       or change how \`julia\` resolves in \`PATH\`."; \
		exit 1; \
	fi

print-%:
	@echo '$*=$($*)'

.PHONY: clean check-julia
