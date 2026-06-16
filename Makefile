BUILD_DIR ?= build
CMAKE ?= cmake
CMAKE_BUILD_TYPE ?= Release
CMAKE_FLAGS ?=
CTEST ?= ctest

.PHONY: all configure serial install test clean doc

all: serial

configure:
	$(CMAKE) -S . -B $(BUILD_DIR) -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) $(CMAKE_FLAGS)

serial: configure
	$(CMAKE) --build $(BUILD_DIR)

install: serial
	$(CMAKE) --install $(BUILD_DIR)

test: configure
	$(CMAKE) --build $(BUILD_DIR)
	$(CTEST) --test-dir $(BUILD_DIR) --output-on-failure

clean:
	$(CMAKE) -E rm -rf $(BUILD_DIR)

doc:
	doxygen doc/Doxyfile
