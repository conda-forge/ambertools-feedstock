# Begin testing - this will never be merged

# Some amber software will segfault with too long paths, 
# so we can't use AMBERHOME=$PREFIX within conda-build
export AMBERHOME=${HOME}/amber
ln -s ${PREFIX} ${AMBERHOME}

cat << EOF > ${AMBERHOME}/config.h
INSTALLTYPE=serial
AMBER_SOURCE=${SRC_DIR}
AMBER_PREFIX=${AMBERHOME}
BINDIR=${AMBERHOME}/bin
DATDIR=${AMBERHOME}/dat
LIBDIR=${AMBERHOME}/lib
INCDIR=${AMBERHOME}/include
PYTHON=python
SKIP_PYTHON=no
SHARED_SUFFIX=${SHLIB_EXT}
EOF

cp ${PREFIX}/config.h ${SRC_DIR}/config.h
cp ${PREFIX}/config.h ${SRC_DIR}/AmberTools/config.h

export LD_LIBRARY_PATH="${PREFIX}/lib:$LD_LIBRARY_PATH"

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
