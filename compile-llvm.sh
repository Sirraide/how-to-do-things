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
     
## Debug mode
cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=/usr/local/llvm-VERSION-debug \
    -DCMAKE_BUILD_TYPE=Debug -DLLVM_PARALLEL_LINK_JOBS=4 -DLLVM_LINK_LLVM_DYLIB=ON \
    CMAKE_EXE_LINKER_FLAGS="-Wl,--reduce-memory-overheads -Wl,--hash-size=1021" \
    -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;compiler-rt' \
    -DLLVM_USE_LINKER=gold -S llvm -B out
