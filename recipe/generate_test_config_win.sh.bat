set -eux

srcdir=$(cygpath -u ${SRC_DIR})
amber_home=$(cygpath -u ${CONDA_PREFIX})/Library
cat << EOF > $amber_home/config.h
INSTALLTYPE=serial
AMBER_SOURCE=$srcdir
AMBER_PREFIX=$amber_home
BINDIR=$amber_home/bin
DATDIR=$amber_home/dat
LIBDIR=$amber_home/lib
INCDIR=$amber_home/include
PYTHON=python
SKIP_PYTHON=no
SHARED_SUFFIX=.dll
PMEMD_GEM=yes
MKL=
EOF