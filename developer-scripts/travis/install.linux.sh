#!/usr/bin/env bash

set -o errexit
set -o verbose
set -o pipefail
set -o nounset
set -o errtrace

__file=developer-scripts/travis/install.linux.sh

# Error tracing
# requires `set -o errtrace`
__caf_err_report() {
    error_code=${?}
    echo "Error (code=${error_code}) in ${__file} in function ${1} on line ${2}." >&2
    false
    return ${error_code}
}
# Always provide an error backtrace
trap '__caf_err_report "${FUNCNAME:-.}" ${LINENO}' ERR

echo "Performing Travis-CI installation phase on Linux..."

if [[ "${BUILD_TYPE:-}" != InstallScript ]]; then # Ubuntu on Travis-CI, NOT testing install.sh
    if ! [[ -x "${HOME}/.local/bin/mpif90" && -x "${HOME}/.local/bin/mpicc" ]]; then
        # mpich install not cached
        # could use prerequisites/build instead...
        wget "${MPICH_URL_HEAD}/${MPICH_URL_TAIL}"
        tar -xzvf "${MPICH_URL_TAIL}"
	export CC=gcc-${GCC}
	export FC=gfortran-${GCC}
        (
	    cd "${MPICH_URL_TAIL%.tar.gz}"
            ./configure --prefix="${CACHE}"
            make -j 4
            make install
	)
    fi
fi

{
    mpif90 --version && mpif90 -show
} || echo "No mpif90"
{
    mpicc --version && mpicc -show
} || echo "No mpicc"

type -a cmake || echo "CMake not installed"
cmake --version || true

echo "Done."
