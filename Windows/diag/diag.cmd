@echo off
cls

SET VER="Version 1.0  Updated 20230825"

Rem ##### Config Start ###############
Rem # Set a internal and an external IP to lookup in DNS. (If external DNS calls are allowed a third lookup is done which will show external IP.)
SET dns_1="myintranet.domain.com"
SET dns_2="myPublic.website.com"

Rem # Set an internal and external IP/FQDN that is pingable.
SET ping_ip_1="internal.host.com"
SET ping_ip_2="external.host.com"

Rem # Set an internal and external IP/FQDN that is open for traceroute.
SET tracert_ip_1="internal.host.com"
SET tracert_ip_2="external.host.com"

Rem # Enable/Disable modules to be run or not.
SET EnableProxy=1
SET EnableVPN=1
SET EnableSSL=1
Rem ##### Config End ###############

@echo *** DIAG gathering basic computer information
@echo *** %VER%
@echo *** Please wait for this window to close
@echo ***

cd %TEMP%
@echo ################### Date and time ####################### > %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
date /t >> %COMPUTERNAME%.txt
time /t >> %COMPUTERNAME%.txt
@echo %VER% >>%COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt

@echo ################### Network IP Configuration ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
ipconfig /all >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt

@echo ################### Routing table ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
route print >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### Wireless Interfaces ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
netsh wlan show interfaces >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### Wireless driver ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
netsh wlan show drivers >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### Wireless Networks detected ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
netsh wlan show network mode=Bssid >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### Net Use ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
net use >> %COMPUTERNAME%.txt
for /f "tokens=2 delims=\\" %%i in ('net use') do ping -l 512 %%i >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### Netstat ALL ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
netstat -an >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### Netstat Statistics ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
netstat -e >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### ARP ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
arp -a >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### DNS checks ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo %dns_1% >> %COMPUTERNAME%.txt
nslookup %dns_1% >> %COMPUTERNAME%.txt
@echo %dns_2% >> %COMPUTERNAME%.txt
set /p "=." <nul

nslookup %dns_2% >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo "External IP lookup with DNS (if empty allow firewall acess to *.opendns.com)"  >> %COMPUTERNAME%.txt
nslookup myip.opendns.com. resolver1.opendns.com 2>nul >> %COMPUTERNAME%.txt
@echo. >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### Ping Default Gateway ####################### >> %COMPUTERNAME%.txt
@echo # Note: on VPN DG will not respond >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
for /f "tokens=3" %%* IN ('route print ^| findstr "\<0.0.0.0\>"') DO ping -n 2 %%* >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### Ping checks ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
ping -n 2 %ping_ip_1% >> %COMPUTERNAME%.txt
ping -n 2 %ping_ip_2% >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### Traceroute checks ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
tracert -d %tracert_ip_1% >> %COMPUTERNAME%.txt
set /p "=." <nul

tracert -d %tracert_ip_2% >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

@echo ################### Variables ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
set >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt

@echo ################### Windwos Version ####################### >> %COMPUTERNAME%.txt
@echo # 10 = 10.0.10586.104  8.1 = 6.3.9600  8.0 = 6.2.9200 >> %COMPUTERNAME%.txt
@echo # 7 = 6.1.7600  Vista = 6.0.6001 XP = 5.1.2600 98 = 4.1.2222 >> %COMPUTERNAME%.txt
@echo # 2016 = 10  2012 R2 = 6.3  2012 = 6.2  2008R2 = 6.1 2008 = 6.0  >> %COMPUTERNAME%.txt
ver >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt

@echo ################### Windows Services Running ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
net start >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul

if "%EnableProxy%"==1 (
@echo ################### Proxy Settings ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet settings" >> %COMPUTERNAME%.txt
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v DefaultConnectionSettings >> %COMPUTERNAME%.txt
@echo # Setting at byte 9 >> %COMPUTERNAME%.txt
@echo # 09 when only ‘Automatically detect settings’ is enabled  >> %COMPUTERNAME%.txt
@echo # 03 when only ‘Use a proxy server for your LAN’ is enabled >> %COMPUTERNAME%.txt
@echo # 0B when both are enabled >> %COMPUTERNAME%.txt
@echo # 05 when only ‘Use automatic configuration script’ is enabled for PAC file>> %COMPUTERNAME%.txt
@echo # 0D when ‘Automatically detect settings’ and ‘Use automatic configuration script’ are enabled >> %COMPUTERNAME%.txt
@echo # 07 when ‘Use a proxy server for your LAN’ and ‘Use automatic configuration script’ are enabled >> %COMPUTERNAME%.txt
@echo # 0F when all the three are enabled. >> %COMPUTERNAME%.txt
@echo # 01 when none of them are enabled. >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul
)

@echo ################### Host file ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
type c:\Windows\System32\drivers\etc\hosts >> %COMPUTERNAME%.txt
@echo.  >> %COMPUTERNAME%.txt

IF "%EnableVPN%"=="1" (
@echo ################### VPN Mobile Endpoint Client ####################### >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
IF EXIST "C:\Program Files (x86)\CheckPoint\Endpoint Connect\trac.exe" (
"C:\Program Files (x86)\CheckPoint\Endpoint Connect\trac.exe" info >> %COMPUTERNAME%.txt
"C:\Program Files (x86)\CheckPoint\Endpoint Connect\trac.exe" ver >> %COMPUTERNAME%.txt
@echo Should be E80.62 = Endpoint Security version NGX build 986000452 or later >> %COMPUTERNAME%.txt
) ELSE (
@echo No Mobile Endpoint Client installed
)
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul
)

IF "%EnableSSL%"=="1" (
@echo ###################### SSL Network Extender ########################## >> %COMPUTERNAME%.txt
@echo # Should be atleast version 800007079, if it is not then uninstall >> %COMPUTERNAME%.txt
@echo # >> %COMPUTERNAME%.txt
IF EXIST "C:\Program Files (x86)\CheckPoint\SSL Network Extender\ver.ini" (
type "C:\Program Files (x86)\CheckPoint\SSL Network Extender\ver.ini" >> %COMPUTERNAME%.txt
) ELSE (
@echo SSL Network Extender is not installed
)
@echo.  >> %COMPUTERNAME%.txt
set /p "=." <nul
)

@echo *** Attach the file %COMPUTERNAME%.txt to your ITSM ticket.
@echo ***
@echo *** Press any key to find %COMPUTERNAME%.txt

start %SystemRoot%\Notepad.exe "%TEMP%\%COMPUTERNAME%.TXT"

rem pause > nul

