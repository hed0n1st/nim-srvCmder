@echo off
%NIMPATH%\dist\mingw32\bin\windres -O coff srvCmder.rc -o srvCmder32.res
%NIMPATH%\dist\mingw64\bin\windres -O coff srvCmder.rc -o srvCmder64.res
