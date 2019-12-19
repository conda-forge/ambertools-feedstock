if [ $(uname) == "Darwin" ]; then
    export COMPILER_SET="clang"
fi

if [ $(uname) == "Linux" ]; then
    export COMPILER_SET="gnu"
fi

# tar -xf AmberTools19.tar.bz2.cmlqap
# cd amber18

# Upgrade AmberTools source to the patch level specified by the MINOR version in $PKG_VERSION
for n in {1..5}; do # try up to five times before failing
    export PATCH_LEVEL=$(echo $PKG_VERSION | cut -d. -f2)
    echo "Upgrading source to patch level $PATCH_LEVEL"
    ./update_amber --update-to=AmberTools.${PATCH_LEVEL} && break
done

# patch -i $RECIPE_DIR/configure.patch -p 2

# Build AmberTools without further patching
echo 'N' | ./configure  -noX11 -norism --with-python ${PREFIX}/bin/python --python-install local $COMPILER_SET
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
