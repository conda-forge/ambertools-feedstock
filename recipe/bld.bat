SET "CWD=%cd%"
FOR /F "tokens=* USEBACKQ" %%F IN (`bash -c "echo $PKG_VERSION | cut -d. -f2"`) DO (
    SET PATCH_LEVEL=%%F || goto :error
)
ECHO "Upgrading source to patch level %PATCH_LEVEL%" || goto :error
python update_amber --update-to=AmberTools.%PATCH_LEVEL% || goto :error

:: Additional build dependencies
copy extra-bc\bin\bc.exe %BUILD_PREFIX%\Library\bin\bc.exe
copy tcsh.exe %BUILD_PREFIX%\Library\bin\csh.exe
REM copy libxblas.a %LIBRARY_PREFIX%\lib\libxblas.a
REM copy %LIBRARY_PREFIX%\lib\fftw3.lib %LIBRARY_PREFIX%\lib\fftw3.a
:: Poor man patch :)
:: This adds lines 74,75
copy %RECIPE_DIR%\replacements\LibraryUtils.cmake.patched %SRC_DIR%\cmake\LibraryUtils.cmake
:: This adds gcc as the default toolset for Boost (otherwise it picks msvc)
copy %RECIPE_DIR%\replacements\Boost.cmake %SRC_DIR%\AmberTools\src\boost\CMakeLists.txt
:: Python Extension patches
:: + Distutils must be monkey-patched so it returns the correct vcruntime140 lib
:: + We need to patch all Python Extension objects (setup.py) so they define
::     -> library_dirs=[sys.prefix]
copy %RECIPE_DIR%\replacements\parmed.setup.py %SRC_DIR%\AmberTools\src\parmed\setup.py
copy %RECIPE_DIR%\replacements\pysander.setup.py %SRC_DIR%\AmberTools\src\pysander\setup.py


:: Build AmberTools with cmake
rmdir build /s /q
mkdir build || goto :error
cd build || goto :error
set "CMAKE_GENERATOR=MinGW Makefiles"
:: This does not work, but it should... that's why we need Boost.cmake replacement above
set "BOOST_JAM_TOOLSET=gcc"
cmake %SRC_DIR% %CMAKE_FLAGS% ^
    -DCMAKE_PREFIX_PATH=%PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCOMPILER=AUTO ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    -DBUILD_GUI=FALSE ^
    -DCHECK_UPDATES=FALSE ^
    -DSKIP_PYTHON_PACKAGE_CHECKS=TRUE ^
    || goto :error
:: Disable for now
:: -DTRUST_SYSTEM_LIBS=TRUE ^

mingw32-make
mingw32-make || goto :error
mingw32-make install || goto :error

:: Export AMBERHOME automatically
mkdir %PREFIX%\etc\conda\activate.d || goto :error
mkdir %PREFIX%\etc\conda\deactivate.d || goto :error
copy %RECIPE_DIR%\activate.sh %PREFIX%\etc\conda\activate.d\ambertools.sh || goto :error
copy %RECIPE_DIR%\activate.fish %PREFIX%\etc\conda\activate.d\ambertools.fish || goto :error
copy %RECIPE_DIR%\activate.bat %PREFIX%\etc\conda\activate.d\ambertools.bat || goto :error
copy %RECIPE_DIR%\deactivate.sh %PREFIX%\etc\conda\deactivate.d\ambertools.sh || goto :error
copy %RECIPE_DIR%\deactivate.fish %PREFIX%\etc\conda\deactivate.d\ambertools.fish || goto :error
copy %RECIPE_DIR%\deactivate.bat %PREFIX%\etc\conda\deactivate.d\ambertools.bat || goto :error

goto :EOF

:error
cd "%CWD%"
echo Failed with error #%errorlevel%.
exit /b %errorlevel%