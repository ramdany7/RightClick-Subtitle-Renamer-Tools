@echo off
setlocal
cd /d "%~dp0"
chcp 65001 >nul
set name=RCSR Tools
set version=v0.0
title Right-Click Subtitle Renamer %version%


:Start                            
set "SelectedThing=%~f1"
set "SelectedThingPath=%~dp1"
call :Setup
if defined Context goto Input-Context

:Intro                            
if defined Command goto Options-Input
echo.
echo.
echo                     %i_%%w_% Right-Click Subtitle Renamer %Version% %_%
echo                %g_%Rename subtitle to video file name automatically.%_%
echo.
echo                %gn_%Activate%g_%/%gn_%Act%g_%    to activate right-click menu.
echo                %gn_%Deactivate%g_%/%gn_%Dct%g_%  to deactivate right-click menu. 
echo.
goto Options-Input

:Options                          
echo.&echo.&echo.&echo.
if defined timestart call :timer-end
set "timestart="
if defined Context (
	if %exitwait% GTR 99 (
		echo.&echo.
		echo %TAB%%g_%%processingtime% Press Any Key to Close this window.
		endlocal
		pause>nul&exit
	)
	echo %TAB%%g_%%processingtime% This window will close in %ExitWait% sec.
	endlocal
	ping localhost -n %ExitWait% >nul&exit
)

:Options-Input                    
echo %g_%--------------------------------------------------------------------------------------------------

:Input-Command                    
for %%F in ("%cd%") do set "FolderName=%%~nxF"
if not defined OpenFrom set "FolderName=%cd%"
set "Command=(none)"
set /p "Command=%_%%w_%%FolderName%%_%%gn_%>"
set "Command=%Command:"=%"
echo %-% &echo %-% &echo %-%
if /i "%Command%"=="Act"			set "Setup_Select=1" &goto Setup-Choice
if /i "%Command%"=="Dct"			set "Setup_Select=2" &goto Setup-Choice
if /i "%Command%"=="Activate"	set "Setup_Select=1" &goto Setup-Choice
if /i "%Command%"=="Deactivate"	set "Setup_Select=2" &goto Setup-Choice

if exist "%Command%" set "input=%command:"=%"&goto directInput
goto Input-Error


:Input-Context                    
set Dir=cd /d "%SelectedThing%"
set SetIMG=set "img=%SelectedThing%"
cls
echo. &echo. &echo.
if /i "%Context%"=="SRT.Rename"				set "SubtitleExtension=srt"&goto SUB-Rename
if /i "%Context%"=="ASS.Rename"				set "SubtitleExtension=ass"&goto SUB-Rename
if /i "%Context%"=="SUB.Rename"				set "SubtitleExtension=sub"&goto SUB-Rename
if /i "%Context%"=="XML.Rename"				set "SubtitleExtension=xml"&goto SUB-Rename
if /i "%Context%"=="FI.Deactivate" 			set "Setup=Deactivate" &goto Setup
goto Input-Error

:Input-Error                      
echo %TAB%%TAB%%r_% Invalid input.  %_%
echo.
if defined Context echo %ESC%%TAB%%TAB%%i_%%r_%%Context%%_%
if not defined Context echo %ESC%%TAB%%TAB%%i_%%r_%%Command%%_%
echo.
echo %TAB%%g_%The command, file path, or directory path is unavailable. 
goto options

:SUB-Rename
for %%D in (%xSelected%) do set "SelectedThingPath=%%~dpD"
cd /d "%SelectedThingPath%"
set ActTitle=SUBTITLE
if /i ".%SubtitleExtension%"==".XML" set ActTitle=CHAPTER

	echo                     %i_%%w_% %ActTitle% AUTO RENAME %_%
	echo               %g_%Rename subtitle to video file name.%_%
	echo.
	echo.
	echo.
%STAGE1%
echo.
call :Timer-start
set VIDcount=0
set FILEcount=0
for %%L in (*) do (
	set "filename=%%~nxL"
	if /i "%%~xL"==".MKV" call :SUB-Rename-Collect.VID
	if /i "%%~xL"==".MP4" call :SUB-Rename-Collect.VID
	if /i "%%~xL"==".%SubtitleExtension%" call :SUB-Rename-Collect.SUB
)

if %VIDcount% LSS 2 call :SUB-Rename-Method1

%Separator%

if %VIDcount% EQU %SUBcount% call :SUB-Rename-Method2
if not %VIDcount% EQU %SUBcount% call :SUB-Rename-Method4

echo.
call :Timer-end
echo  %g_%The process took %ExecutionTime%%_%
%separator%

echo  %i_%%gn_% %_% %g_%Press %cc_%^[A^]%g_% to Confirm. Press %r_%^[B^]%g_% to Cancel.%bk_%
CHOICE /N /C AB
if %errorlevel%==2 exit
echo.
echo.
echo.
%STAGE2%
echo.
%separator%&call :Timer-start
set DisplayCount=0
for /L %%F in (1,1,%VIDcount%) do (
	set List=%%F
	if defined VIDfile%%F call :SUB-Rename-Action
)
%separator%
echo.
echo   %i_%    Done.   %_%
goto Options


:SUB-Rename-Method1
if %VIDcount% EQU 0 echo.&echo.&echo    %g_%^(No files to be proceed.^)%_%&pause>nul&exit
echo %ESC%┌%c_%🎞 %c_%%VIDfile1%%ESC%
echo %ESC%└%_%📄 %SUBfile1%%ESC%
set "RenBefore=%SUBfile1%"
set "RenAfter=%VIDfile1:~0,-4%.%SubtitleExtension%"
echo.&echo.&echo.&echo.
:SUB-Rename-Method1-Redo
%STAGE2%
echo.
echo %ESC%┌%c_%🎞 %c_%%VIDfile1%%ESC%
echo %ESC%│%g_%📄 %RenBefore%%ESC%
echo %ESC%└%w_%📄 %w_%%RenAfter%%ESC%
ren "%RenBefore%" "%RenAfter%"
echo.
echo   %i_%    Done.   %_%
echo.&echo.&echo.&echo.
call :timer-end
echo %TAB%%g_%The process took %ExecutionTime% ^| %g_%^[%gn_%U%g_%^]%g_% Undo.  %g_%^[%r_%X%g_%^]%g_% Close this window.%bk_%
CHOICE /N /C UX
if %errorlevel%==2 exit
echo.&echo.&echo.&echo.
echo %i_%%cc_%2/1%_% %cc_%%u_%Undo..                      %_%
echo.
echo %ESC%┌%c_%🎞 %c_%%VIDfile1%%ESC%
echo %ESC%│%g_%📄 %RenAfter%%ESC%
echo %ESC%└%w_%📄 %w_%%RenBefore%%ESC%
ren "%RenAfter%" "%RenBefore%"
echo.
echo   %i_%    Done.   %_%
echo.&echo.&echo.&echo.
call :timer-end
echo %TAB%%g_%The process took %ExecutionTime% ^| %g_%^[%cc_%R%g_%^]%g_% Redo.  %g_%^[%r_%X%g_%^]%g_% Close this window.%bk_%
CHOICE /N /C RX
if %errorlevel%==2 exit
goto SUB-Rename-Method1-Redo

:SUB-Rename-Method2
for /L %%F in (1,1,%VIDcount%) do set "List=%%F"&if defined VIDfile%%F call :SUB-Rename-Method2-Display
echo.&call :Timer-end
echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%cc_%R%g_%^] to Rename. Press %g_%^[%r_%C%g_%^] to Cancel.%bk_%
CHOICE /N /C RC
if %errorlevel%==2 exit
echo.&echo.&echo.

:SUB-Rename-Method2-Redo
%STAGE2%
echo.
%separator%&call :Timer-start
set DisplayCount=0
for /L %%F in (1,1,%VIDcount%) do set "List=%%F"&if defined VIDfile%%F call :SUB-Rename-Method2-Action
echo.&call :Timer-end
echo   %i_%    Done.   %_%
echo.
echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%gn_%U%g_%^] to Undo. Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
CHOICE /N /C UX
if %errorlevel%==2 exit
echo.&echo.&echo.

echo %i_%%cc_%2/1%_% %cc_%%u_%Undo..                      %_%
echo.
%separator%&call :Timer-start
set DisplayCount=0
for /L %%F in (1,1,%VIDcount%) do set "List=%%F"&if defined VIDfile%%F call :SUB-Rename-Method2-Undo
echo.&call :Timer-end
echo   %i_%    Done.   %_%
echo.
echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%cc_%R%g_%^] to Redo. Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
CHOICE /N /C RX
if %errorlevel%==2 exit
echo.&echo.&echo.
goto SUB-Rename-Method2-Redo

:SUB-Rename-Method2-Display
set /a DisplayCount+=1
call set "VIDfile=%%VIDfile%List%%%"
call set "SUBfile=%%SUBfile%List%%%"

if defined SUBfile%List% (
	echo %ESC%┌%c_%🎞 %c_%%VIDfile%%ESC%
	echo %ESC%└%w_%📄 %_%%SUBfile%%ESC%
) else (
	echo %ESC% %c_%🎞 %c_%%VIDfile%%ESC%
	echo %ESC% %c_%   %g_%No subtitle file.%ESC%
)
if not %DisplayCount% EQU %VIDcount% echo.
exit /b

:SUB-Rename-Method2-Action
set /a DisplayCount+=1
call set "VIDfile=%%VIDfile%List%%%"
call set "SUBfile=%%SUBfile%List%%%"

if defined SUBfile%List% (
	echo %ESC%┌%c_%🎞 %c_%%VIDfile%%ESC%
	echo %ESC%│%g_%📄 %SUBfile%%ESC%
	echo %ESC%└%w_%📄 %w_%%VIDfile:~0,-4%.%SubtitleExtension%%ESC%
	ren "%SUBfile%" "%VIDfile:~0,-4%.%SubtitleExtension%"
) else (
	echo %ESC% %c_%🎞 %c_%%VIDfile%%ESC%
	echo %ESC% %c_%   %g_%No subtitle file.%ESC%
)
if not %DisplayCount% EQU %VIDcount% echo.
exit /b

:SUB-Rename-Method2-Undo
set /a DisplayCount+=1
call set "VIDfile=%%VIDfile%List%%%"
call set "SUBfile=%%SUBfile%List%%%"

if defined SUBfile%List% (
	echo %ESC%┌%c_%🎞 %c_%%VIDfile%%ESC%
	echo %ESC%│%g_%📄 %VIDfile:~0,-4%.%SubtitleExtension%%ESC%
	echo %ESC%└%w_%📄 %w_%%SUBfile%%ESC%
	ren "%VIDfile:~0,-4%.%SubtitleExtension%" "%SUBfile%"
) else (
	echo %ESC% %c_%🎞 %c_%%VIDfile%%ESC%
	echo %ESC% %c_%   %g_%No subtitle file.%ESC%
)
if not %DisplayCount% EQU %VIDcount% echo.
exit /b

:SUB-Rename-Method4
for %%D in (%xSelected%) do (
	set "SUBselected=%%~nxD"
	for /f "tokens=1-26 delims=(-). " %%A in ("%%~nD") do (
		set "CompareA=%%A"
		set "CompareB=%%B"
		set "CompareC=%%C"
		set "CompareD=%%D"
		set "CompareE=%%E"
		set "CompareF=%%F"
		set "CompareG=%%G"
		set "CompareH=%%H"
		set "CompareI=%%I"
		set "CompareJ=%%J"
		set "CompareK=%%K"
		set "CompareL=%%L"
		set "CompareM=%%M"
		set "CompareN=%%N"
		set "CompareO=%%O"
		set "CompareP=%%P"
		set "CompareQ=%%Q"
		set "CompareR=%%R"
		set "CompareS=%%S"
		set "CompareT=%%T"
		set "CompareU=%%U"
		set "CompareV=%%V"
		set "CompareW=%%W"
		set "CompareX=%%X"
		set "CompareY=%%Y"
		set "CompareZ=%%Z"
		set "MatchCountLast=0"
		for /L %%n in (1,1,%VIDcount%) do (
			set List=%%n
			set "MatchCountNow=0"
			call :SUB-Rename-Method4-Setup
		)
		call :SUB-Rename-Method4-Result
	)
)
echo.&call :Timer-end
echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%cc_%R%g_%^] to Rename. Press %g_%^[%r_%C%g_%^] to Cancel.%bk_%
CHOICE /N /C RC
if %errorlevel%==2 exit
echo.&echo.&echo.

%STAGE2%
echo.
%separator%
call :Timer-start
set "MatchList=0"
call :SUB-Rename-Method4-Action
echo.&call :Timer-end
echo   %_%%i_%    Done.   %_%
echo.&echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%gn_%U%g_%^] to Undo. Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
CHOICE /N /C UX
if %errorlevel%==2 exit
echo.&echo.&echo.
:SUB-Rename-Method4-Redo
echo %i_%%cc_%2/1%_% %cc_%%u_%Undo..                      %_%
echo.
%separator%
call :Timer-start
set "MatchList=0"
call :SUB-Rename-Method4-Undo
echo.&call :Timer-end
echo   %_%%i_%    Done.   %_%
echo.
echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%cc_%R%g_%^] to Redo. Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
CHOICE /N /C RX
if %errorlevel%==2 exit
echo.&echo.&echo.

%STAGE2%
echo.
%separator%
call :Timer-start
set "MatchList=0"
call :SUB-Rename-Method4-Action
echo.&call :Timer-end
echo   %_%%i_%    Done.   %_%
echo.&echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%gn_%U%g_%^] to Undo. Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
CHOICE /N /C UX
if %errorlevel%==2 exit
echo.&echo.&echo.
goto SUB-Rename-Method4-Redo

:SUB-Rename-Method4-Setup
call set "VIDcompare=%%VIDfile%List%%%"
set "CompareResult=%VIDcompare%"
for %%D in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do set "compareMe=%%D"&call :SUB-Rename-Method4-compare
if %MatchCountNow% GTR %MatchCountLast% set "VIDselected=%VIDcompare%"&set "SUBmatchResult=%CompareResult%"&set "MatchCountLast=%MatchCountNow%"
rem echo %ESC%%CompareResult%%ESC%
exit /b

:SUB-Rename-Method4-Compare
if not defined compare%compareMe% exit /b
call set "VIDcompareKey=%%Compare%CompareMe%%%"
call set "VIDcompareString=%%VIDcompare:%VIDcompareKey%=%%"
for %%x in (Bluray,WEB,DL,HD,480p,720p,1080p,2160p,x265,x264,HEVC,10bit,DD5,1-Pahe,Pahe) do if /i "%VIDcompareKey%"=="%%x" exit /b
if /i not "%VIDcompare%"=="%VIDcompareString%" set /a MatchCountNow+=1 &call set "CompareResult=%%CompareResult:%VIDcompareKey%=%g_%%VIDcompareKey%%bk_%%%"
exit /b

:SUB-Rename-Method4-Result
if not defined VIDselected (
	echo %ESC%%g_%┌%g_%📄 %g_%%SUBselected%%ESC%
	echo %ESC%%r_%└%r_%🗋%g_%No file match!%ESC%
	exit /b
)
set /a MatchCount+=1
call set "SUBmatch%MatchCount%=%SUBselected%"
call set "VIDmatch%MatchCount%=%VIDselected%"
call set "MatchResult%MatchCount%=%SUBmatchResult%"
echo.
echo %ESC%┌%yy_%📄 %SUBselected%%ESC%
echo %ESC%│%bk_%   %SUBmatchResult%%ESC%
echo %ESC%└%c_%🎞  %VIDselected%%ESC%
exit /b

:SUB-Rename-Method4-Action
set /a MatchList+=1
if not defined MatchResult%MatchList% exit /b
call set "SUBselected=%%SUBmatch%MatchList%%%"
call set "VIDselected=%%VIDmatch%MatchList%%%"
echo.
echo %ESC%┌%c_%🎞  %VIDselected%%ESC%
echo %ESC%│%g_%📄 %SUBselected%%ESC%
echo %ESC%└%w_%📄 %VIDselected:~0,-4%.%SubtitleExtension%%ESC%%r_%
ren "%SUBselected%" "%VIDselected:~0,-4%.%SubtitleExtension%"
goto SUB-Rename-Method4-Action
exit /b

:SUB-Rename-Method4-Undo
set /a MatchList+=1
if not defined MatchResult%MatchList% exit /b
call set "SUBselected=%%SUBmatch%MatchList%%%"
call set "VIDselected=%%VIDmatch%MatchList%%%"
echo.
echo %ESC%┌%c_%🎞  %VIDselected%%ESC%
echo %ESC%│%g_%📄 %VIDselected:~0,-4%.%SubtitleExtension%%ESC%
echo %ESC%└%w_%📄 %SUBselected%%ESC%%r_%
ren "%VIDselected:~0,-4%.%SubtitleExtension%" "%SUBselected%"
goto SUB-Rename-Method4-Undo
exit /b


:SUB-Rename-Collect.VID
if exist "%filename:~0,-4%.%SubtitleExtension%" (
	echo %ESC%%g_%┌%g_%🎞 %g_%%filename%%ESC%
	echo %ESC%%g_%└%g_%📄 %g_%%filename:~0,-4%.%SubtitleExtension% %gn_%✓%g_%%ESC%
	echo.
	set /a FILEcount+=1
	set "FILEname%FILEcount%=%filename%"
	exit /b
)
set /a VIDcount+=1
set /a FILEcount+=1
set "FILEname%FILEcount%=%filename%"
set "VIDfile%VIDcount%=%filename%"
exit /b

:SUB-Rename-Collect.SUB
if exist "%filename:~0,-4%.mkv" exit /b
if exist "%filename:~0,-4%.mp4" exit /b
set /a SUBcount+=1
set /a FILEcount+=1
set "FILEname%FILEcount%=%filename%"
set "SUBfile%SUBcount%=%filename%"
exit /b


:FileSize                         
if "%size_B%"=="" set size=0 KB&echo %r_%Error: Fail to get file size!%_% &exit /b
set /a size_KB=%size_B%/1024
set /a size_MB=%size_KB%00/1024
set /a size_GB=%size_MB%/1024
set size_MB=%size_MB:~0,-2%.%size_MB:~-2%
set size_GB=%size_GB:~0,-2%.%size_GB:~-2%
if %size_B% NEQ 1024 set size=%size_B% Bytes
if %size_B% GEQ 1024 set size=%size_KB% KB
if %size_B% GEQ 1024000 set size=%size_MB% MB
if %size_B% GEQ 1024000000 set size=%size_GB% GB
exit /b

:Timer-start
set timestart=%time%
exit /b

:Timer-end
set timeend=%time%
set options="tokens=1-4 delims=:.,"
for /f %options% %%a in ("%timestart%") do set start_h=%%a&set /a start_m=100%%b %% 100&set /a start_s=100%%c %% 100&set /a start_ms=100%%d %% 100
for /f %options% %%a in ("%timeend%") do set end_h=%%a&set /a end_m=100%%b %% 100&set /a end_s=100%%c %% 100&set /a end_ms=100%%d %% 100
 
set /a hours=%end_h%-%start_h%
set /a mins=%end_m%-%start_m%
set /a secs=%end_s%-%start_s%
set /a ms=%end_ms%-%start_ms%
if %ms% lss 0 set /a secs = %secs% - 1 & set /a ms = 100%ms%
if %secs% lss 0 set /a mins = %mins% - 1 & set /a secs = 60%secs%
if %mins% lss 0 set /a hours = %hours% - 1 & set /a mins = 60%mins%
if %hours% lss 0 set /a hours = 24%hours%
if 1%ms% lss 100 set ms=0%ms%
 
:: Mission accomplished
set /a totalsecs = %hours%*3600 + %mins%*60 + %secs%
if %mins% lss 1 set "show_mins="
if %mins% gtr 0 set "show_mins=%mins% minutes "
if %hours% lss 1 set "show_hours="
if %hours% gtr 0 set "show_hours=%hours% hours " 
set ExecutionTime=%show_hours%%show_mins%%secs%.%ms% seconds
set "processingtime=The process took %ExecutionTime% ^|"
exit /b

:Setup                            
rem Define color palette and some variables
set "g_=[90m"
set "gg_=[32m"
set "gn_=[92m"
set "u_=[4m"
set "w_=[97m"
set "r_=[31m"
set "rr_=[91m"
set "b_=[34m"
set "bb_=[94m"
set "bk_=[30m"
set "y_=[33m"
set "yy_=[93m"
set "c_=[36m"
set "cc_=[96m"
set "_=[0m"
set "-=[0m[30m-[0m"
set "i_=[7m"
set "p_=[35m"
set "pp_=[95m"
set "ntc_=%_%%i_%%w_% %_%%-%"
set "TAB=   "
set ESC=[30m"[0m
set "AST=%r_%*%_%"                         
set p1=ping localhost -n 1 ^>nul
set p2=ping localhost -n 2 ^>nul
set p3=ping localhost -n 3 ^>nul
set p4=ping localhost -n 4 ^>nul
set p5=ping localhost -n 5 ^>nul
set "RCSR=%~dp0"
set "RCSR=%RCSR:~0,-1%"
set "RCSRD=%RCSR%\uninstall.cmd"
set "timestart="
set "Separator=echo %_%-------------------------------------------------------------------------%_%"
set "STAGE1=echo %i_%%cc_%1/2%_%%cc_% %u_%Searching Matching files..  %_%"
set "STAGE2=echo %i_%%cc_%2/2%_%%cc_% %u_%Renaming files..            %_%"
set "ExitWait=100"

rem Geting setup..
if /i "%setup%" EQU "Deactivate" set "setup_select=2" &goto Setup-Choice
if exist "%RCSR%\resources\deactivating.RCSR" set "Setup=Deactivate" &set "setup_select=2" &goto Setup-Choice
if exist "%RCSRD%" (
	for /f "useback tokens=1,2 delims=:" %%S in ("%RCSRD%") do set /a "InstalledRelease=%%T" 2>nul
	call :Setup-Update
	exit /b
) else echo.&echo.&echo.&set "setup_select=1" &goto Setup-Choice
echo.&echo.&echo.
Goto Setup-Options

:Setup-Update
set /a "CurrentRelease=%version:v0.=%"
if %CurrentRelease% GTR %InstalledRelease% echo Need to update!
exit /b

:Setup-Options                    
echo.&echo.
echo               %i_%     %name% %version%     %_%
echo.
echo            %g_%Activate or Deactivate Subtitle Renamer Tools on Explorer Right Click menus
echo            %g_%Press %gn_%1%g_% to %w_%Activate%g_%, Press %gn_%2%g_% to %w_%Deactivate%g_%, Press %gn_%3%g_% to %w_%Exit%g_%.%bk_%
echo.&echo.
choice /C:123 /N
set "setup_select=%errorlevel%"

:Setup-Choice                     
if "%setup_select%"=="1" (
	echo %g_%Activating RCSR Tools%_%
	set "Setup_action=install"
	set "HKEY=HKEY"
	goto Setup_process
)
if "%setup_select%"=="2" (
	echo %g_%Deactivating RCSR Tools%_%
	set "Setup_action=uninstall"
	set "HKEY=-HKEY"
	goto Setup_process
)
if "%setup_select%"=="3" goto options
goto Setup-Options

:Setup_process                   
set "Setup_Write=%~dp0Setup_%Setup_action%.reg"
call :Setup_Writing
if not exist "%~dp0Setup_%Setup_action%.reg" goto Setup_error
echo %g_%Updating shell extension menu ..%_%
regedit.exe /s "%~dp0Setup_%Setup_action%.reg" ||goto Setup_error
del "%~dp0Setup_%Setup_action%.reg"

REM installing -> create "uninstall.bat"
if /i "%setup_select%"=="1" (
	echo cd /d "%%~dp0">"%RCSRD%"
	echo set "Setup=Deactivate" ^&call "%name%" ^|^|pause^>nul :%version:v0.=%>>"%RCSRD%"
	echo %w_%%name% %version%  %cc_%Activated%_%
	echo %g_%Subtitle Renamer Tools has been added to the right-click menus. %_%
	echo %g_%"Rename Subtitle" added to .srt, .ass, .sub and .xml file context menu.
	echo.&echo.&echo.&echo.
	if not defined input (goto intro)
)

REM uninstalling -> delete "uninstall.bat"
if /i "%setup_select%"=="2" (
	del "%RCSR%\resources\deactivating.RCSR" 2>nul
	if exist "%RCSRD%" del "%RCSRD%"
	echo %w_%%name% %version%  %r_%Deactivated%_%
	echo %g_%Subtitle Renamer Tools have been removed from the right-click menus.%_%
if /i "%Setup%"=="Deactivate" set "Setup=Deactivated"
)
if /i "%Setup%"=="Deactivated" %p5%&%p3%&exit
goto options

:Setup_error                      
cls
echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
echo            %r_%Setup fail.
echo            %w_%Permission denied.
set "setup="
set "context="
del "%RCSR%\Setup_%Setup_action%.reg" 2>nul
del "%RCSR%\resources\deactivating.RCSR" 2>nul
pause>nul&exit


:Setup_Writing                    
echo %g_%Preparing registry entry ..%_%

rem Escaping the slash using slash
	set "curdir=%~dp0_."
	set "curdir=%curdir:\_.=%"
	set "curdir=%curdir:\=\\%"

rem Multi Select, Separate instance
	set cmd=cmd.exe /c
	set "RCSRTools=%~f0"
	set RCSRexe=^&call \"%RCSRTools:\=\\%\"
	set SCMD=\"%curdir%\\resources\\SingleInstanceAccumulator.exe\" \"-c:cmd /c
	set SRCSRexe=^^^&set xSelected=$files^^^&call \"\"%RCSRTools:\=\\%\"\"\"


rem Define registry root
	set RegExShell=%HKEY%_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell
	set RegExSRT=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.srt\shell
	set RegExASS=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.ass\shell
	set RegExXML=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.xml\shell



rem Generating setup_*.reg
(
	echo Windows Registry Editor Version 5.00

	:REG-Context_Menu-SRT_Rename
	echo [%RegExSRT%\RCSR.SRT.Rename]
	echo "MUIVerb"="Rename Subtitle"
	echo [%RegExSRT%\RCSR.SRT.Rename\command]
	echo @="%SCMD% set \"Context=SRT.Rename\"%SRCSRexe% \"%%1\""

	:REG-Context_Menu-ASS_Rename
	echo [%RegExASS%\RCSR.ASS.Rename]
	echo "MUIVerb"="Rename Subtitle"
	echo [%RegExASS%\RCSR.ASS.Rename\command]
	echo @="%SCMD% set \"Context=ASS.Rename\"%SRCSRexe% \"%%1\""
	
	:REG-Context_Menu-SUB_Rename
	echo [%RegExASS%\RCSR.SUB.Rename]
	echo "MUIVerb"="Rename Subtitle"
	echo [%RegExASS%\RCSR.SUB.Rename\command]
	echo @="%SCMD% set \"Context=SUB.Rename\"%SRCSRexe% \"%%1\""

	:REG-Context_Menu-XML_Rename
	echo [%RegExXML%\RCSR.XML.Rename]
	echo "MUIVerb"="Rename XML"
	echo [%RegExXML%\RCSR.XML.Rename\command]
	echo @="%SCMD% set \"Context=XML.Rename\"%SRCSRexe% \"%%1\""
	
)>>"%Setup_Write%"
exit /b
