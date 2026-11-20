@echo off
rem Startet die Browser-Vorschau der Solarctic-Zen-App (Standard: http://localhost:8080).
rem Nur zum Ausprobieren von Ablaeufen und Design; keine Geraetefunktionen.
set PUB_CACHE=D:\SolarcticApp\sdk\pub-cache
set PATH=D:\SolarcticApp\sdk\flutter\bin;%PATH%
if "%PORT%"=="" set PORT=8080
cd /d D:\SolarcticApp\SolarcticZen\app
flutter run -d web-server --web-hostname localhost --web-port %PORT%
