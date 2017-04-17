@ECHO OFF

pushd %~dp0

REM Command file for Sphinx documentation

if "%SPHINXBUILD%" == "" (
	set SPHINXBUILD=sphinx-build
)
set SOURCEDIR=source
set BUILDDIR=build
set BUILDBRANCH=gh-pages
set SPHINXOPTS=-c .
set SPHINXPROJ=EffectiveDjango

if "%1" == "" goto help
if "%1" == "push" goto push

%SPHINXBUILD% >NUL 2>NUL
if errorlevel 9009 (
	echo.
	echo.The 'sphinx-build' command was not found. Make sure you have Sphinx
	echo.installed, then set the SPHINXBUILD environment variable to point
	echo.to the full path of the 'sphinx-build' executable. Alternatively you
	echo.may add the Sphinx directory to PATH.
	echo.
	echo.If you don't have Sphinx installed, grab it from
	echo.http://sphinx-doc.org/
	exit /b 1
)

%SPHINXBUILD% -M %1 %SOURCEDIR% %BUILDDIR% %SPHINXOPTS%
goto end

:push
for /f %%i in ('git --git-dir=$(BUILDDIR)\..\.git\modules\build log -1 --pretty=format:"%s (%h)"') do set MESSAGE=%%i
git --git-dir=$(BUILDDIR)\..\.git\modules\build checkout %BUILDBRANCH%
git --git-dir=$(BUILDDIR)\..\.git\modules\build add .
git --git-dir=$(BUILDDIR)\..\.git\modules\build commit -m '%MESSAGE%'
# git --git-dir=$(BUILDDIR)\..\.git\modules\build push origin %BUILDBRANCH%

goto end

:help
%SPHINXBUILD% -M help %SOURCEDIR% %BUILDDIR% %SPHINXOPTS%

:end
popd
