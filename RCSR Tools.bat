@echo off
cd /d "%~dp0"
chcp 65001 >nul
set name=RCSR Tools
set version=v0.0
title Right-Click Subtitle Renamer %version%


:Start                            
call :Setup
if defined Context goto Input-Context

:Intro                            
if defined Command goto Options-Input
echo.
echo.
echo                     %h1_% Right-Click Subtitle Renamer %Version% %_%
echo                %g_%Rename subtitles to video file name automatically.%_%
echo.
echo                %gn_%Activate%g_%/%gn_%Act%g_%    to activate right-click menu.
echo                %gn_%Deactivate%g_%/%gn_%Dct%g_%  to deactivate right-click menu. 
echo.
goto Options-Input

:Input-Context                    
set Dir=cd /d "%SelectedThing%"
set SetIMG=set "img=%SelectedThing%"
cls&echo.
if /i "%Context%"=="SRT.Rename"				set "SubtitleExtension=srt"&goto SUB-Universal-Rename
if /i "%Context%"=="ASS.Rename"				set "SubtitleExtension=ass"&goto SUB-Universal-Rename
if /i "%Context%"=="SSA.Rename"				set "SubtitleExtension=ssa"&goto SUB-Universal-Rename
if /i "%Context%"=="IDX.Rename"				set "SubtitleExtension=idx"&goto SUB-Universal-Rename
if /i "%Context%"=="SUB.Rename"				set "SubtitleExtension=sub"&goto SUB-Universal-Rename
if /i "%Context%"=="XML.Rename"				set "SubtitleExtension=xml"&goto SUB-Universal-Rename
if /i "%Context%"=="ALL.Rename"				goto SUB-Universal-Rename
if /i "%Context%"=="FI.Deactivate" 			set "Setup=Deactivate" &goto Setup
goto Input-Error

:Input-Error                      
echo %TAB%%TAB%%r_% Invalid input.  %_%&echo.
if defined Context echo %ESC%%TAB%%TAB%%i_%%r_%%Context%%_%
if not defined Context echo %ESC%%TAB%%TAB%%i_%%r_%%Command%%_%
echo.&echo %TAB%%g_%The command, file path, or directory path is unavailable. 
goto options

:SUB-Universal-Rename
setlocal EnableDelayedExpansion
call :Timer-start
echo                      %h1_% SUBTITLE AUTO RENAME %_%
echo               %g_%Rename subtitles to video file name.%_%
echo.&echo.&echo.
set MKV=0&set MPF=0
set SRT=0&set ASS=0&set XML=0&set SUB=0&set SSA=0&set IDX=0&set Sc=0
set VIDS=0&set SUBS=0&set Vc=0
set Fc=0
if defined SubtitleExtension goto SUB-Extension-Rename
call :Collect-SelectedFiles
if %SUBS%==0 if %VIDS%==0 goto No-VidSub
if %VIDS%==0 goto No-Vids
if %SUBS%==0 goto No-Subs
set /a VS=%VIDS%+%SUBS%
if %VS%==2 call :Method1
call :Method2
setlocal DisableDelayedExpansion
echo.&echo     %i_%%r_%             Unexpected Error!             %_%
pause>nul&exit

:SUB-Extension-Rename
set xSUBS=0
for %%L in (%xSelected%) do (
	set "SelectedThingPath=%%~dpL"
	for %%S in (srt,ass,ssa,xml,sub,idx) do if /i "%%~xL"==".%%S" set /a xSUBS+=1
)
cd /d "%SelectedThingPath%"

if "%xSUBS%"=="1" (
	rem echo       %i_%%w_% Gathering files.. %_%
	for %%F in (*) do (
		for %%V in (mkv,mp4) do if /i "%%~xF"==".%%V" set /a VIDS+=1
		for %%S in (srt,ass,ssa,xml,sub,idx) do if /i "%%~xF"==".%%S" set /a SUBS+=1
	)
) else (
	call :Collect-SelectedFiles
	call :Collect-VidInDir
	call :Method2
)
if %VIDS%==0 goto No-VidsInDir

if %VIDS%==1 (
	call :Collect-SelectedFiles
	call :Collect-VidInDir
	call :Method1
)

set /a VS=%VIDS%+%SUBS%

if %VS%==2 (
	call :Collect-DirFiles
	call :Method1
)

if %VIDS%==%SUBS% (
	set SUBS=0&set VIDS=0
	call :Collect-DirFiles
	call :Method3
) else (
	call :Collect-SelectedFiles
	call :Collect-VidInDir
	call :Method2
)

setlocal DisableDelayedExpansion
echo.&echo     %i_%%r_%             Unexpected Error!             %_%
pause>nul&exit


:Collect-SelectedFiles
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
	if /i "%%~xL"==".SSA" set /a SSA+=1&call :Collect-Subs
	if /i "%%~xL"==".IDX" set /a IDX+=1&call :Collect-Subs
)
cd /d "%SelectedThingPath%"
set /a VIDS=%MKV%+%MPF%
set /a SUBS=%SRT%+%ASS%+%XML%+%SUB%+%SSA%+%IDX%
exit /b

:Collect-DirFiles
for %%L in (*) do (
	set "file=%%~nxL"
	set "name=%%~nL"
	set "ext=%%~xL"
	set "SelectedThingPath=%%~dpL"
	if /i "%%~xL"==".MKV" set /a MKV+=1&call :Collect-Vids
	if /i "%%~xL"==".MP4" set /a MPF+=1&call :Collect-Vids
	if /i "%%~xL"==".%SubtitleExtension%" set /a SUBS+=1&call :Collect-Subs
)
set /a VIDS=%MKV%+%MPF%
exit /b

:Collect-VidInDir
for %%F in (*) do (
	set "file=%%~nxF"
	set "name=%%~nF"
	set "ext=%%~xF"
	for %%V in (mkv,mp4) do if /i "%%~xF"==".%%V" set /a VIDS+=1&call :Collect-Vids
)
exit /b

:Collect-Vids
if defined ExcludeMatched if defined SubtitleExtension if exist "%name%.%SubtitleExtension%" (
	echo %ESC%%g_%┌%g_%🎞 %g_%%file%%ESC%
	echo %ESC%%g_%└%g_%📄 %g_%%name:~0,-4%.%SubtitleExtension% %gn_%✓%g_%%ESC%
	echo.
	exit /b
)
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
set "Vfilter=%Vfilter:]=,%"
set "Vfilter=%Vfilter:[=,%"
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
if defined ExcludeMatched if defined SubtitleExtension for %%v in (mkv,mp4) do (
	if exist "%name%.%%v" (
		echo %ESC%%g_%┌%g_%🎞 %g_%%name%.%%v%ESC%
		echo %ESC%%g_%└%g_%📄 %g_%%file% %gn_%✓%g_%%ESC%
		echo.
		exit /b
	)
)
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
set "Sfilter=%Sfilter:]=,%"
set "Sfilter=%Sfilter:[=,%"
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
echo.
if defined SubtitleExtension (
	echo %g_% There is only one video in this directory, 
	echo %g_% subtitle will be renamed to video file name. %_%
) else (
	echo %g_% One video and one subtitle selected, 
	echo %g_% subtitle will be renamed to video file name. %_%
)
echo.&echo.&echo.

:Method1-Redo
call :Timer-start
%STAGE2%&echo.
if exist "%RenAfter%" (
	echo %ESC%┌%c_%🎞 %c_%%Vfile1%%ESC%
	echo %ESC%│%r_%   %RenBefore%%ESC%
	echo %ESC%│%g_%   Video already have subtitle associated.%ESC%
	echo %ESC%└%w_%📄 %_%%RenAfter%%gn_%✓%g_%%ESC%%r_%
	echo.
	echo %TAB%%g_%Press ^[%cc_%R%g_%^] to Replace.  %g_%Press ^[%r_%X%g_%^] to Close this window.%bk_%
	CHOICE /N /C RX
)
if !errorlevel!==1 for %%R in ("%RenAfter%") do (set "Rname=%%~nR"&set "Rext=%%~xR")&call :Method1-Replace
if !errorlevel!==2 exit

echo %ESC%┌%c_%🎞 %c_%%Vfile1%%ESC%
echo %ESC%│%g_%   %RenBefore%%ESC%
echo %ESC%└%w_%📄 %w_%%RenAfter%%ESC%%r_%
ren "%RenBefore%" "%RenAfter%"
echo.&echo   %_%%i_%    Done.   %_%
echo.&echo.&echo.&echo.&call :Timer-end
echo %TAB%%g_%The process took %ExecutionTime% ^| %g_%^[%gn_%U%g_%^] Undo.  %g_%^[%r_%X%g_%^] Close this window.%bk_%
CHOICE /N /C UX
if !errorlevel!==2 exit
echo.&echo.&echo.&echo.&call :Timer-start
%STAGE3%&echo.
echo %ESC%┌%c_%🎞 %c_%%Vfile1%%ESC%
echo %ESC%│%g_%   %RenAfter%%ESC%
echo %ESC%└%w_%📄 %w_%%RenBefore%%ESC%%r_%
ren "%RenAfter%" "%RenBefore%"
echo.&echo   %_%%i_%    Done.   %_%
echo.&echo.&echo.&echo.&call :timer-end
echo %TAB%%g_%The process took %ExecutionTime% ^| %g_%^[%cc_%R%g_%^] Redo.  %g_%^[%r_%X%g_%^] Close this window.%bk_%
CHOICE /N /C RX
if !errorlevel!==2 exit
goto Method1-Redo

:Method1-Replace
set /a R+=1
if exist "%Rname%_%R%%Rext%" goto Method1-Replace
ren "%Rname%%Rext%" "%Rname%_%R%%Rext%"
echo %ESC% %g_%📄 %g_%%RenAfter%%g_%✓%ESC%%r_%
echo %ESC% %_%📄 %_%%Rname%%gn_%_%R%%_%%Rext%%g_%%ESC%%r_%
echo.&echo.
goto Method1-Redo

:Method2
%STAGE1%
echo.
%Separator%
echo.
if %SUBS%==1 if %Sc%==0 cls&echo.&echo.&echo.&echo.&echo %TAB%Subtitles already pairs with videos.
if %Vc%==0 echo %TAB%All videos already pairs with subtitles.

if not %Vc%==0 for /L %%s in (1,1,%Sc%) do (
	set matched=0
	for /L %%v in (1,1,%Vc%) do (
		set "match=0"
		set "SMkey="
		for %%S in (!Sfilter%%s!) do (
			for %%V in (!Vfilter%%v!) do (
				if /i "%%S"=="%%V" (
					set /a match+=1
					if /i "!SMkey!"=="" (set "SMkey=%%S"&set "VMkey=%%V") else set "SMkey=!SMkey!, %%S"&set "VMkey=!VMkey!, %%V"
					if !match! gtr !matched! (
						set "MVid=%%v"
						set "MVfile=!Vfile%%v!"
						set "MVname=!Vname%%v!"
						set  "MVext=!Vext%%v!"
						
						set "MSid=%%s"
						set "MSfile=!Sfile%%s!"
						set "MSname=!Sname%%s!"
						set  "MSext=!Sext%%s!"
						
						set "SMk=!SMkey!"
						set "VMk=!VMkey!"
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
		
		set "MVNfilter="
		for %%N in (%VidFilter%) do (
			set "string=%%N"
			if /i not "!MVname:%%N=!"=="!MVname!" (
				call :StrLen String Lenght
				set "Space="
				for /L %%s in (1,1,!Lenght!) do (set Space=-!Space!)
				for %%L in (!Space!) do (
					if "!MVNfilter!"=="" set "MVNfilter=!MVname:%%N=%%L!"
					set "MVNfilter=!MVNfilter:%%N=%%L!"
				)
			)
		)
		if "!MVNfilter!"=="" set "MVNfilter=!MVname!"
		
		set "SMkD="
		for %%M in (!SMk!) do (
			if "!SMkD!"=="" set SMkD=!MVNfilter:%%M=%g_%%%M%bk_%!
			set SMkD=!SMkD:%%M=%g_%%%M%bk_%!
		)

		rem set "SMkDh="
		rem for %%M in (!SMk!) do (
		rem 	if "!SMkDh!"=="" set SMkDh=!MSname:%%M=%w_%%%M%w_%!
		rem 	set SMkDh=!SMkDh:%%M=%w_%%%M%w_%!
		rem )
		
		rem set "VMkD="
		rem for %%M in (!SMk!) do (
		rem 	if "!VMkD!"=="" set VMkD=!MVname:%%M=%g_%%%M%bk_%!
		rem 	set VMkD=!VMkD:%%M=%g_%%%M%bk_%!
		rem )
		rem echo Vfilter : "!Vfilter!
		rem echo SMk     :
		rem echo VMk     :
		rem echo Sfilter :
		rem echo.
		echo %ESC%┌%c_%🎞 %c_%!MVfile!%ESC%
		echo %ESC%│%g_%🔗 %bk_%!SMkD!%ESC%
		rem echo %ESC%│%g_%🔗 %bk_%!SMkD!%ESC%
		echo %ESC%└%w_%📄 %w_%!MSname!!MSext!%ESC%
		echo.
	) else (
		echo %ESC%%g_%┌%c_%🗋 %g_%%ESC%
		echo %ESC%%g_%│%r_%🔗 %g_%No file match.%ESC%
		echo %ESC%%g_%└%w_%📄 %_%!Sfile%%s!%ESC%
		echo.
	)
)
call :Timer-end
echo  %g_%The process took %ExecutionTime% ^| Analyzed: ^(%SUBS%^) Subtitles  ^(%VIDS%^) Videos %_%
%separator%
if !matched! equ 0 echo  %g_%Press any key to close this window.&pause>nul&exit
if /i not "%BypassConfirmation%"=="yes" (
	echo  %i_%%gn_% %_% %g_%Press %g__%^[%cc_%R%g_%^] to Rename. Press %g_%^[%r_%C%g_%^] to Cancel.%bk_%
	CHOICE /N /C RC
	if !errorlevel!==2 exit
)
:Method2-Redo
echo.&echo.&echo.&echo.
%STAGE2%
call :Timer-start
echo.
%Separator%
echo.
for /L %%m in (1,1,%Mc%) do (
	echo %ESC%┌%c_%🎞 %c_%!MVfile%%m!%ESC%
	echo %ESC%│%g_%   !MSfile%%m!%ESC%
	echo %ESC%└%w_%📄 %w_%!MVname%%m!!MSext%%m!%ESC%%r_%
	echo.
	ren "!MSfile%%m!" "!MVname%%m!!MSext%%m!"
)
echo.&call :Timer-end
echo   %_%%i_%    Done.   %_%&echo.
echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%gn_%U%g_%^] to Undo. Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
CHOICE /N /C UX
if !errorlevel!==2 exit
echo.&echo.&echo.&echo.

%STAGE3%
echo.
%separator%&call :Timer-start
echo.
for /L %%m in (1,1,%Mc%) do (
	echo %ESC%┌%c_%🎞 %c_%!MVfile%%m!%ESC%
	echo %ESC%│%g_%   !MVname%%m!!MSext%%m!%ESC%
	echo %ESC%└%w_%📄 %w_%!MSfile%%m!%ESC%%r_%
	echo.
	ren "!MVname%%m!!MSext%%m!" "!MSfile%%m!"
)
echo.&call :Timer-end
echo   %_%%i_%    Done.   %_%&echo.
echo  %g_%The process took %ExecutionTime%%_%
%separator%
echo  %i_%%gn_% %_% %g_%Press %g__%^[%cc_%R%g_%^] to Redo. Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
CHOICE /N /C RX
if !errorlevel!==2 exit
echo.&echo.&echo.&echo.
goto Method2-Redo
pause>nul&exit

:Method3
%STAGE1%
echo.
echo    %g_%Would you rename it according file order^?
echo    %g_%otherwise press M to analyze by file name.
echo.
%Separator%
echo.
for /L %%s in (1,1,%Sc%) do (
	echo %ESC%┌%c_%🎞 %c_%!Vfile%%s!%ESC%
	rem echo %ESC%│%g_%%ESC%
	echo %ESC%└%w_%📄 %w_%!Sfile%%s!%ESC%
	echo.
)
call :Timer-end
echo  %g_%The process took %ExecutionTime% ^| ^(%SUBS%^) Subtitle ^(%VIDS%^) Video %_%
%separator%
if /i not "%BypassConfirmation%"=="yes" (
	echo  %i_%%gn_% %_% %g_%Press %g__%^[%cc_%R%g_%^] to Rename. Press %g_%^[%cc_%M%g_%^] to Change method. %g_%Press %g_%^[%r_%C%g_%^] to Cancel.%bk_%
	CHOICE /N /C RMC
)
if !errorlevel!==2 echo.&echo.&echo.&echo.&call :Method2
if !errorlevel!==3 exit

:Method3-Redo
echo.&echo.&echo.&echo.
%STAGE2%
call :Timer-start
echo.
%Separator%
echo.
for /L %%s in (1,1,%Sc%) do (
	echo %ESC%┌%c_%🎞 %c_%!Vfile%%s!%ESC%
	echo %ESC%│%g_%   !Sfile%%s!%ESC%
	echo %ESC%└%w_%📄 %w_%!Vname%%s!!Sext%%s!%ESC%
	ren "!Sfile%%s!" "!Vname%%s!!Sext%%s!"
	echo.
)
call :Timer-end
echo  %g_%The process took %ExecutionTime%%_%
%separator%
if /i not "%BypassConfirmation%"=="yes" (
	echo  %i_%%gn_% %_% %g_%Press %g__%^[%gg_%U%g_%^] to Undo. %g_%Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
	CHOICE /N /C UX
	if !errorlevel!==2 exit
)
echo.&echo.&echo.&echo.
%STAGE3%
call :Timer-start
echo.
%Separator%
echo.
for /L %%s in (1,1,%Sc%) do (
	echo %ESC%┌%c_%🎞 %c_%!Vfile%%s!%ESC%
	echo %ESC%│%g_%   !Vname%%s!!Sext%%s!%ESC%
	echo %ESC%└%w_%📄 %w_%!Sfile%%s!%ESC%
	ren "!Vname%%s!!Sext%%s!" "!Sfile%%s!"
	echo.
)
call :Timer-end
echo  %g_%The process took %ExecutionTime%%_%
%separator%
if /i not "%BypassConfirmation%"=="yes" (
	echo  %i_%%gn_% %_% %g_%Press %g__%^[%cc_%R%g_%^] to Redo. %g_%Press %g_%^[%r_%X%g_%^] to Close this window.%bk_%
	CHOICE /N /C RX
	if !errorlevel!==2 exit
)
goto Method3-Redo
pause>nul&exit

:No-Vids
echo.&echo.&echo.
echo %TAB%%w_%No Video selected.
pause>nul&exit

:No-VidsInDir
echo.&echo.&echo.
echo %TAB%%w_%No Video found in this directory.
echo %TAB%%g_%%cd%
pause>nul&exit

:No-Subs
echo.&echo.&echo.
echo %TAB%%w_%No Subtitle selected.
pause>nul&exit

:No-VidSub
echo.&echo.&echo.
echo %TAB%%w_%No Video ^& Subtitle selected.
pause>nul&exit

:StrLen  StrVar  [RtnVar]
  setlocal EnableDelayedExpansion
  set "s=#!%~1!"
  set "len=0"
  for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
    if "!s:~%%N,1!" neq "" (
      set /a "len+=%%N"
      set "s=!s:~%%N!"
    )
  )
  endlocal&if "%~2" neq "" (set %~2=%len%) else echo %len%
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

:Setup                            
rem Define color palette and some variables
set "h1_=[42m[30m"
set "h2_=[106m[30m"
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
set "STAGE1=echo %i_%%cc_%1/2%_% %h2_% Searching Matching Files..  %_%"
set "STAGE2=echo %i_%%cc_%2/2%_% %h2_% Renaming Files..            %_%"
set "STAGE3=echo %i_%%cc_%2/1%_% %h2_% Reverting File Names..      %_%"
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
set "setup_select=!errorlevel!"

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
	echo %g_%"Rename Subtitle" added to .srt, .ass, .ssa, .sub, .idx, .xml context menu.
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
	set RegExSSA=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.ssa\shell
	set RegExIDX=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.idx\shell
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
	
	:REG-Context_Menu-SSA_Rename
	echo [%RegExSSA%\RCSR.SSA.Rename]
	echo "MUIVerb"="Rename Subtitle (.ssa)"
	echo [%RegExSSA%\RCSR.SSA.Rename\command]
	echo @="%SCMD% set \"Context=SSA.Rename\"%SRCSRexe% \"%%1\""
	
	:REG-Context_Menu-IDX_Rename
	echo [%RegExIDX%\RCSR.IDX.Rename]
	echo "MUIVerb"="Rename Subtitle (.idx)"
	echo [%RegExIDX%\RCSR.IDX.Rename\command]
	echo @="%SCMD% set \"Context=IDX.Rename\"%SRCSRexe% \"%%1\""
	
	:REG-Context_Menu-ALL_Rename
	echo [%RegExALL%\RCSR.Universal.Rename]
	echo "MUIVerb"="Rename Subtitle"
	echo [%RegExALL%\RCSR.Universal.Rename\command]
	echo @="%SCMD% set \"Context=All.Rename\"%SRCSRexe% \"%%1\""
	
)>>"%Setup_Write%"
exit /b
