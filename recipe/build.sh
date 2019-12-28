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
echo 'N' | ./configure $NO_SSE -noX11 -norism --with-netcdf ${PREFIX} --with-python ${PYTHON} --python-install local $COMPILER_SET
# using the -openmp flag causes packages not to be included in the build
# however, the RISM model requires OpenMP, so -norism is set
# the --prefix tag does not work, so copy the files manually to $PREFIX

bash amber.sh

make
make install

mkdir $PREFIX/dat

cp -rf bin/* $PREFIX/bin/
cp -rf dat/* $PREFIX/dat/
cp -rf lib/* $PREFIX/lib/
cp -rf include/* $PREFIX/include/
