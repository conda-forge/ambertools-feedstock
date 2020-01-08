set -euxo pipefail

# Upgrade AmberTools source to the patch level specified by the MINOR version in $PKG_VERSION
for n in {1..5}; do
    export PATCH_LEVEL=$(echo $PKG_VERSION | cut -d. -f2)
    echo "Upgrading source to patch level $PATCH_LEVEL"
    ./update_amber --update-to=AmberTools.${PATCH_LEVEL} && break
done

# Patch manually to avoid issues with newlines
perl -p  -e 's/\r$//g' ${RECIPE_DIR}/patches/amber19-fix-cmake.patch > amber19-fix-cmake.patch
perl -pi -e 's/\r$//g' ${SRC_DIR}/cmake/*.cmake
patch -p1 --ignore-whitespace -t -i amber19-fix-cmake.patch || true

CMAKE_FLAGS=""
if [[ "$target_platform" == osx* ]]; then
    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
    export FFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} ${FFLAGS}"
fi

# Build AmberTools with cmake
mkdir -p build
cd build
cmake ${SRC_DIR} ${CMAKE_FLAGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCOMPILER=MANUAL \
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DDOWNLOAD_MINICONDA=FALSE \
    -DBUILD_GUI=TRUE \
    -DCHECK_UPDATES=FALSE

make && make install

# Export AMBERHOME automatically
mkdir -p ${PREFIX}/etc/conda/{activate,deactivate}.d
cp ${RECIPE_DIR}/activate.sh ${PREFIX}/etc/conda/activate.d/ambertools.sh
cp ${RECIPE_DIR}/activate.fish ${PREFIX}/etc/conda/activate.d/ambertools.fish
cp ${RECIPE_DIR}/deactivate.sh ${PREFIX}/etc/conda/deactivate.d/ambertools.sh
cp ${RECIPE_DIR}/deactivate.fish ${PREFIX}/etc/conda/deactivate.d/ambertools.fish
