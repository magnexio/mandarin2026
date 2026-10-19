@echo off
rem Sube los cambios a GitHub Pages: https://magnexio.github.io/mandarin2026/
cd /d "%~dp0"
git add -A
git commit -m "Actualizacion %date%"
git push
echo.
echo Listo. La web se actualiza en 1-2 minutos: https://magnexio.github.io/mandarin2026/
pause
