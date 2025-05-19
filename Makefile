.PHONY: test lint

test:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

lint: 
	# https://luals.github.io/#install
	lua-language-server --check=./lua --checklevel=Error

deploy: test lint
