#!/bin/bash

set -vex

export VCPKG_ROOT="$HOME/build/vcpkg"
if [[ -e "$VCPKG_ROOT" && ! -e "$VCPKG_ROOT/.git" ]]; then
	rm -rf "$VCPKG_ROOT"
fi
if [ ! -e "$VCPKG_ROOT" ]; then
	git clone https://github.com/Microsoft/vcpkg.git "$VCPKG_ROOT"
fi
pushd "$VCPKG_ROOT"
git fetch --all --prune --tags
git checkout .
git checkout 409c1c4a05f853e3204b5914e693221576525cd6
./bootstrap-vcpkg.sh -disableMetrics
#./vcpkg integrate install
echo "set(VCPKG_BUILD_TYPE release)" >> triplets/x64-linux.cmake
export VCPKG_DEFAULT_TRIPLET=x64-linux
#./vcpkg install llvm  # takes very long time
sudo apt-get install -y clang
# workaround to make clang_sys crate detect installed libclang
sudo ln -s libclang.so.1 /usr/lib/llvm-6.0/lib/libclang.so
./vcpkg upgrade --no-dry-run
./vcpkg install --recurse "opencv${VCPKG_OPENCV_VERSION}[contrib,nonfree]"
popd
