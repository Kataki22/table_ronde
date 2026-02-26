@echo off
REM Script de test pour Windows

echo Test de l'API TableRonde Backend
echo ====================================
echo.

set BASE_URL=http://localhost:3000

echo 1. Verification de la connexion au serveur...
curl -s %BASE_URL% >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Serveur accessible
) else (
    echo [ERREUR] Serveur non accessible
    echo.
    echo Assurez-vous que le serveur est demarre avec: npm start
    exit /b 1
)

echo.
echo 2. Test des endpoints...

echo Testing GET /posts...
curl -s -o nul -w "HTTP %%{http_code}" %BASE_URL%/posts
echo.

echo Testing GET /profiles...
curl -s -o nul -w "HTTP %%{http_code}" %BASE_URL%/profiles
echo.

echo Testing GET /chats...
curl -s -o nul -w "HTTP %%{http_code}" %BASE_URL%/chats
echo.

echo Testing GET /messages...
curl -s -o nul -w "HTTP %%{http_code}" %BASE_URL%/messages
echo.

echo.
echo 3. Affichage des donnees...

echo.
echo Posts disponibles:
curl -s %BASE_URL%/posts | findstr /C:"\"id\""

echo.
echo Profils disponibles:
curl -s %BASE_URL%/profiles | findstr /C:"\"id\""

echo.
echo Tests termines!
echo.
echo Conseils:
echo    - Utilisez http://localhost:3000 dans votre navigateur
echo    - Consultez SERVER_JSON_GUIDE.md pour plus d'informations
echo    - Lancez 'dart run scripts/generate_mock_data.dart' pour plus de donnees

pause
