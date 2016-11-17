SP=" "
HEADER_START=\033[1m$(SP)
HEADER_END=$(SP)\033[0m

.PHONY: default
default: spec

.PHONY: deps
deps: libs

libs: shard.yml
	@echo "$(HEADER_START)Installing dependencies…$(HEADER_END)"
	crystal deps
	mkdir -p `dirname $@`
	touch $@
	@echo

.PHONY: clean
clean:
	@echo "$(HEADER_START)Cleaning…$(HEADER_END)"
	rm -rf .crystal
	rm -rf tmp
	rm -rf build
	rm -rf .shards
	rm -rf libs
	@echo

.PHONY: spec
spec: deps
	@echo "$(HEADER_START)Testing…$(HEADER_END)"
	crystal spec
	@echo
