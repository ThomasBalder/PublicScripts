ECHO Uninstall Symantec AV & install SCEP AV. 

IF EXIST "C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\SMC.exe" GOTO :SEPEXIST 
IF EXIST "C:\Program Files (x86)\Microsoft Security Client" GO :END

copy %LOGONSERVER%\NETLOGON\SCEP\SCEPInstall.exe C:\WINDOWS\TEMP\ /Y
"C:\WINDOWS\TEMP\SCEPInstall.exe" /s

:SEPEXIST 
MsiExec.exe /x {87C925D6-F6BF-4FBD-840B-53BAE2648B7B}  /qn

:END
EXIT


