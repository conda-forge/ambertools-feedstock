#!/bin/bash

set -euxo pipefail

# Debug installed versions
conda list

### These commands can't be tested from CLI without input arguments
# addles -h
# AddToBox -h
# cestats --help
# charmmlipid2amber.py -h
# ChBox -h
# cphstats -h
# elsize
# gbnsr6 -h
# gem.pmemd
# gwh -h
# hcp_getpdb -h
# make_crd_hg
# makeDIST_RST
# mdout_analyzer.py -h
# metatwist -h
# mm_pbsa_nabnmode
# mm_pbsa_statistics.pl -h
# mm_pbsa.pl
# mmpbsa_py_energy
# mmpbsa_py_nabnmode -h
# molsurf -h
# mpinab2c -h
# nab -h
# nab2c -h
# nef_to_RST -h
# nmode -h
# OptC4.py -h ## REQUIRES OPENMM
# packmol
# paramfit -h
# parmcal -h
# parmchk2
# pbsa
# process_mdout.perl -h
# process_minout.perl -h
# PropPDB -h
# residuegen -h
# rism1d -h
# rism3d.orave -h
# rism3d.snglpnt -h
# rism3d.thermo -h
sander --version
sander.MPI --version
# sander.LES -h
# saxs_rism -h
# senergy -h
# simplepbsa
# sviol2 -h
# xaLeap -h ## REQUIRES DISPLAY
# xleap -h ## REQUIRES DISPLAY
# xparmed -h ## REQUIRES DISPLAY
# XrayPrep ## REQUIRES PHENIX

# this below stopped working with 21.12 - see
# https://github.com/conda-forge/ambertools-feedstock/pull/78#issuecomment-1039141799
# car_to_files.py -h

# These have SyntaxErrors due to Py2k print style and others
# fitpkaeo.py -h
# genremdinputs.py -h
# pymdpbsa -h
# pytleap -h
# softcore_setup.py -h

# These run fine if prompted for help or version messages
add_pdb -h
add_xray -h
am1bcc -h
amb2chm_par.py -h
amb2chm_psf_crd.py -h
amb2gro_top_gro.py -h
ambmask -h
ambpdb -h
ante-MMPBSA.py -h
antechamber -h
atomtype -h
bondtype -h
CartHess2FC.py -h
ceinutil.py -h
cpeinutil.py -h
cpinutil.py -h
cpptraj -h
draw_membrane2
edgembar -h
espgen -h
espgen.py -h
FEW.pl -h
# # removed in 23.0
# ffgbsa -h
finddgref.py -h
fixremdcouts.py -h
IPMach.py -h
makeANG_RST -help
MCPB.py -h
mdgx -h
# # removed in 23.0
# mdnab -h
# mdout2pymbar.pl -h
metalpdb2mol2.py -h
# # removed in 23.0
# minab -h
MMPBSA.py -h
mol2rtf.py -h
ndfes -h
nfe-umbrella-slice -h
# # does not work
# packmol-memgen -h
parmed -h
pdb4amber -h
PdbSearcher.py -h
prepgen -h
ProScrs.py -h
# reduce -V || true | grep -q "reduce."
resp -h
respgen -h
saxs_md -h
sqm -h
sviol -h
teLeap -h
tleap -h
UnitCell

# # Removed in 23.0
# # Debug nab hardcoding BUILD_PREFIX/bin/<compiler>
# echo 'printf( "hello world\n" );' > ltest.nab
# nab -v ltest.nab

# We still test these two to check the PERL5LIBS behavior
mm_pbsa_statistics.pl || true
mm_pbsa.pl || true

# Debug https://github.com/conda-forge/ambertools-feedstock/issues/35
python -c "import parmed; print(parmed.__version__); assert parmed.version >= (4, 0), f'Wrong version: {parmed.version}'"

# These two commands need csh, but CF only has tcsh
ln -s ${PREFIX}/bin/tcsh ${PREFIX}/bin/csh
sgldwt.sh
sgldinfo.sh
last_err_code=$?


if [[ $unit_tests == skip ]]; then
    exit $last_err_code
fi

###### AMBERTOOLS UNIT TESTS ######

set +e

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
PMEMD_GEM=yes
MKL=
EOF

cp ${PREFIX}/config.h ${SRC_DIR}/config.h
cp ${PREFIX}/config.h ${SRC_DIR}/AmberTools/config.h

set +u
export LD_LIBRARY_PATH="${PREFIX}/lib:$LD_LIBRARY_PATH"
set -u

cd ${SRC_DIR}/AmberTools/test
make test
test_err_code=$?

# Show output
echo "************"
echo "Test summary"
echo "************"
cat ${PREFIX}/logs/test_at_serial/at_summary
echo "***************"
echo "Detected errors"
echo "***************"
grep -ihn9 -e "error" -e "failed" --color=always ${PREFIX}/logs/test_at_serial/*.log | sed "s|${PREFIX}|<PREFIX>|g"

exit $test_err_code
