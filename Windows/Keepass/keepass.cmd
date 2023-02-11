@echo off
rem This script should replace your keepass shortcut to protect against the trigger vuln described in CVE-2023-24055.
rem the vuln is that an adversari could update your keepass.config.xml and put triggers into it so when you start and login our passwords would be exported and shipped off.
rem even though that would mean you have severe other problems to deal with, like how did they get into your computer for a starter. anyway
rem
rem this script will at first run create a md5sum of your keepass.config.xml and store it in a file in your temp folder.
rem at every next run it will compare the current md5sum of your config with the stored one, if it differs you'll be warned.
rem if not it will start keepass.

set keepath="C:\Program Files\KeePass Password Safe 2"
set xmlFile=%keepath%\keepass.config.xml
set realExe=%keepath%\keePass.exe
set checkFile=%TEMP%\mycheck.txt

IF EXIST %checkFile% (
  echo md5sum of config exists.
  pause
) else (
  echo Calculating the MD5sum for the keepass.config.xml and saving it to mycheck.txt in %TEMP%
  certutil -hashfile %xmlFile% MD5 | findstr /V "MD5 Cert" > %checkFile%
  pause
  exit 1
)

rem Calculate the current MD5 sum of the XML file
echo Calc the MD5 of current file
pause
for /f "tokens=1 delims=" %%a in ('certutil -hashfile %xmlFile% MD5 ^| findstr /V "MD5 Cert"') do set currentMd5=%%a

rem Read the stored MD5 sum from the check file
echo Read the stored MD5 value
set /p storedMd5=<"%checkFile%"
echo The Stored file is: %storedMd5%
echo Current MD5 is: %currentMd5%

rem Compare the current and stored MD5 sums

if "%currentMd5%" == "%storedMd5%" (
  call %realExe%
) else (
  echo WARNING: MD5 sum of %xmlFile% does not match the stored value!
  echo "Examine the content before you proceed!!"
  echo
  echo Current: %currentMd5%
  echo Stored: %storedMd5%
  pause
  exit 1
)
