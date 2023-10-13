.PHONY: test
test:
	nvim --headless -u test/init.lua -c "PlenaryBustedDirectory test/ {minimal_init = 'test/init.lua'}"

.PHONY: test_clean
test_clean:
	rm .tests -rf

.PHONY: test
test_dev:
	nvim --headless -c "PlenaryBustedDirectory test/"
