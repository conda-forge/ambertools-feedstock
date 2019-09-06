if [ $(uname) == "Darwin" ]; then
    export COMPILER_SET="clang"
fi

if [ $(uname) == "Linux" ]; then
    export COMPILER_SET="gnu"
fi

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
