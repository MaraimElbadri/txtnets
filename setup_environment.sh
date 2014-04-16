#!/bin/bash

set -e

ROOT="$(pwd)"
ENV="$ROOT/env"
EXTERNAL="$ROOT/external"
LIB="$ROOT/lib"
DATA="$ROOT/data"
PLATFORM="$(uname)"

function safe_call {
    # usage:
    #   safe_call function param1 param2 ...

    HERE="$(pwd)"
    "$@"
    cd "$HERE"
}

function conda_install {
    conda install --yes "$@"
}

function pip_install {
    pip install "$@"
}

function install_cld2 {
    cd "$EXTERNAL"

    # build cld2
    svn checkout http://cld2.googlecode.com/svn/trunk/ cld2

    cd cld2/internal/
    if [[ "$PLATFORM" == "Darwin" ]]; then
        sed -i -e 's/^g++/g++-4.8/' compile_libs.sh
    fi
    ./compile_libs.sh
    mv libcld2_full.so libcld2.so "$LIB"

    # build python bindings for cld2
    cd "$EXTERNAL"

    hg clone https://code.google.com/p/chromium-compact-language-detector/
    cd chromium-compact-language-detector

    sed -i -e "/include_dirs/ s~$~library_dirs=\['$LIB'\],~" setup.py setup_full.py

    python setup.py install
    python setup_full.py install
}

function install_pycuda {
    cd "$EXTERNAL"

    safe_call pip_install Mako

    git clone --recursive http://git.tiker.net/trees/pycuda.git
    cd pycuda

    python configure.py
    python setup.py build
    python setup.py install
}

function install_scikits-cuda {
    cd "$EXTERNAL"

    git clone https://github.com/lebedov/scikits.cuda.git
    cd scikits.cuda

    python setup.py install
}

mkdir -p "$EXTERNAL"
mkdir -p "$LIB"
mkdir -p "$DATA"

export LD_LIBRARY_PATH="$LIB"

conda create --yes --prefix "$ENV" python pip
source activate "$ENV"

# you also need to install fftw

safe_call conda_install numpy scipy mkl
safe_call conda_install matplotlib
safe_call conda_install psutil
safe_call conda_install nose
safe_call conda_install ipython
safe_call conda_install nltk
safe_call pip_install pyprind
safe_call pip_install pyfftw
safe_call pip_install --pre line_profiler
safe_call pip_install ruffus
safe_call pip_install sh
safe_call pip_install simplejson
safe_call install_cld2
