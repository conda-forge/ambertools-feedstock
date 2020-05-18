
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
:: :: DOES NOT WORK!!!! something libdl?
:: sander -h
:: :: DOES NOT WORK!!!! something libdl?
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
add_pdb.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
add_xray.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
cmd /c am1bcc.bat -h
IF %ERRORLEVEL% NEQ 0 exit 1
ambmask.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
ambpdb.exe -h
cmd /c antechamber.bat -h
IF %ERRORLEVEL% NEQ 0 exit 1
cmd /c atomtype.bat -h
IF %ERRORLEVEL% NEQ 0 exit 1
cmd /c bondtype.bat -h
IF %ERRORLEVEL% NEQ 0 exit 1
REM :: Does not execute - errorlevel -1073741515
REM cpptraj.exe -h
REM IF %ERRORLEVEL% NEQ 0 exit 1
REM :: Does not exist?
REM draw_membrane2.exe
REM IF %ERRORLEVEL% NEQ 0 exit 1
cmd /c espgen.bat -h
IF %ERRORLEVEL% NEQ 0 exit 1
REM :: Missing!
REM FEW.pl -h
REM IF %ERRORLEVEL% NEQ 0 exit 1
ffgbsa.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
makeANG_RST.exe -help
IF %ERRORLEVEL% NEQ 0 exit 1
mdgx.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
mdnab.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
minab.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
nfe-umbrella-slice.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
pdb4amber.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
cmd /c prepgen.bat -h
IF %ERRORLEVEL% NEQ 0 exit 1
cmd /c reduce.bat -V
IF %ERRORLEVEL% NEQ 0 exit 1
REM :: Access denied???
REM resp.exe -h
REM IF %ERRORLEVEL% NEQ 0 exit 1
cmd /c respgen.bat -h
IF %ERRORLEVEL% NEQ 0 exit 1
saxs_md.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
sqm.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
teLeap.exe -h
IF %ERRORLEVEL% NEQ 0 exit 1
cmd /c tleap.bat -h
IF %ERRORLEVEL% NEQ 0 exit 1
UnitCell.exe
IF %ERRORLEVEL% NEQ 0 exit 1
rism3d.orave --help
IF %ERRORLEVEL% NEQ 0 exit 1

:: Python scripts
for /f "usebackq tokens=*" %%a in (`where amb2chm_par.py`) do echo %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where amb2chm_psf_crd.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where amb2gro_top_gro.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where ante-MMPBSA.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where car_to_files.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where CartHess2FC.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where ceinutil.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where cpeinutil.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where cpinutil.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where espgen.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where finddgref.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where fitpkaeo.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where fixremdcouts.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where genremdinputs.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where IPMach.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where MCPB.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where metalpdb2mol2.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where MMPBSA.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where mol2rtf.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where PdbSearcher.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where ProScrs.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where softcore_setup.py`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where packmol-memgen`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where parmed`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where pymdpbsa`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where pytleap`) do python %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1

:: Perl scripts
for /f "usebackq tokens=*" %%a in (`where mdout2pymbar.pl`) do perl %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1
for /f "usebackq tokens=*" %%a in (`where sviol`) do perl %%a -h
IF %ERRORLEVEL% NEQ 0 exit 1