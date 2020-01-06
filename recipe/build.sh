set -euxo pipefail

# Patch manually to avoid issues with newlines
sed 's/\r$//g' ${RECIPE_DIR}/patches/amber19-fix-cmake.patch > amber19-fix-cmake.patch
sed -i 's/\r$//g' ${SRC_DIR}/cmake/*.cmake
patch -p1 --ignore-whitespace -t -i amber19-fix-cmake.patch || true

# Upgrade AmberTools source to the patch level specified by the MINOR version in $PKG_VERSION
for n in {1..5}; do
    export PATCH_LEVEL=$(echo $PKG_VERSION | cut -d. -f2)
    echo "Upgrading source to patch level $PATCH_LEVEL"
    ./update_amber --update-to=AmberTools.${PATCH_LEVEL} && break
done

# Build AmberTools with cmake
mkdir build
cd build
cmake ${SRC_DIR} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCOMPILER=MANUAL \
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DDOWNLOAD_MINICONDA=FALSE \
    -DCHECK_UPDATES=FALSE
#    -DFORCE_EXTERNAL_LIBS="netcdf;netcdf-fortran"

make && make install

# Export AMBERHOME automatically
mkdir -p ${PREFIX}/etc/conda/{activate,deactivate}.d
cp ${RECIPE_DIR}/activate.sh ${PREFIX}/etc/conda/activate.d/ambertools.sh
cp ${RECIPE_DIR}/activate.fish ${PREFIX}/etc/conda/activate.d/ambertools.fish
cp ${RECIPE_DIR}/deactivate.sh ${PREFIX}/etc/conda/deactivate.d/ambertools.sh
cp ${RECIPE_DIR}/deactivate.fish ${PREFIX}/etc/conda/deactivate.d/ambertools.fish
