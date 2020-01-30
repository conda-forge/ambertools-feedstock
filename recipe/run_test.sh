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

cp ${PREFIX}/config.h ${SRC_DIR}/config.h
cp ${PREFIX}/config.h ${SRC_DIR}/AmberTools/config.h

export AMBERHOME=${PREFIX}
export LD_LIBRARY_PATH="${PREFIX}/lib:$LD_LIBRARY_PATH"
# export PERL5LIB="${PREFIX}/lib/perl:$PERL5LIB"
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
