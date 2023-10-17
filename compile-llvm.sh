## Release mode
cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=/usr/local/llvm-VERSION \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;compiler-rt' \
    -S llvm -B out
    
## Release mode with assertions etc.
cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=/usr/local/llvm-VERSION \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_UNREACHABLE_OPTIMIZE=OFF \
    -DLLVM_ENABLE_DUMP=ON \
    -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;compiler-rt' \
    -S llvm -B out

## Release mode + assertions + other stuff. This is my personal recommendation
## for consuming LLVM as a *library*.
##
## Remove the `DLLVM_USE_LINKER` option if you don’t have `mold` installed or
## set it to `lld` if possible in that case.
cmake -G "Ninja" \
  -S llvm \
  -B out \
  -DCMAKE_INSTALL_PREFIX="/usr/share/local/llvm-VERSION" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;compiler-rt;mlir' \
  -DLLVM_C_COMPILER=clang \
  -DLLVM_CXX_COMPILER=clang++ \
  -DLLVM_USE_LINKER=mold \
  -DLLVM_ENABLE_UNWIND_TABLES=OFF \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_UNREACHABLE_OPTIMIZE=OFF \
  -DLLVM_ENABLE_DUMP=ON \
  -DLLVM_CCACHE_BUILD=ON \
  -DLLVM_ENABLE_DOXYGEN=ON \
  -DLLVM_ENABLE_FFI=ON \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DLLVM_INCLUDE_TESTS=OFF
     
## Debug mode
cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=/usr/local/llvm-VERSION-debug \
    -DCMAKE_BUILD_TYPE=Debug -DLLVM_PARALLEL_LINK_JOBS=4 -DLLVM_LINK_LLVM_DYLIB=ON \
    CMAKE_EXE_LINKER_FLAGS="-Wl,--reduce-memory-overheads -Wl,--hash-size=1021" \
    -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;compiler-rt' \
    -DLLVM_USE_LINKER=gold -S llvm -B out
