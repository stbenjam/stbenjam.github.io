# High-bandwidth Cyberpunk Terminal Makefile

# Configuration
PORT = 4001
RUBY_BIN = /opt/homebrew/opt/ruby@3.3/bin
BUNDLE = $(RUBY_BIN)/bundle

.PHONY: help install serve clean

help:
	@echo "SYSTEM_READY // Available commands:"
	@echo "  make install  - Install digital dependencies"
	@echo "  make serve    - Boot local terminal at http://localhost:$(PORT)"
	@echo "  make clean    - Wipe generated data stream"

install:
	@echo "Installing dependencies..."
	$(BUNDLE) install

serve:
	@echo "Booting local terminal on port $(PORT)..."
	$(BUNDLE) exec jekyll serve --port $(PORT) --livereload

clean:
	@echo "Cleaning generated site..."
	$(BUNDLE) exec jekyll clean
