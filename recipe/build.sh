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
BUILD_GUI="TRUE"
if [[ "$target_platform" == osx* ]]; then
    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
    BUILD_GUI="FALSE"
    # Hack around https://github.com/conda-forge/gfortran_osx-64-feedstock/issues/11
    # Taken from https://github.com/awvwgk/staged-recipes/tree/dftd4/recipes/dftd4
    # See contents of fake-bin/cc1 for an explanation
    export PATH="${PATH}:${RECIPE_DIR}/fake-bin"
fi

# Build AmberTools with cmake
mkdir -p build
cd build
cmake ${SRC_DIR} ${CMAKE_FLAGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCOMPILER=MANUAL \
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DDOWNLOAD_MINICONDA=FALSE \
    -DBUILD_GUI=${BUILD_GUI} \
    -DCHECK_UPDATES=FALSE

make && make install

# Export AMBERHOME automatically
mkdir -p ${PREFIX}/etc/conda/{activate,deactivate}.d
cp ${RECIPE_DIR}/activate.sh ${PREFIX}/etc/conda/activate.d/ambertools.sh
cp ${RECIPE_DIR}/activate.fish ${PREFIX}/etc/conda/activate.d/ambertools.fish
cp ${RECIPE_DIR}/deactivate.sh ${PREFIX}/etc/conda/deactivate.d/ambertools.sh
cp ${RECIPE_DIR}/deactivate.fish ${PREFIX}/etc/conda/deactivate.d/ambertools.fish

# Begin testing - this will never be merged

cat << EOF > ${PREFIX}/config.h
INSTALLTYPE=serial
AMBER_SOURCE=${SRC_DIR}
AMBER_PREFIX=${PREFIX}
BINDIR=${PREFIX}/bin
DATDIR=${PREFIX}/dat
LIBDIR=${PREFIX}/lib
INCDIR=${PREFIX}/include
PYTHON=python
SKIP_PYTHON=no
SHARED_SUFFIX=${SHLIB_EXT}
EOF

set +eux
export AMBERHOME=${PREFIX}
export LD_LIBRARY_PATH="${PREFIX}/lib:$LD_LIBRARY_PATH"
export PERL5LIB="${PREFIX}/lib/perl:$PERL5LIB"
cd ${SRC_DIR}/AmberTools/test
make test

# Show output
echo "************"
echo "Test summary"
echo "************"
cat ${PREFIX}/logs/test_at_serial/at_summary
echo "***************"
echo "Detected errors"
echo "***************"
grep -ihn9 -e "error" -e "failed" --color=always ${PREFIX}/logs/test_at_serial/*.log | sed "s|${PREFIX}|<PREFIX>|g"
