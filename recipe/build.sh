if [[ "$target_platform" == osx* ]]; then
    export COMPILER_SET="clang"
fi

if [[ "$target_platform" == linux* ]]; then
    export COMPILER_SET="gnu"
fi

NO_SSE=""
if [[ "$target_platform" == linux-ppc64le ]]; then
    # needed in ppc64le because otherwise fftw-3.3 does not compile
    NO_SSE="-nosse"
fi


# Upgrade AmberTools source to the patch level specified by the MINOR version in $PKG_VERSION
for n in {1..5}; do
    export PATCH_LEVEL=$(echo $PKG_VERSION | cut -d. -f2)
    echo "Upgrading source to patch level $PATCH_LEVEL"
    ./update_amber --update-to=AmberTools.${PATCH_LEVEL} && break
done

# Build AmberTools without further patching
echo 'N' | ./configure $NO_SSE -noX11 -norism -nofftw3 --with-netcdf ${PREFIX} --with-python ${PYTHON} --python-install local $COMPILER_SET
# using the -openmp flag causes packages not to be included in the build
# however, the RISM model requires OpenMP, so -norism is set
# the --prefix tag does not work, so copy the files manually to $PREFIX

# Patch config.h after ./configure has run to trick make into thinking
# that boost and fftw3 have been compiled from source. We are providing
# conda packages instead. Point to the correct X11 libs location too.
echo "Patching config.h..."
sed -e "s|^MEMEMBED=.*|MEMEMBED=yes|" \
    -e "s|^FFTW3=.*|FFTW3=|" \
    -e "s|^FFTWLIB=.*|FFTWLIB=-lfftw3|" \
    -e "s|^MAKE_XLEAP=.*|MAKE_XLEAP=install_xleap|" \
    -e "s|^XHOME=.*|XHOME=${PREFIX}|" \
    -e "s|^XLIBS=.*|XLIBS=-L${PREFIX}/lib|" \
    -e "s|^LAPACK=.*|LAPACK=skip|" \
    -e "s|^BLAS=.*|BLAS=skip|" \
    -e "\$aCONDA_PREFIX=${PREFIX}" \
    -i config.h

cp -f config.h AmberTools/src
cp -f config.h AmberTools/src/cphstats

echo "Resulting config.h..."
cat config.h

make
make install

mkdir $PREFIX/dat
cp -rf bin/* $PREFIX/bin/
cp -rf dat/* $PREFIX/dat/
cp -rf lib/* $PREFIX/lib/
cp -rf include/* $PREFIX/include/

# Export AMBERHOME automatically
mkdir -p ${PREFIX}/etc/conda/{activate,deactivate}.d
cp ${RECIPE_DIR}/activate.sh ${PREFIX}/etc/conda/activate.d/ambertools.sh
cp ${RECIPE_DIR}/deactivate.sh ${PREFIX}/etc/conda/deactivate.d/ambertools.sh
