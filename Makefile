PROJECT_SOURCE_DIR ?= $(abspath ./)
BUILD_DIR ?= $(PROJECT_SOURCE_DIR)/build
INSTALL_DIR ?= $(BUILD_DIR)/install
NUM_JOB ?= 8
PYTHON_EXECUTABLE ?= $(shell which python3.7)
WHEELS_DIR ?= $(PROJECT_SOURCE_DIR)/wheels

all:
	@echo nothing special
clean:
	rm -rf $(BUILD_DIR) $(WHEELS_DIR)
force_clean:
	docker run --rm -v `pwd`:`pwd` -w `pwd` -it alpine/make make clean

CMAKE_ARGS ?= \
	-G'Unix Makefiles' \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR)
build:
	mkdir -p $(WHEELS_DIR)
	mkdir -p $(BUILD_DIR) && cd $(BUILD_DIR) && \
	cmake $(CMAKE_ARGS) $(PROJECT_SOURCE_DIR) && \
	make -j$(NUM_JOBS) && make install
	make -C $(BUILD_DIR)/install/python clean install
	mkdir -p $(WHEELS_DIR) && cp $(BUILD_DIR)/install/python/dist/*.whl $(WHEELS_DIR) && ls -alh $(WHEELS_DIR)

.PHONY: all clean force_clean build

build_py36_conda:
	conda env list | grep '^py36 ' && PYTHON_EXECUTABLE=python BUILD_DIR=$(BUILD_DIR)/py36 conda run --no-capture-output -n py36 make build
build_py37_conda:
	conda env list | grep '^py37 ' && PYTHON_EXECUTABLE=python BUILD_DIR=$(BUILD_DIR)/py37 conda run --no-capture-output -n py37 make build
build_py38_conda:
	conda env list | grep '^py38 ' && PYTHON_EXECUTABLE=python BUILD_DIR=$(BUILD_DIR)/py38 conda run --no-capture-output -n py38 make build
build_py39_conda:
	conda env list | grep '^py39 ' && PYTHON_EXECUTABLE=python BUILD_DIR=$(BUILD_DIR)/py39 conda run --no-capture-output -n py39 make build
build_py310_conda:
	conda env list | grep '^py310 ' && PYTHON_EXECUTABLE=python BUILD_DIR=$(BUILD_DIR)/py310 conda run --no-capture-output -n py310 make build
build_wheels_for_conda: build_py36_conda build_py37_conda build_py38_conda build_py39_conda build_py310_conda
.PHONY: build_python_all build_py36 build_py37 build_py38 build_py39 build_py310

build_python_all: build_wheels_for_conda
.PHONY: build_python_all

upload_wheels:
	python3 -m pip install twine
	twine upload wheels/* -r local

# https://github.com/orgs/cubao/packages/container/package/build-env-manylinux2014-x64
MANYLINUX_TAG := ghcr.io/cubao/build-env-manylinux2014-x64:latest
test_in_manylinux:
	docker run --rm -v `pwd`:`pwd` -w `pwd` -it $(MANYLINUX_TAG) bash
build_wheels_in_manylinux:
	docker run --rm -v `pwd`:`pwd` -w `pwd` -it $(MANYLINUX_TAG) make build_python_all
