@echo off
call :%*
goto :eof

:perl_setup
if not defined perl_type set perl_type=strawberry
cinst -y curl
if "%perl_type%" == "cygwin" (
  start /wait c:\cygwin\setup-x86.exe -q -g -P perl -P binutils -P make -P gcc -P gcc-core -P gcc-g++ -P make -P pkg-config -P libcrypt-devel -P openssl-devel -P curl
  set "PATH=C:\cygwin\usr\local\bin;C:\cygwin\bin;%PATH%"
) else if "%perl_type%" == "strawberry" (
  if not defined perl_version (
    cinst -y StrawberryPerl
  ) else (
    cinst -y StrawberryPerl --version %perl_version%
  )
  if errorlevel 1 (
    type C:\ProgramData\chocolatey\logs\chocolatey.log
    exit /b 1
  )
  set "PATH=C:\Strawberry\perl\site\bin;C:\Strawberry\perl\bin;C:\Strawberry\c\bin;%PATH%"
) else (
  echo.Unknown perl type "%perl_type%"! 1>&2
  exit /b 1
)
for /f "usebackq delims=" %%d in (`perl -MConfig -e"print $Config{make}"`) do set "make=%%d"
set "perl=perl"
set "cpanm=call .appveyor.cmd cpanm"
set "cpan=%perl% -S cpan"
set TAR_OPTIONS=--warning=no-unknown-keyword
goto :eof

:cpanm
%perl% -S cpanm >NUL 2>&1
if ERRORLEVEL 1 (
  curl -V >NUL 2>&1
  if ERRORLEVEL 1 cinst -y curl
  curl -k -L https://cpanmin.us/ -o "%TEMP%\cpanm"
  %perl% "%TEMP%\cpanm" -n App::cpanminus
)
set "cpanm=%perl% -S cpanm"
%cpanm% %*
goto :eof

:local_lib
if "%perl_type%" == "cygwin" goto :local_lib_cygwin
%perl% -Ilib -Mlocal::lib=--shelltype=cmd %* > %TEMP%\local-lib.bat
call %TEMP%\local-lib.bat
del %TEMP%\local-lib.bat
goto :eof

:local_lib_cygwin
for /f "usebackq delims=" %%d in (`sh -c "cygpath -w $HOME/perl5"`) do (
  c:\perl\bin\perl.exe -Ilib -Mlocal::lib - %%d --shelltype=cmd > "%TEMP%\local-lib.bat"
)
setlocal
  call "%TEMP%\local-lib.bat"
endlocal & set "PATH=%PATH%"
set "PATH_BACK=%PATH%"
%perl% -Ilib -Mlocal::lib - --shelltype=cmd > "%TEMP%\local-lib.bat"
call "%TEMP%\local-lib.bat"
set "PATH=%PATH_BACK%"
del "%TEMP%\local-lib.bat"
goto :eof

:eof
