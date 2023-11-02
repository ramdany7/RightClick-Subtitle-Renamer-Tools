@echo off
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
goto Input-Error


:Input-Context                    
set Dir=cd /d "%SelectedThing%"
set SetIMG=set "img=%SelectedThing%"
cls&echo. &echo. &echo.
if /i "%Context%"=="SRT.Rename"				set "SubtitleExtension=srt"&goto SUB-Rename
if /i "%Context%"=="ASS.Rename"				set "SubtitleExtension=ass"&goto SUB-Rename
if /i "%Context%"=="SUB.Rename"				set "SubtitleExtension=sub"&goto SUB-Rename
if /i "%Context%"=="XML.Rename"				set "SubtitleExtension=xml"&goto SUB-Rename
if /i "%Context%"=="ALL.Rename"				goto SUB-Universal-Rename
if /i "%Context%"=="FI.Deactivate" 			set "Setup=Deactivate" &goto Setup
goto Input-Error

:Input-Error                      
echo %TAB%%TAB%%r_% Invalid input.  %_%&echo.
if defined Context echo %ESC%%TAB%%TAB%%i_%%r_%%Context%%_%
if not defined Context echo %ESC%%TAB%%TAB%%i_%%r_%%Command%%_%
echo.&echo %TAB%%g_%The command, file path, or directory path is unavailable. 
goto options

:No-Vids
echo.&echo.&echo.
echo %TAB%%w_%No Video selected.
pause>nul&exit

:No-Subs
echo.&echo.&echo.
echo %TAB%%w_%No Subtitle selected.
pause>nul&exit

:No-VidSub
echo.&echo.&echo.
echo %TAB%%w_%No Video ^& Subtitle selected.
pause>nul&exit

:SUB-Universal-Rename
setlocal EnableDelayedExpansion
echo                     %i_%%w_% SUBTITLE AUTO RENAME %_%
echo               %g_%Rename subtitle to video file name.%_%
echo.&echo.&echo.
set MKV=0&set MPF=0&set SRT=0&set ASS=0&set XML=0&set SUB=0&set VIDS=0&set SUBS=0&set Vc=0&set Sc=0&set Fc=0
for %%L in (%xSelected%) do (
	set "file=%%~nxL"
	set "name=%%~nL"
	set "ext=%%~xL"
	set "SelectedThingPath=%%~dpL"
	if /i "%%~xL"==".MKV" set /a MKV+=1&call :Collect-Vids
	if /i "%%~xL"==".MP4" set /a MPF+=1&call :Collect-Vids
	if /i "%%~xL"==".SRT" set /a SRT+=1&call :Collect-Subs
	if /i "%%~xL"==".ASS" set /a ASS+=1&call :Collect-Subs
	if /i "%%~xL"==".XML" set /a XML+=1&call :Collect-Subs
	if /i "%%~xL"==".SUB" set /a SUB+=1&call :Collect-Subs
)
cd /d "%SelectedThingPath%"
set /a VIDS=%MKV%+%MPF%
set /a SUBS=%SRT%+%ASS%+%XML%+%SUB%
if %SUBS%==0 if %VIDS%==0 goto No-VidSub
if %VIDS%==0 goto No-Vids
if %SUBS%==0 goto No-Subs
set /a VS=%VIDS%+%SUBS%
if %VS%==2 (call :Method1) else call :Method2

setlocal DisableDelayedExpansion
echo.&echo     %i_%%r_%             Unexpected Error!             %_%
pause>nul&exit

:Collect-Vids
set /a Fc+=1
set "Ffile%Fc%=%file%"
set "Fname%Fc%=%name%"
set "Fext%Fc%=%ext%"

set /a Vc+=1
set "Vfile%Vc%=%file%"
set "Vname%Vc%=%name%"
set "Vext%Vc%=%ext%"
set "Vfilter="
for %%f in (%VidFilter%) do (
	if "!Vfilter!"=="" set "Vfilter=!name:%%f=!"
	set "Vfilter=!Vfilter:%%f=!"
)
set "Vfilter=%Vfilter:(=,%"
set "Vfilter=%Vfilter:-=,%"
set "Vfilter=%Vfilter:)=,%"
set "Vfilter=%Vfilter:.=,%"
set "Vfilter=%Vfilter:_=,%"
set "Vfilter=%Vfilter: =,%"
set "Vfilter=%Vfilter:,,,,,=,%"
set "Vfilter=%Vfilter:,,,,=,%"
set "Vfilter=%Vfilter:,,,=,%"
set "Vfilter=%Vfilter:,,=,%"
set "Vfilter%Vc%=%Vfilter%"
set "Ffilter%Fc%=%Vfilter%"
exit /b

:Collect-Subs
set /a Fc+=1
set "Ffile%Fc%=%file%"
set "Fname%Fc%=%name%"
set "Fext%Fc%=%ext%"

set /a Sc+=1
set "Sfile%Sc%=%file%"
set "Sname%Sc%=%name%"
set "Sext%Sc%=%ext%"
set "Sfilter="
for %%f in (%SubFilter%) do (
	if "!Sfilter!"=="" set "Sfilter=!name:%%f=!"
	set "Sfilter=!Sfilter:%%f=!"
)
set "Sfilter=%Sfilter:(=,%"
set "Sfilter=%Sfilter:-=,%"
set "Sfilter=%Sfilter:)=,%"
set "Sfilter=%Sfilter:.=,%"
set "Sfilter=%Sfilter:_=,%"
set "Sfilter=%Sfilter: =,%"
set "Sfilter=%Sfilter:,,,,,=,%"
set "Sfilter=%Sfilter:,,,,=,%"
set "Sfilter=%Sfilter:,,,=,%"
set "Sfilter=%Sfilter:,,=,%"
set "Sfilter%Sc%=%Sfilter%"
set "Ffilter%Fc%=%Sfilter%"
exit /b


:Method1
%STAGE1%
echo     %g_%Mode: %gn_%1 vs 1%_% 
echo.
if "%Sname1%"=="%Vname1%" (
	echo %ESC%┌%c_%🎞 %c_%%Vfile1%%ESC%
	echo %ESC%└%_%📄 %Sfile1%%ESC%
	echo.
	echo %TAB%%w_%Filename already match.
	pause>nul&exit
)
echo %ESC%┌%c_%🎞 %c_%%Vfile1%%ESC%
echo %ESC%└%_%📄 %Sfile1%%ESC%
set "RenBefore=%Sfile1%"
set "RenAfter=%Vname1%%Sext1%"
echo.&echo.&echo.&echo.

:Method1-Redo
call :Timer-start
%STAGE2%&echo.
echo %ESC%┌%c_%🎞 %c_%%Vfile1%%ESC%
echo %ESC%│%g_%📄 %RenBefore%%ESC%
echo %ESC%└%w_%📄 %w_%%RenAfter%%ESC%
ren "%RenBefore%" "%RenAfter%"
echo.&echo   %i_%    Done.   %_%
echo.&echo.&echo.&echo.&call :Timer-end
echo %TAB%%g_%The process took %ExecutionTime% ^| %g_%^[%gn_%U%g_%^] Undo.  %g_%^[%r_%X%g_%^] Close this window.%bk_%
CHOICE /N /C UX
if %errorlevel%==2 exit
echo.&echo.&echo.&echo.&call :Timer-start
echo %i_%%cc_%2/1%_% %cc_%%u_%Undo..                      %_%&echo.
echo %ESC%┌%c_%🎞 %c_%%Vfile1%%ESC%
echo %ESC%│%g_%📄 %RenAfter%%ESC%
echo %ESC%└%w_%📄 %w_%%RenBefore%%ESC%
ren "%RenAfter%" "%RenBefore%"
echo.&echo   %i_%    Done.   %_%
echo.&echo.&echo.&echo.&call :timer-end
echo.&echo.
echo.
echo %TAB%%g_%The process took %ExecutionTime% ^| %g_%^[%cc_%R%g_%^] Redo.  %g_%^[%r_%X%g_%^] Close this window.%bk_%
CHOICE /N /C RX
if %errorlevel%==2 exit
goto Method1-Redo

:Method2
%STAGE1%
call :Timer-start
echo.
%Separator%
echo.
for /L %%s in (1,1,%Sc%) do (
	set matched=0
	for /L %%v in (1,1,%Vc%) do (
		set "match=0"
		set "Mkey="
		for %%S in (!Sfilter%%s!) do (
			for %%V in (!Vfilter%%v!) do (
				set "Key=%%S"
				if /i "%%S"=="%%V" (
					set /a match+=1
					if /i "!Mkey!"=="" (set "Mkey=!Key!") else set "Mkey=!Mkey!, !Key!"
					if !match! gtr !matched! (
						set "MVid=%%v"
						set "MVfile=!Vfile%%v!"
						set "MVname=!Vname%%v!"
						set  "MVext=!Vext%%v!"
						
						set "MSid=%%s"
						set "MSfile=!Sfile%%s!"
						set "MSname=!Sname%%s!"
						set  "MSext=!Sext%%s!"
						
						set "Mk=!Mkey!"
						set "matched=!match!"
					)
				)
			)
		)
	)
	if not !matched! equ 0 (
		set /a Mc+=1
		set "MVfile!Mc!=!MVfile!"
		set "MVname!Mc!=!MVname!"
		set  "MVext!Mc!=!MVext!"
		
		set "MSfile!Mc!=!MSfile!"
		set "MSname!Mc!=!MSname!"
		set  "MSext!Mc!=!MSext!"
		
		set "Mk%Mc%=!Mk!"
		
		echo %ESC%┌%c_%🎞 %c_%!MVfile!%ESC%
		echo %ESC%│%g_%   !Mk!%ESC%
		echo %ESC%└%w_%📄 %w_%!MSfile!%ESC%
		echo.
	) else (
		echo %ESC%%g_%┌%c_%🗋 %g_%No file match.%ESC%
		echo %ESC%%g_%└%w_%📄 %w_%!Sfile%%s!%ESC%
		echo.
	)
)
call :Timer-end
echo.
echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%cc_%R%g_%^] to Rename. Press %g_%^[%r_%C%g_%^] to Cancel.%bk_%
CHOICE /N /C RC
if %errorlevel%==2 exit
:Method2-Redo
echo.&echo.&echo.&echo.
%STAGE2%
call :Timer-start
echo.
%Separator%
for /L %%m in (1,1,%Mc%) do (
	echo %ESC%┌%c_%🎞 %c_%!MVfile%%m!%ESC%
	echo %ESC%│%g_%   !MSfile%%m!%ESC%
	echo %ESC%└%w_%📄 %w_%!MVname%%m!!MSext%%m!%ESC%%r_%
	ren "!MSfile%%m!" "!MVname%%m!!MSext%%m!"
)
echo.&call :Timer-end
echo   %_%%i_%    Done.   %_%
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
for /L %%m in (1,1,%Mc%) do (
	echo %ESC%┌%c_%🎞 %c_%!MVfile%%m!%ESC%
	echo %ESC%│%g_%   !MVname%%m!!MSext%%m!%ESC%
	echo %ESC%└%w_%📄 %w_%!MSfile%%m!%ESC%%r_%
	ren "!MVname%%m!!MSext%%m!" "!MSfile%%m!"
)
echo.&call :Timer-end
echo   %_%%i_%    Done.   %_%
echo.
echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%cc_%R%g_%^] to Redo. Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
CHOICE /N /C RX
if %errorlevel%==2 exit
echo.&echo.&echo.
goto Method2-Redo
pause>nul&exit

:SUB-Rename
for %%D in (%xSelected%) do set "SelectedThingPath=%%~dpD"
cd /d "%SelectedThingPath%"
set ActTitle=SUBTITLE&if /i ".%SubtitleExtension%"==".XML" set ActTitle=CHAPTER
echo                     %i_%%w_% %ActTitle% AUTO RENAME %_%
echo               %g_%Rename subtitle to video file name.%_%
echo.&echo.&echo.
%STAGE1%
echo.&call :Timer-start
setlocal EnableDelayedExpansion
for %%L in (*) do (
	set "filename=%%~nxL"
	if /i "%%~xL"==".MKV" set /a MKVcount+=1&call :SUB-Rename-Collect.VID
	if /i "%%~xL"==".MP4" set /a MPcount+=1&call :SUB-Rename-Collect.VID
	if /i "%%~xL"==".%SubtitleExtension%" set /a SUBScount+=1&call :SUB-Rename-Collect.SUB
)
setlocal DisableDelayedExpansion
if %VIDcount% LSS 2 call :SUB-Rename-Method1
%Separator%
if %VIDcount% EQU %SUBcount% call :SUB-Rename-Method2
setlocal EnableDelayedExpansion
if not %VIDcount% EQU %SUBcount% call :SUB-Rename-Method3
setlocal DisableDelayedExpansion
echo.&echo     %i_%%r_%             Unexpected Error!             %_%
pause>nul&exit

:SUB-Rename-Collect.VID
if exist "%filename:~0,-4%.%SubtitleExtension%" (
	echo %ESC%%g_%┌%g_%🎞 %g_%%filename%%ESC%
	echo %ESC%%g_%└%g_%📄 %g_%%filename:~0,-4%.%SubtitleExtension% %gn_%✓%g_%%ESC%
	echo.
	set /a FILEcount+=1
	set /a MATCHEDcount+=1
	set "FILEname%FILEcount%=%filename%"
	exit /b
)
set "VIDfilter="
set /a VIDcount+=1
set /a FILEcount+=1
set "FILEname%FILEcount%=%filename%"
set "VIDfile%VIDcount%=%filename%"
for %%f in (Bluray,NF,WEB,DL,HD,BD,480p,720p,1080p,2160p,x265,x264,HEVC,10bit,6CH,Pahe.in,WebRip,WebDL,WebHD,DD+7,DD5.1,7.1CH,DD+5.1) do (
	if "!VIDfilter!"=="" set "VIDfilter=!filename:%%f=!"
	set "VIDfilter=!VIDfilter:%%f=!"
)
set "VIDfilter%VIDcount%=%VIDfilter%"
exit /b

:SUB-Rename-Collect.SUB
if exist "%filename:~0,-4%.mkv" exit /b
if exist "%filename:~0,-4%.mp4" exit /b
set /a SUBcount+=1
set /a FILEcount+=1
set "FILEname%FILEcount%=%filename%"
set "SUBfile%SUBcount%=%filename%"
rem setlocal EnableDelayedExpansion
rem for %%f in (Bluray,NF,WEB,DL,HD,BD,480p,720p,1080p,2160p,x265,x264,HEVC,10bit,6CH,Pahe.in,x,WebRip,WebDL,WebHD,DD+7,DD5.1,7.1CH,DD+5.1) do (
rem 	if "!SUBfilter!"=="" set "SUBfilter=!filename:%%f=!"
rem 	set "SUBfilter=!SUBfilter:%%f=!"
rem )
rem setlocal DisableDelayedExpansion
rem Set "SUBfilter%SUBcount%=%SUBfilter%"
exit /b

:SUB-Rename-Collect-Result
set /a VIDScount=%MPcount%+%MKVcount%
if %VIDScount%	GTR 0	set "resultVID=%c_%%VIDScount%%g_% Videos found."
if %MKVcount%		GTR 0	set "resultMKV=^(%MKVcount%^) MKV"
if %MKVcount%		EQU %VIDScount% set "resultMKV=All are MKV."
if %MPcount%		GTR 0	set "resultMP4=^(%MPcount%^) MP4"
if %MPcount%		EQU %VIDScount% set "resultMP4=All are MP4."
if %SUBScount%	GTR 0	set "resultSUB=%yy_%%SUBScount%%g_% Subtitle/*.%SubtitleExtension% found."
if %MATCHEDcount%	GTR 0	set "resultMATCHED=%g_%^(%gn_%%MATCHEDcount%%g_%^) Video already have *.%SubtitleExtension% subtitle."
if %VIDcount% GTR %MATCHEDcount% set "resultMATCHED=%gn_%^(All^) video already have *.%SubtitleExtension% subtitle."
echo   %resultVID% %resultMKV% %resultMP4% %resultMATCHED%
echo   %resultSUB% 
if %VIDcount%     EQU 0 if %MATCHEDcount% EQU 0 echo.&echo  %r_%No .mkv or .mp4 found in this directory.%_%
exit /b

:SUB-Rename-Method1
if %VIDcount% EQU 0 (
	call :SUB-Rename-Collect-Result
	pause>nul&exit
)
echo %ESC%┌%c_%🎞 %c_%%VIDfile1%%ESC%
echo %ESC%└%_%📄 %SUBfile1%%ESC%
set "RenBefore=%SUBfile1%"
set "RenAfter=%VIDfile1:~0,-4%.%SubtitleExtension%"
echo.&echo.&echo.&echo.

:SUB-Rename-Method1-Redo
%STAGE2%&echo.
echo %ESC%┌%c_%🎞 %c_%%VIDfile1%%ESC%
echo %ESC%│%g_%📄 %RenBefore%%ESC%
echo %ESC%└%w_%📄 %w_%%RenAfter%%ESC%
ren "%RenBefore%" "%RenAfter%"
echo.&echo   %i_%    Done.   %_%
echo.&echo.&echo.&echo.&call :timer-end
echo %TAB%%g_%The process took %ExecutionTime% ^| %g_%^[%gn_%U%g_%^] Undo.  %g_%^[%r_%X%g_%^] Close this window.%bk_%
CHOICE /N /C UX
if %errorlevel%==2 exit
echo.&echo.&echo.&echo.
echo %i_%%cc_%2/1%_% %cc_%%u_%Undo..                      %_%&echo.
echo %ESC%┌%c_%🎞 %c_%%VIDfile1%%ESC%
echo %ESC%│%g_%📄 %RenAfter%%ESC%
echo %ESC%└%w_%📄 %w_%%RenBefore%%ESC%
ren "%RenAfter%" "%RenBefore%"
echo.&echo   %i_%    Done.   %_%
echo.&echo.&echo.&echo.&call :timer-end
echo.&echo.
call :SUB-Rename-Collect-Result
echo.
echo %TAB%%g_%The process took %ExecutionTime% ^| %g_%^[%cc_%R%g_%^] Redo.  %g_%^[%r_%X%g_%^] Close this window.%bk_%
CHOICE /N /C RX
if %errorlevel%==2 exit
goto SUB-Rename-Method1-Redo

:SUB-Rename-Method2
for /L %%F in (1,1,%VIDcount%) do set "List=%%F"&if defined VIDfile%%F call :SUB-Rename-Method2-Display
echo.&call :Timer-end
echo.&echo.&call :SUB-Rename-Collect-Result
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

:SUB-Rename-Method3
for %%D in (%xSelected%) do (
	set /a SCount+=1
	set "SUBselected!SCount!=%%~nxD"
	set "SUBselected=%%~nxD"
	call :SUB-Rename-Method3-Delim
	call :SUB-Rename-Method3-Result
)

call :Timer-end
echo.&echo.
call :SUB-Rename-Collect-Result
echo.
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
call :SUB-Rename-Method3-Action
echo.&call :Timer-end
echo   %_%%i_%    Done.   %_%
echo.&echo.
call :SUB-Rename-Collect-Result
echo.
echo.&echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%gn_%U%g_%^] to Undo. Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
CHOICE /N /C UX
if %errorlevel%==2 exit
echo.&echo.&echo.
:SUB-Rename-Method3-Redo
echo %i_%%cc_%2/1%_% %cc_%%u_%Undo..                      %_%
echo.
%separator%
call :Timer-start
call :SUB-Rename-Method3-Undo
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
call :SUB-Rename-Method3-Action
echo.&call :Timer-end
echo   %_%%i_%    Done.   %_%
echo.&echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%gn_%U%g_%^] to Undo. Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
CHOICE /N /C UX
if %errorlevel%==2 exit
echo.&echo.&echo.
goto SUB-Rename-Method3-Redo
pause>nul&exit

:SUB-Rename-Method3-Delim
set "MatchCountLast="
set "SUBfilter="
for %%f in (Bluray,NF,WEB,DL,HD,BD,480p,720p,1080p,2160p,x265,x264,HEVC,10bit,6CH,Pahe.in,WebRip,Rip,WebDL,WebHD,DD+7,DD5.1,7.1CH,DD+5.1) do (
	if "!SUBfilter!"=="" set "SUBfilter=!SUBselected:%%f=!"
	set "SUBfilter=!SUBfilter:%%f=!"
)
set "SUBfilter%SCount%=%SUBfilter%"
call set "SUBfilter=%%SUBfilter%SCount%%%"
for /f "tokens=1-26 delims=(-)._ " %%A in ("!SUBfilter!") do (
	set "KeyA=%%A"
	set "KeyB=%%B"
	set "KeyC=%%C"
	set "KeyD=%%D"
	set "KeyE=%%E"
	set "KeyF=%%F"
	set "KeyG=%%G"
	set "KeyH=%%H"
	set "KeyI=%%I"
	set "KeyJ=%%J"
	set "KeyK=%%K"
	set "KeyL=%%L"
	set "KeyM=%%M"
	set "KeyN=%%N"
	set "KeyO=%%O"
	set "KeyP=%%P"
	set "KeyQ=%%Q"
	set "KeyR=%%R"
	set "KeyS=%%S"
	set "KeyT=%%T"
	set "KeyU=%%U"
	set "KeyV=%%V"
	set "KeyW=%%W"
	set "KeyX=%%X"
	set "KeyY=%%Y"
	set "KeyZ=%%Z"
)

for /L %%n in (1,1,%VIDcount%) do (
	set "num=%%n"
	set "MatchParts="
	set "MatchShow="
	set "MatchCount=0"
	if not defined MatchCountLast set MatchCountLast=0
	for %%D in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do (
		if defined Key%%D (
			set "part=%%D"
			call set "SUBkey=%%Key!part!%%"
			call set "VIDfilter=%%VIDfilter!num!%%"
			call set "VIDselected=%%VIDfile!num!%%"
			call :SUB-Rename-Method3-Compare
		)
	)
)
exit /b

:SUB-Rename-Method3-Compare
call set "VIDcompare=%%VIDfilter:%SUBkey%=%%"
if /i "%VIDfilter%"=="%VIDcompare%" exit /b
if not defined MatchParts (set MatchParts="%SUBkey%") else set MatchParts=%MatchParts%, "%SUBkey%"
if not defined MatchShow (call set "MatchShow=%%VIDselected:%SUBkey%=%g_%%SUBkey%%bk_%%%") else call set "MatchShow=%%MatchShow:%SUBkey%=%g_%%SUBkey%%bk_%%%"
set /a MatchCount+=1
if %MatchCount% GTR %MatchCountLast% (
	set "MatchShowKey=%MatchShow%"
	set "MatchCountlast=%MatchCount%"
	set "MatchVID=%VIDselected%"
	set "MatchSUB=%SUBselected%"
	set "MatchKey=%MatchParts%"
)
exit /b

:SUB-Rename-Method3-Result
if not defined MatchVID (
	echo %ESC%%g_%┌%g_%📄 %g_%%SUBselected%%ESC%
	echo %ESC%%r_%└%r_%🗋%g_%No file match!%ESC%
	exit /b
)
set "MatchVID%Scount%=%MatchVID%"
set "MatchKey%Scount%=%MatchKey%"
set "MatchSUB%Scount%=%MatchSUB%"
set "MatchCount%Scount%=%MatchCount%"
set "MatchShow%Scount%=%MatchShowKey%"
echo.
echo %ESC%┌%yy_%📄 %MatchSUB%%ESC%
echo %ESC%│%bk_%   %MatchShowKey%
echo %ESC%└%c_%🎞  %MatchVID%%ESC%
exit /b

:SUB-Rename-Method3-Action
if not defined Acount (set /a Acount+=1)
call set "SUBselected=%%SUBselected%Acount%%%"
if not defined MatchVID%Acount% (
	echo %ESC%%g_%┌%g_%📄 %g_%%SUBselected%%ESC%
	echo %ESC%%r_%└%r_%🗋%g_%No file match!%ESC%
	exit /b
)
call set "SUBselected=%%MatchSUB%Acount%%%"
call set "VIDselected=%%MatchVID%Acount%%%"
echo.
echo %ESC%┌%c_%🎞  %VIDselected%%ESC%
echo %ESC%│%g_%📄 %SUBselected%%ESC%
echo %ESC%└%w_%📄 %VIDselected:~0,-4%.%SubtitleExtension%%ESC%%r_%
ren "%SUBselected%" "%VIDselected:~0,-4%.%SubtitleExtension%"
if %Acount% EQU %Scount% set "Acount="&exit /b
set /a Acount+=1
goto SUB-Rename-Method3-Action

:SUB-Rename-Method3-Undo
if not defined Acount (set /a Acount+=1)
call set "SUBselected=%%SUBselected%Acount%%%"
if not defined MatchVID%Acount% (
	echo %ESC%%g_%┌%g_%📄 %g_%%SUBselected%%ESC%
	echo %ESC%%r_%└%r_%🗋%g_%No file match!%ESC%
	exit /b
)
call set "SUBselected=%%MatchSUB%Acount%%%"
call set "VIDselected=%%MatchVID%Acount%%%"
echo.
echo %ESC%┌%c_%🎞  %VIDselected%%ESC%
echo %ESC%│%g_%📄 %VIDselected:~0,-4%.%SubtitleExtension%%ESC%
echo %ESC%└%w_%📄 %SUBselected%%ESC%%r_%
ren "%VIDselected:~0,-4%.%SubtitleExtension%" "%SUBselected%"
if %Acount% EQU %Scount% set "Acount="&exit /b
set /a Acount+=1
goto SUB-Rename-Method3-Undo

:SUB-Rename-Method4
for %%D in (%xSelected%) do (
	set "SUBselected=%%~nxD"
	for /f "tokens=1-26 delims=(-)._ " %%A in ("%%~nD") do (
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
call :SUB-Rename-Collect-Result
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
call set "VIDcompare=%%VIDfilter%List%%%"
call set "VIDfile=%%VIDfile%List%%%"
set "CompareResult=%VIDfile%"
for %%D in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do set "compareMe=%%D"&call :SUB-Rename-Method4-compare
if %MatchCountNow% GTR %MatchCountLast% set "VIDselected=%VIDfile%"&set "SUBmatchResult=%CompareResult%"&set "MatchCountLast=%MatchCountNow%"
rem echo %ESC%%CompareResult%%ESC%
exit /b

:SUB-Rename-Method4-Compare
if not defined compare%compareMe% exit /b
call set "VIDcompareKey=%%Compare%CompareMe%%%"
call set "VIDcompareString=%%VIDcompare:%VIDcompareKey%=%%"
rem for %%x in (Bluray,WEB,DL,HD,BD,480p,720p,1080p,2160p,x265,x264,HEVC,10bit,6CH,DD5,1-Pahe,Pahe,x,WebRip,WebDL,WebHD,DD+7) do if /i "%VIDcompareKey%"=="%%x" exit /b
if /i not "%VIDcompare%"=="%VIDcompareString%" set /a MatchCountNow+=1 &call set "CompareResult=%VIDCompareKey%,%CompareResult%"
echo Match: "%CompareResult%"
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

:Config-Load                      
REM Load Config from config.ini
if not exist "%~dp0RCSR.config.ini" call :Config-GetDefault
if exist "%~dp0RCSR.config.ini" (
	for /f "usebackq tokens=1,2 delims==" %%C in ("%~dp0RCSR.config.ini") do (set "%%C=%%D")
) else (
	echo.&echo.&echo.&echo.
	echo       %w_%Couldn't load RCSR.config.ini.   %r_%Access is denied.
	echo       %w_%Try Run As Admin.%_%
	%P5%&%p5%&exit
)
set "SubFilter=%SubFilter:"=%"
set "SubFilter=%SubFilter:!=%"
set "SubFilter=%SubFilter:(=%"
set "SubFilter=%SubFilter:)=%"
set "SubFilter=%SubFilter:<=%"
set "SubFilter=%SubFilter:>=%"

set "VidFilter=%VidFilter:"=%"
set "VidFilter=%VidFilter:!=%"
set "VidFilter=%VidFilter:(=%"
set "VidFilter=%VidFilter:)=%"
set "VidFilter=%VidFilter:<=%"
set "VidFilter=%VidFilter:>=%"

set "BypassConfirmation=%BypassConfirmation:"=%"
EXIT /B

:Config-GetDefault                
cd /d "%~dp0"
(
	echo SubFilter="Bluray,NF,WEB,DL,HD,BD,480p,720p,1080p,2160p,x265,x264,HEVC,10bit,6CH,Pahe.in,WebRip,WebDL,WebHD,DD+7,DD5.1,7.1CH,DD+5.1"
	echo VidFilter="Bluray,NF,WEB,DL,HD,BD,480p,720p,1080p,2160p,x265,x264,HEVC,10bit,6CH,Pahe.in,WebRip,WebDL,WebHD,DD+7,DD5.1,7.1CH,DD+5.1"
	echo.
	echo BypassConfirmation="No"
)>"%~dp0RCSR.config.ini"
EXIT /B

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
set FILEcount=0
set MPcount=0
set MKVcount=0
set SUBcount=0
set SUBScount=0
set MATCHEDcount=0
set VIDcount=0
set VIDScount=0
call :Config-Load

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
	set RegExSUB=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.sub\shell
	set RegExXML=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.xml\shell
	set RegExALL=%HKEY%_CLASSES_ROOT\*\shell
	
rem Generating setup_*.reg
(
	echo Windows Registry Editor Version 5.00

	:REG-Context_Menu-SRT_Rename
	echo [%RegExSRT%\RCSR.SRT.Rename]
	echo "MUIVerb"="Rename Subtitle (.srt)"
	echo [%RegExSRT%\RCSR.SRT.Rename\command]
	echo @="%SCMD% set \"Context=SRT.Rename\"%SRCSRexe% \"%%1\""

	:REG-Context_Menu-ASS_Rename
	echo [%RegExASS%\RCSR.ASS.Rename]
	echo "MUIVerb"="Rename Subtitle (.ass)"
	echo [%RegExASS%\RCSR.ASS.Rename\command]
	echo @="%SCMD% set \"Context=ASS.Rename\"%SRCSRexe% \"%%1\""
	
	:REG-Context_Menu-SUB_Rename
	echo [%RegExSUB%\RCSR.SUB.Rename]
	echo "MUIVerb"="Rename Subtitle (.sub)"
	echo [%RegExSUB%\RCSR.SUB.Rename\command]
	echo @="%SCMD% set \"Context=SUB.Rename\"%SRCSRexe% \"%%1\""

	:REG-Context_Menu-XML_Rename
	echo [%RegExXML%\RCSR.XML.Rename]
	echo "MUIVerb"="Rename XML"
	echo [%RegExXML%\RCSR.XML.Rename\command]
	echo @="%SCMD% set \"Context=XML.Rename\"%SRCSRexe% \"%%1\""
	
	:REG-Context_Menu-ALL_Rename
	echo [%RegExALL%\RCSR.Universal.Rename]
	echo "MUIVerb"="Rename Subtitle"
	echo [%RegExALL%\RCSR.Universal.Rename\command]
	echo @="%SCMD% set \"Context=All.Rename\"%SRCSRexe% \"%%1\""
	
)>>"%Setup_Write%"
exit /b
