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
if (( $(printf "%02d%02d" ${PKG_VERSION//./ }) <= 2205 )); then
    export CFLAGS="${CFLAGS:-} -fcommon"
fi

CMAKE_FLAGS=""
BUILD_GUI="FALSE"
#if [[ "$target_platform" == osx* ]]; then
#    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
#    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
#    # Hack around https://github.com/conda-forge/gfortran_osx-64-feedstock/issues/11
#    # Taken from https://github.com/awvwgk/staged-recipes/tree/dftd4/recipes/dftd4
#    # See contents of fake-bin/cc1 for an explanation
#    export PATH="${PATH}:${RECIPE_DIR}/fake-bin"
#    # BUILD_GUI="FALSE"
#    # Workarounds for issue #20
#    #  In MacOS, `tk` ships some X11 headers that interfere with the X11 libraries
#    #  1) delete clobbered X11 headers (mix of tk and xorg)
#    rm -rf ${PREFIX}/include/X11/{DECkeysym,HPkeysym,Sunkeysym,X,XF86keysym,Xatom,Xfuncproto}.h
#    rm -rf ${PREFIX}/include/X11/{ap_keysym,keysym,keysymdef,Xlib,Xutil,cursorfont}.h
#    #  2) Reinstall Xorg dependencies
#    #     We temporarily disable the (de)activation scripts because they fail otherwise
#    set +u
#    mv ${BUILD_PREFIX}/etc/conda/{activate.d,activate.d.bak}
#    mv ${BUILD_PREFIX}/etc/conda/{deactivate.d,deactivate.d.bak}
#    CONDA_SUBDIR="$target_platform" conda install --yes --no-deps --force-reinstall -p ${PREFIX} xorg-xproto xorg-libx11
#    mv ${BUILD_PREFIX}/etc/conda/{activate.d.bak,activate.d}
#    mv ${BUILD_PREFIX}/etc/conda/{deactivate.d.bak,deactivate.d}
#    set -u
#fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == 1 && "${CMAKE_CROSSCOMPILING_EMULATOR:-}" == "" ]]; then
    # Assume that netcdf works
    export CMAKE_ARGS="${CMAKE_ARGS} -DNetCDF_F90_WORKS_EXITCODE=0"
fi

# We need to build some x86 bins to compile arm64, so we need to save the paths here so we can use them later
CC_TARGET=${CC}
CXX_TARGET=${CXX}
FC_TARGET=${FC}

if [[ "${build_platform}" != "${target_platform}" ]]; then
    # Build host tools first
    mkdir -p ${BUILD_PREFIX}/amber_host_tools
    mkdir -p build_host_tools
    cd build_host_tools || exit
	CC=${CC_FOR_BUILD} 
	CXX=${CXX_FOR_BUILD}
	FC=${FC_FOR_BUILD}
    cmake ${CMAKE_ARGS} ${SRC_DIR} ${CMAKE_FLAGS} \
        -DBUILD_HOST_TOOLS=TRUE \
        -DCOMPILER=MANUAL \
        -DCMAKE_INSTALL_PREFIX="${BUILD_PREFIX}/amber_host_tools"
	VERBOSE=1 make
	VERBOSE=1 make install

    CMAKE_FLAGS+=" -DUSE_HOST_TOOLS=TRUE"
    CMAKE_FLAGS+=" -DHOST_TOOLS_DIR=${BUILD_PREFIX}/amber_host_tools"
	if [[ "$target_platform" == "osx-arm64" ]]; then
		echo "editing out mtune native for mtune apple-m1"
		# This is super hacky -- but now that we built the host tools, we need to change the flag to build for m1
		# TODO see if just removing -mtune=native is enough
		find ../ \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i 's/-mtune=native/-march=armv8.3-a/g'
		#find ../ \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i 's/CXX -stdlib=libc++/CXX -stdlib=libc++ -arch armv8.3-a/g'
		# Add arm64 to the LDFLAGS 
		#export LDFLAGS="$LDFLAGS -arch arm64"
		# Tell cmake now we want to build osx-arm64
		CMAKE_FLAGS+=" -DCMAKE_OSX_ARCHITECTURES=arm64 -DCROSSCOMPILE=TRUE -DTARGET_TRIPLE=arm64 "
	fi
	cd ${BUILD_PREFIX} || exit
fi

# Build AmberTools with cmake
mkdir -p build
cd build || exit
# Now we go back to the target arch
CC=${CC_TARGET}
CXX=${CXX_TARGET}
FC=${FC_TARGET}

if [ "${mpi}" = "nompi" ]; then ENABLE_MPI=FALSE; else ENABLE_MPI=TRUE; fi

if [[ "${cuda_compiler_version}" = "None" ]]; then
    ENABLE_CUDA=FALSE
else
    ENABLE_CUDA=TRUE
    # necessary to find cicc on CUDA >=12.0
    export PATH="${PATH}:${BUILD_PREFIX}/nvvm/bin"

    if [[ ${cuda_compiler_version} == 11.8 ]]; then
        export CMAKE_CUDA_ARCHS="35-real;53-real;62-real;72-real;75-real;80-real;86-real;89"
    elif [[ ${cuda_compiler_version} == 12.0 ]]; then
        export CMAKE_CUDA_ARCHS="53-real;62-real;72-real;75-real;80-real;86-real;89-real;90"
	elif [[ ${cuda_compiler_version} == 12.6 ]]; then
        export CMAKE_CUDA_ARCHS="53-real;62-real;72-real;75-real;80-real;86-real;89-real;90"
    fi
    export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_CUDA_ARCHITECTURES=${CMAKE_CUDA_ARCHS}"
fi

cmake ${CMAKE_ARGS} ${SRC_DIR} ${CMAKE_FLAGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCOMPILER=MANUAL \
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DBUILD_GUI=${BUILD_GUI} \
    -DCHECK_UPDATES=FALSE \
	-DDISABLE_TOOLS="nab" \
    -DMPI=${ENABLE_MPI} \
    -DCUDA=${ENABLE_CUDA} \
    -DTRUST_SYSTEM_LIBS=TRUE

VERBOSE=1 make
VERBOSE=1 make install


# Export AMBERHOME automatically
mkdir -p ${PREFIX}/etc/conda/{activate,deactivate}.d
cp ${RECIPE_DIR}/activate.sh ${PREFIX}/etc/conda/activate.d/ambertools.sh
cp ${RECIPE_DIR}/activate.fish ${PREFIX}/etc/conda/activate.d/ambertools.fish
cp ${RECIPE_DIR}/deactivate.sh ${PREFIX}/etc/conda/deactivate.d/ambertools.sh
cp ${RECIPE_DIR}/deactivate.fish ${PREFIX}/etc/conda/deactivate.d/ambertools.fish
