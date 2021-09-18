ARG DEBIAN_FRONTEND=noninteractive
ARG LLVM=llvmorg-12.0.1
ARG LLVM_SOURCE_DIR=llvm-project-${LLVM}
ARG LLVM_ROOT=/llvm
ARG LLVM_BUILD=${LLVM_ROOT}/build
ARG LLVM_INSTALL=${LLVM_ROOT}/dist

FROM ubuntu:20.04 as llvmbuild
ARG DEBIAN_FRONTEND
ARG LLVM
ARG LLVM_SOURCE_DIR
ARG LLVM_ROOT
ARG LLVM_BUILD
ARG LLVM_INSTALL

RUN apt-get update
RUN apt-get install --yes make cmake curl build-essential python3
RUN mkdir ${LLVM_ROOT}
WORKDIR ${LLVM_ROOT}

RUN curl https://github.com/llvm/llvm-project/archive/refs/tags/${LLVM}.tar.gz\
 --location\
 --output ${LLVM}.tag.gz

RUN tar -xf ${LLVM}.tag.gz
RUN rm ${LLVM}.tag.gz

RUN mkdir ${LLVM_BUILD}
WORKDIR ${LLVM_BUILD}

RUN cmake -S ../${LLVM_SOURCE_DIR}/llvm \
-DLLVM_ENABLE_PROJECTS="clang;lldb" \
-DLLVM_BUILD_LLVM_DYLIB=ON \
-DLLVM_TARGETS_TO_BUILD="X86;WebAssembly;AArch64;ARM" \
-DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL} \
-DCMAKE_BUILD_TYPE=Release

RUN cmake --build .
RUN cmake --build . --target install
ENV PATH="${LLVM_INSTALL}:${PATH}"

FROM ubuntu:20.04 as llvmdist
ARG DEBIAN_FRONTEND
ARG LLVM_INSTALL

RUN apt-get update
RUN apt-get install --yes make cmake
COPY --from=llvmbuild ${LLVM_INSTALL} /usr/local
