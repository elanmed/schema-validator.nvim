.PHONY: test lint docs

test:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

lint: 
	# https://luals.github.io/#install
	lua-language-server --check=./lua --checklevel=Error

docs: 
	./deps/ts-vimdoc.nvim/scripts/docgen.sh README.md doc/schema-validator.txt schema-validator

deploy: test lint docs
