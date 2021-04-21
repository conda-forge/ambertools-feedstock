set -euxo pipefail

# Upgrade AmberTools source to the patch level specified by the MINOR version in $PKG_VERSION
for n in {1..5}; do
    export PATCH_LEVEL=$(echo $PKG_VERSION | cut -d. -f2)
    echo "Upgrading source to patch level $PATCH_LEVEL"
    ./update_amber --update-to=AmberTools.${PATCH_LEVEL} && break
done

# Some Fortran binaries segfault because of this flag (addles, make_crd_hg... maybe sander?)
# See PR #24 -- this might be against CF conventions; might also disappear when we provide openmp/mpi
export FFLAGS=${FFLAGS//-fopenmp }
export FORTRANFLAGS=${FORTRANFLAGS//-fopenmp }
export DEBUG_FFLAGS=${DEBUG_FFLAGS//-fopenmp }

# memembed requires -pthread
# from: https://github.com/facebook/Surround360/issues/3
export CXXFLAGS="${CXXFLAGS} -pthread"

# duplicate symbols cause errors on GCC10+ and Clang 11+
# see https://github.com/conda-forge/ambertools-feedstock/pull/50#issuecomment-756171906
# This will get fixed upstream at some point...
# if (( $(printf "%02d%02d" ${PKG_VERSION//./ }) <= 2100 )); then
    export CFLAGS="${CFLAGS:-} -fcommon"
# fi

# Do not vendor some dependencies
# DISABLE_TOOLS: Tools to not build. Accepts a semicolon-seperated list of directories in AmberTools/src.
CMAKE_FLAGS+=" -DDISABLE_TOOLS='parmed;packmol_memgen;'"

CMAKE_FLAGS=""
BUILD_GUI="TRUE"
if [[ "$target_platform" == osx* ]]; then
    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
    # Hack around https://github.com/conda-forge/gfortran_osx-64-feedstock/issues/11
    # Taken from https://github.com/awvwgk/staged-recipes/tree/dftd4/recipes/dftd4
    # See contents of fake-bin/cc1 for an explanation
    export PATH="${PATH}:${RECIPE_DIR}/fake-bin"
    # BUILD_GUI="FALSE"
    # Workarounds for issue #20
    #  In MacOS, `tk` ships some X11 headers that interfere with the X11 libraries
    #  1) delete clobbered X11 headers (mix of tk and xorg)
    rm -rf ${PREFIX}/include/X11/{DECkeysym,HPkeysym,Sunkeysym,X,XF86keysym,Xatom,Xfuncproto}.h
    rm -rf ${PREFIX}/include/X11/{ap_keysym,keysym,keysymdef,Xlib,Xutil,cursorfont}.h
    #  2) Reinstall Xorg dependencies
    #     We temporarily disable the (de)activation scripts because they fail otherwise
    set +u
    mv ${BUILD_PREFIX}/etc/conda/{activate.d,activate.d.bak}
    mv ${BUILD_PREFIX}/etc/conda/{deactivate.d,deactivate.d.bak}
    conda install --yes --no-deps --force-reinstall -p ${PREFIX} xorg-xproto xorg-libx11
    mv ${BUILD_PREFIX}/etc/conda/{activate.d.bak,activate.d}
    mv ${BUILD_PREFIX}/etc/conda/{deactivate.d.bak,deactivate.d}
    set -u

    # This file is mistaken as a source file in OSX, but it's just metadata
    rm ${SRC_DIR}/AmberTools/src/cpptraj/src/xdrfile/version
fi

# Build AmberTools with cmake
mkdir -p build
cd build
cmake ${SRC_DIR} ${CMAKE_FLAGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCOMPILER=MANUAL \
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DBUILD_GUI=${BUILD_GUI} \
    -DCHECK_UPDATES=FALSE \
    -DTRUST_SYSTEM_LIBS=TRUE

make && make install

# Export AMBERHOME automatically
mkdir -p ${PREFIX}/etc/conda/{activate,deactivate}.d
cp ${RECIPE_DIR}/activate.sh ${PREFIX}/etc/conda/activate.d/ambertools.sh
cp ${RECIPE_DIR}/activate.fish ${PREFIX}/etc/conda/activate.d/ambertools.fish
cp ${RECIPE_DIR}/deactivate.sh ${PREFIX}/etc/conda/deactivate.d/ambertools.sh
cp ${RECIPE_DIR}/deactivate.fish ${PREFIX}/etc/conda/deactivate.d/ambertools.fish
