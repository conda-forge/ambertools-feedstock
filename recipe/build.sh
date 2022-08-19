# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./AmberTools/src/reaxff_puremd/PuReMD
cp $BUILD_PREFIX/share/gnuconfig/config.* ./AmberTools/src/netcdf-fortran-4.4.4
cp $BUILD_PREFIX/share/gnuconfig/config.* ./AmberTools/src/fftw-3.3
cp $BUILD_PREFIX/share/gnuconfig/config.* ./AmberTools/src/xblas/config
cp $BUILD_PREFIX/share/gnuconfig/config.* ./AmberTools/src/boost/tools/build/src/engine/boehm_gc
cp $BUILD_PREFIX/share/gnuconfig/config.* ./AmberTools/src/netcdf-4.6.1
set -euxo pipefail

# Upgrade AmberTools source to the patch level specified by the MINOR version in $PKG_VERSION
export PATCH_LEVEL=$(echo $PKG_VERSION | cut -d. -f2)
if [[ $PATCH_LEVEL != 0 ]]; then
    for n in {1..5}; do
        echo "Upgrading source to patch level $PATCH_LEVEL"
        ./update_amber --update-to=AmberTools.${PATCH_LEVEL} && break
    done
fi

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
if (( $(printf "%02d%02d" ${PKG_VERSION//./ }) <= 2200 )); then
    export CFLAGS="${CFLAGS:-} -fcommon"
fi

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
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == 1 && "${CMAKE_CROSSCOMPILING_EMULATOR:-}" == "" ]]; then
    # Assume that netcdf works
    export CMAKE_ARGS="${CMAKE_ARGS} -DNetCDF_F90_WORKS_EXITCODE=0"
    # mikemhenry 2022-04-27
    # remove compile option that doesn't seem to work on M1 + clang
    # https://stackoverflow.com/questions/65966969/why-does-march-native-not-work-on-apple-m1
    # while the SO question is about march, -mtune=native doesn't seem to work either
    cat > remove_mtune_native_flag.patch << "EOF"
    --- cmake/CompilerFlags.cmake	2021-04-26 06:45:47.000000000 -0700
    +++ cmake/CompilerFlags.cmake       2022-04-27 21:55:30.567714491 -0700
    @@ -195,7 +195,7 @@
     if("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang" OR "${CMAKE_C_COMPILER_ID}" STREQUAL "AppleClang")
     	add_flags(C -Wall -Wno-unused-function)
     	
    -	list(APPEND OPT_CFLAGS "-mtune=native")
    +	#list(APPEND OPT_CFLAGS "-mtune=native")
     	
     	#if we are crosscompiling and using clang, tell CMake this
     	if(CROSSCOMPILE)
    @@ -214,7 +214,7 @@
     if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
     	add_flags(CXX -Wall -Wno-unused-function)
     	
    -	list(APPEND OPT_CXXFLAGS "-mtune=native")
    +	#list(APPEND OPT_CXXFLAGS "-mtune=native")
     	
     	if(CROSSCOMPILE)
     		set(CMAKE_CXX_COMPILER_TARGET ${TARGET_TRIPLE})
EOF

    patch cmake/CompilerFlags.cmake < remove_mtune_native_flag.patch

fi

# Build AmberTools with cmake
mkdir -p build
cd build
cmake ${CMAKE_ARGS} ${SRC_DIR} ${CMAKE_FLAGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCOMPILER=MANUAL \
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DBUILD_GUI=${BUILD_GUI} \
    -DCHECK_UPDATES=FALSE \
    -DTRUST_SYSTEM_LIBS=TRUE

make
make install

# Export AMBERHOME automatically
mkdir -p ${PREFIX}/etc/conda/{activate,deactivate}.d
cp ${RECIPE_DIR}/activate.sh ${PREFIX}/etc/conda/activate.d/ambertools.sh
cp ${RECIPE_DIR}/activate.fish ${PREFIX}/etc/conda/activate.d/ambertools.fish
cp ${RECIPE_DIR}/deactivate.sh ${PREFIX}/etc/conda/deactivate.d/ambertools.sh
cp ${RECIPE_DIR}/deactivate.fish ${PREFIX}/etc/conda/deactivate.d/ambertools.fish
