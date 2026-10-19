# Convenience wrapper around CMake. Run inside the Nix dev shell (direnv or `nix develop`).

BUILD_TYPE ?= Release
GENERATOR  ?= Ninja
BUILD_DIR  ?= build/$(BUILD_TYPE)

SUBMODULE_MARKERS := openvdb/CMakeLists.txt GLFW/CMakeLists.txt imgui/imgui.cpp

.PHONY: all build configure submodules clean distclean

all: build

build: $(BUILD_DIR)/CMakeCache.txt
	cmake --build $(BUILD_DIR)

configure $(BUILD_DIR)/CMakeCache.txt: $(SUBMODULE_MARKERS)
	cmake -S . -B $(BUILD_DIR) -G $(GENERATOR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE)

submodules: $(SUBMODULE_MARKERS)

$(SUBMODULE_MARKERS) &:
	git submodule update --init

clean:
	cmake --build $(BUILD_DIR) --target clean

distclean:
	rm -rf build Dist
