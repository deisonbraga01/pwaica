@echo off
chcp 65001 >nul
set API=https://n8nwebhookportaine.centralad.com.br/webhook/criar-imagem-for-gemini
set IMGS=%~dp0..\imgs
if not exist "%IMGS%" mkdir "%IMGS%"

set STYLE= Design grafico clean, sem texto, sem marca dagua, alta qualidade, estilo app de telemedicina premium, paleta teal e azul escuro, contraste forte para PWA.

echo Gerando icon-192.png...
curl -s -X POST "%API%" -H "Content-Type: application/json" -d "{\"prompt\": \"Icone PWA quadrado 192x192 para ICA Med Tec, simbolo medico estilizado com escudo e estetoscopio, fundo teal escuro, composicao centralizada, sem texto.%STYLE%\"}" -o "%IMGS%\icon-192.png"
echo Gerando icon-512.png...
curl -s -X POST "%API%" -H "Content-Type: application/json" -d "{\"prompt\": \"Icone PWA quadrado 512x512 para ICA Med Tec, simbolo medico elegante, fundo gradiente azul petroleo para teal, alta nitidez, sem texto.%STYLE%\"}" -o "%IMGS%\icon-512.png"
echo Gerando icon-maskable-512.png...
curl -s -X POST "%API%" -H "Content-Type: application/json" -d "{\"prompt\": \"Icone maskable 512x512 para PWA ICA Med Tec, elemento principal bem centralizado com margem segura ampla, sem texto, visual premium.%STYLE%\"}" -o "%IMGS%\icon-maskable-512.png"
echo Gerando apple-touch-icon.png...
curl -s -X POST "%API%" -H "Content-Type: application/json" -d "{\"prompt\": \"Icone apple touch 180x180 para app ICA Med Tec, fundo limpo e contraste alto, simbolo medico central, sem texto.%STYLE%\"}" -o "%IMGS%\apple-touch-icon.png"
echo Gerando pwa-screenshot-wide.png...
curl -s -X POST "%API%" -H "Content-Type: application/json" -d "{\"prompt\": \"Screenshot PWA horizontal 1280x720 estilo mockup do app ICA Med Tec: tela de login com CPF, botao link magico, tema dark teal, sem texto legivel de marca.%STYLE%\"}" -o "%IMGS%\pwa-screenshot-wide.png"
echo Gerando pwa-screenshot-narrow.png...
curl -s -X POST "%API%" -H "Content-Type: application/json" -d "{\"prompt\": \"Screenshot PWA vertical 720x1280 estilo mockup do app ICA Med Tec: fluxo de acesso do paciente por CPF, interface mobile dark teal, sem texto legivel de marca.%STYLE%\"}" -o "%IMGS%\pwa-screenshot-narrow.png"

echo Concluido. Assets PWA em %IMGS%
exit /b 0
