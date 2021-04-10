@echo off

set DownloadURL="https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-1.0.0-win64.zip"
powershell -Command "Invoke-WebRequest %DownloadURL% -OutFile speedtest.zip"
powershell -nologo Expand-Archive speedtest.zip -DestinationPath ./ -Force
attrib +h +s speedtest.exe

del speedtest.zip
del speedtest.md


call:get_time
set "filename=results_%fullstamp%.csv"

echo Results will be write to "%filename%"

set csv_header="server name","server id","latency","jitter","packet loss","download","upload","download bytes","upload bytes","share url","date"
echo %csv_header% > tmp.csv

copy tmp.csv %filename% > NUL
del tmp.csv

REM get user input interval time
set /p delay_min="Input delay between tests in minutes: "
set /a delay_sec = %delay_min%*60

echo Delay between test will be %delay_sec% secondes

:_start_spdtst

	REM start periodical speedtest
	echo Test in progress...
	FOR /F "tokens=*" %%o IN ('speedtest.exe -f csv') do (SET VAR=%%o)
	echo Test OK
	
	call:get_time
	echo %var%,"%fullstamp%" > tmp.csv
	type tmp.csv >> %filename%
	del tmp.csv

	timeout /t %delay_sec%

	goto _start_spdtst


:get_time
REM get timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "fullstamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"
goto:eof