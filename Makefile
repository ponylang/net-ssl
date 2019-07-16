config ?= release

BUILD_DIR ?= build/$(config)
SRC_DIR ?= net_ssl
tests_binary := $(BUILD_DIR)/net_ssl

ifdef config
	ifeq (,$(filter $(config),debug release))
		$(error Unknown configuration "$(config)")
	endif
endif

ifeq ($(config),release)
	PONYC = ponyc
else
	PONYC = ponyc --debug
endif

ifdef ssl
	ifeq (,$(filter $(ssl), 1.1.x 0.9.0))
		$(error Unknown ssl version "$(ssl)")
	endif
endif

ifeq ($(ssl), 1.1.x)
	SSL = -Dopenssl_1.1.x
else
	SSL = -Dopenssl_0.9.0
endif

SOURCE_FILES := $(shell find $(SRC_DIR) -name \*.pony)

test: unit-tests build-examples

unit-tests: $(tests_binary)
	$^ --exclude=integration --sequential

$(tests_binary): $(GEN_FILES) $(SOURCE_FILES) | $(BUILD_DIR)
	${PONYC} ${SSL} -o ${BUILD_DIR} $(SRC_DIR)

build-examples:
	find examples/*/* -name '*.pony' -print | xargs -n 1 dirname  | sort -u | grep -v ffi- | xargs -n 1 -I {} ${PONYC} ${SSL} -s --checktree -o ${BUILD_DIR} {}

clean:
	rm -rf $(BUILD_DIR)

realclean:
	rm -rf build

TAGS:
	ctags --recurse=yes $(SRC_DIR)

all: test

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: all clean realclean TAGS test
