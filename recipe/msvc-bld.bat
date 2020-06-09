SET "CWD=%cd%"
FOR /F "tokens=* USEBACKQ" %%F IN (`bash -c "echo $PKG_VERSION | cut -d. -f2"`) DO (
    SET PATCH_LEVEL=%%F || goto :error
)
ECHO "Upgrading source to patch level %PATCH_LEVEL%" || goto :error
%PYTHON% update_amber --update-to=AmberTools.%PATCH_LEVEL% || goto :error

:: Additional build dependencies
copy extra-bc\bin\bc.exe %BUILD_PREFIX%\Library\bin\bc.exe
copy tcsh.exe %BUILD_PREFIX%\Library\bin\csh.exe
copy libxblas.a %LIBRARY_PREFIX%\lib\libxblas.a

:: Build AmberTools with cmake
rmdir build /s /q
mkdir build || goto :error
cd build || goto :error
set "CMAKE_GENERATOR=NMake Makefiles"
cmake %SRC_DIR% %CMAKE_FLAGS% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCOMPILER=AUTO ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    -DBUILD_GUI=FALSE ^
    -DCHECK_UPDATES=FALSE ^
    -DTRUST_SYSTEM_LIBS=TRUE ^
    -DMKL_INTERFACE_LIBRARY=%LIBRARY_LIB%\mkl_intel_lp64_dll.lib ^
    -DXBLAS_LIBRARY=%LIBRARY_LIB%\libxblas.a ^
    || goto :error

nmake || goto :error
nmake install || goto :error

:: Export AMBERHOME automatically
mkdir %PREFIX%/etc/conda/activate.d || goto :error
mkdir %PREFIX%/etc/conda/deactivate.d || goto :error
cp %RECIPE_DIR%/activate.sh %PREFIX%/etc/conda/activate.d/ambertools.sh || goto :error
cp %RECIPE_DIR%/activate.fish %PREFIX%/etc/conda/activate.d/ambertools.fish || goto :error
cp %RECIPE_DIR%/activate.bat %PREFIX%/etc/conda/activate.d/ambertools.bat || goto :error
cp %RECIPE_DIR%/deactivate.sh %PREFIX%/etc/conda/deactivate.d/ambertools.sh || goto :error
cp %RECIPE_DIR%/deactivate.fish %PREFIX%/etc/conda/deactivate.d/ambertools.fish || goto :error
cp %RECIPE_DIR%/deactivate.bat %PREFIX%/etc/conda/deactivate.d/ambertools.bat || goto :error

goto :EOF

:error
cd "%CWD%"
echo Failed with error #%errorlevel%.
exit /b %errorlevel%