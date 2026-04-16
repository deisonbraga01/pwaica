# Runbook de build iOS e envio para TestFlight

## Pré-requisitos
- Mac com Xcode atualizado.
- Apple Developer ativo com permissões de App Manager.
- Bundle ID: `br.com.icamedtec.telemedicinahumana`.
- Certificados e profiles válidos no time Apple.

## 1) Preparar projeto
No terminal (Mac), na raiz do projeto:

```bash
npm ci
npm run cap:sync:ios
```

## 2) Abrir no Xcode e configurar assinatura
```bash
npm run cap:open:ios
```

No Xcode:
1. Selecione target `App`.
2. Em `Signing & Capabilities`, escolha seu Team.
3. Confirme `Bundle Identifier` igual ao configurado para produção.
4. Defina versão (`Marketing Version`) e build (`Current Project Version`).

## 3) Validar build local
1. Rode em simulador iPhone e iPad.
2. Rode em dispositivo físico.
3. Verifique:
   - tela inicial carrega;
   - fallback offline abre quando sem rede;
   - links externos abrem fora do app;
   - fluxo CPF -> link seguro funciona.

## 4) Arquivar e enviar para TestFlight
No Xcode:
1. `Product` -> `Archive`.
2. Em Organizer, `Distribute App`.
3. Escolha `App Store Connect` -> `Upload`.
4. Finalize upload.

Opcional via CLI (ambiente avançado):
```bash
xcodebuild -workspace ios/App/App.xcworkspace -scheme App -configuration Release -destination generic/platform=iOS archive -archivePath build/App.xcarchive
```

## 5) Configurar TestFlight
No App Store Connect:
1. Abra o build enviado.
2. Preencha `What to Test`.
3. Adicione testadores internos.
4. Execute smoke test antes de enviar para review final.

## 6) Enviar para revisão da Apple
1. Complete metadados com base em `docs/app-store/app-store-connect-metadata.md`.
2. Suba screenshots conforme `docs/app-store/assets-checklist-ios.md`.
3. Preencha `Sign-In Information` com CPF de teste.
4. Envie para revisão.
