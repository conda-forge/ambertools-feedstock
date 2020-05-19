:::::: These commands can't be tested from CLI without input arguments
:: :: Works
:: addles -h
:: :: Works
:: AddToBox -h
:: :: Works
:: cestats --help
:: :: Works
:: charmmlipid2amber.py -h
:: :: Works
:: ChBox -h
::: :: Works
:: cphstats -h
:: :: Works
:: elsize
:: :: Works
:: gbnsr6 -h
:: :: Works
:: gem.pmemd
:: :: Works
:: gwh -h
:: :: Works
:: hcp_getpdb -h
:: :: Works
:: make_crd_hg
:: :: Works
:: makeDIST_RST
:: :: Works
:: mdout_analyzer.py -h
:: :: Works
:: metatwist -h
:: :: Works
:: mm_pbsa_nabnmode
:: :: Works ??
:: mm_pbsa_statistics.pl -h
:: :: Works
:: mm_pbsa.pl
:: :: Works
:: mmpbsa_py_energy
:: :: Works
:: mmpbsa_py_nabnmode -h
:: :: Works
:: molsurf -h
:: :: Possible error? nab2c: Internal error: nfname required
:: mpinab2c -h
:: :: Works
:: nab -h
:: :: Works
:: nab2c -h
:: :: Works
:: nef_to_RST -h
:: :: Works
:: nmode -h
:: OptC4.py -h :::: REQUIRES OPENMM
:: :: Works
:: packmol
:: :: Works
:: paramfit -h
:: :: Works
:: parmcal -h
:: :: Works
:: parmchk2
:: :: Works
:: pbsa
:: :: Works
:: process_mdout.perl -h
:: :: Works
:: process_minout.perl -h
:: :: Works
:: PropPDB -h
:: :: Works
:: residuegen -h
:: :: Works
:: sander -h
:: :: Works
:: sander.LES -h
:: :: Works
:: saxs_rism -h
:: :: Works
:: perl senergy -h
:: :: Works
:: rism1d --help
:: :: Works
:: rism3d.snglpnt --help
:: :: Works
:: rism3d.thermo --help
:: :: Works
:: simplepbsa
:: :: Works
:: perl sviol2 -h
:: :: ERROR - MISSING!!
:: xaLeap -h :::: REQUIRES DISPLAY
:: :: ERROR - MISSING!!
:: xleap -h :::: REQUIRES DISPLAY
:: :: Works
:: xparmed -h :::: REQUIRES DISPLAY
:: :: Works
:: XrayPrep :::: REQUIRES PHENIX

:: These run fine if prompted for help or version messages
add_pdb.exe -h  || goto :error
add_xray.exe -h  || goto :error
cmd /c am1bcc.bat -h  || goto :error
ambmask.exe -h  || goto :error
ambpdb.exe -h
cmd /c antechamber.bat -h  || goto :error
cmd /c atomtype.bat -h  || goto :error
cmd /c bondtype.bat -h  || goto :error
cpptraj.exe -h  || goto :error
REM :: Missing! This is not available on Windows
REM :: until we get FEW to build (Perl deps needd)
REM draw_membrane2.exe  || goto :error
REM cmd /c espgen.bat -h  || goto :error
REM :: Missing! This is not available on Windows.
REM :: until we get FEW to build (Perl deps needd)
REM FEW.pl -h  || goto :error
REM ffgbsa.exe -h  || goto :error
makeANG_RST.exe -help  || goto :error
mdgx.exe -h  || goto :error
mdnab.exe -h  || goto :error
minab.exe -h  || goto :error
nfe-umbrella-slice.exe -h  || goto :error
pdb4amber.exe -h  || goto :error
cmd /c prepgen.bat -h  || goto :error
cmd /c reduce.bat -V  || goto :error
REM :: ERROR - Access denied???
REM resp.exe -h  || goto :error
REM cmd /c respgen.bat -h  || goto :error
saxs_md.exe -h  || goto :error
sqm.exe -h  || goto :error
teLeap.exe -h  || goto :error
cmd /c tleap.bat -h  || goto :error
UnitCell.exe  || goto :error
rism3d.orave --help  || goto :error

:: Python scripts
for /f "usebackq tokens=*" %%a in (`where amb2chm_par.py`) do echo %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where amb2chm_psf_crd.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where amb2gro_top_gro.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where ante-MMPBSA.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where car_to_files.py`) do python %%a -h  || goto :error
REM :: This won't work without scipy
REM for /f "usebackq tokens=*" %%a in (`where CartHess2FC.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where ceinutil.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where cpeinutil.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where cpinutil.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where espgen.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where finddgref.py`) do python %%a -h  || goto :error
REM :: This won't work without scipy
REM for /f "usebackq tokens=*" %%a in (`where fitpkaeo.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where fixremdcouts.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where genremdinputs.py`) do python %%a -h  || goto :error
REM :: This won't work without scipy
REM for /f "usebackq tokens=*" %%a in (`where IPMach.py`) do python %%a -h  || goto :error
REM :: This won't work without scipy
REM for /f "usebackq tokens=*" %%a in (`where MCPB.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where metalpdb2mol2.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where MMPBSA.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where mol2rtf.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where PdbSearcher.py`) do python %%a -h  || goto :error
REM :: This won't work without scipy
REM for /f "usebackq tokens=*" %%a in (`where ProScrs.py`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where softcore_setup.py`) do python %%a -h  || goto :error
REM :: This won't work without scipy
REM for /f "usebackq tokens=*" %%a in (`where packmol-memgen`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where parmed`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where pymdpbsa`) do python %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where pytleap`) do python %%a -h  || goto :error

:: Perl scripts
for /f "usebackq tokens=*" %%a in (`where mdout2pymbar.pl`) do perl %%a -h  || goto :error
for /f "usebackq tokens=*" %%a in (`where sviol`) do perl %%a -h  || goto :error

IF "%unit_tests%" == "skip" ( goto :EOF )

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: UNIT TEST SUITE
:: to run it, set `unit_tests = run` in conda_build_config.yaml
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo on

conda install -yq -c jaimergp m2-tcsh

set "SRC_DIR=%AMBERHOME%\..\..\test_tmp"
:: Re-export in Unix-style paths
for /f "usebackq tokens=*" %%a in (`cygpath -u %CONDA_PREFIX%`) do set "AMBERHOME=%%a"   || goto :error
set "AMBERHOME=%AMBERHOME%/Library"
:: Prepare environment
bash -lc "mkdir /tmp"
bash -l generate_config_win.sh || goto :error
copy "%CONDA_PREFIX%\Library\config.h" "%SRC_DIR%\config.h"  || goto :error
copy "%CONDA_PREFIX%\Library\config.h" "%SRC_DIR%\AmberTools\config.h"  || goto :error
copy "%CONDA_PREFIX%\mingw-w64\bin\mingw32-make.exe" "%CONDA_PREFIX%\mingw-w64\bin\make.exe"

:::: Wrapped command fixes
:: NAB
echo "${CONDA_PREFIX}/Library/bin/wrapped_progs/nab.exe" $@ > "%CONDA_PREFIX%\Library\bin\nab"

:: Run!
cd %SRC_DIR%\AmberTools\test  || goto :error
bash -lc "make test" || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%