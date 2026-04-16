# Guia passo a passo para upload iOS sem Mac (Windows + Codemagic automático)

Este é o fluxo mais simples para seu cenário: você usa Windows e quer publicar iOS sem gerar manualmente `.p12` e `.mobileprovision`.

O Codemagic faz build em macOS na nuvem e pode cuidar da assinatura automaticamente.

## 0) Pré-requisitos mínimos
- Conta Apple Developer ativa.
- Acesso ao App Store Connect com perfil `Admin` ou `App Manager`.
- Repositório do projeto no GitHub.
- App criado no App Store Connect com bundle id `br.com.icamedtec.telemedicinahumana`.
- API Key da App Store Connect (Issuer ID, Key ID e arquivo `.p8`).

## 1) Criar conta no Codemagic e conectar o repositório
1. Acesse [Codemagic](https://codemagic.io/) e faça login com GitHub.
2. Clique em `Add application`.
3. Selecione o repositório `appicamedtec`.
4. Escolha workflow para app iOS/Capacitor.

## 2) Configurar credenciais Apple no Codemagic
No Codemagic, em configurações do app/workflow:

1. Abra a seção de integração com App Store Connect.
2. Informe:
   - `Issuer ID`
   - `Key ID`
   - upload do arquivo `.p8`
3. Ative `Automatic code signing`.

Com isso, o Codemagic gerencia certificado e provisioning profile para você.

## 3) Configurar o build do projeto
No workflow iOS, defina estas etapas:
1. `npm ci`
2. `npm run cap:sync:ios`
3. build iOS com export para App Store/TestFlight

Se o assistente do Codemagic perguntar o tipo de distribuição, selecione `App Store`.

## 4) Disparar o primeiro build
1. Clique em `Start new build`.
2. Selecione a branch principal.
3. Rode o build.
4. Aguarde finalizar.

## 5) Publicar no TestFlight pelo Codemagic
No mesmo workflow:
1. Ative publicação para `App Store Connect` / `TestFlight`.
2. Vincule o app correto.
3. Execute novo build com publish habilitado.

Quando terminar, valide no App Store Connect -> `TestFlight`.

## 6) Teste interno obrigatório
1. Adicione testadores internos.
2. Preencha `What to Test`.
3. Valide:
   - abertura do app;
   - login por CPF e redirecionamento;
   - fallback sem internet;
   - links externos abrindo fora do app.

## 7) Enviar para App Review
No App Store Connect:
1. Preencha metadados e URLs.
2. Faça upload das screenshots.
3. Informe política de privacidade.
4. Em `App Review Information`, inclua instruções e CPF de teste.
5. Selecione o build e clique `Submit for Review`.

Arquivos de apoio:
- `docs/app-store/app-store-connect-metadata.md`
- `docs/app-store/assets-checklist-ios.md`
- `docs/app-store/review-rejection-playbook.md`

## 8) Erros comuns no Codemagic
- **Falha de assinatura automática**: conferir se API Key tem permissão e se bundle id está correto.
- **Build não aparece no TestFlight**: verificar se `Publish to App Store Connect` está habilitado.
- **Erro de versão/build**: aumentar `build number` antes de novo envio.
- **Rejeição por login**: sempre fornecer CPF de teste e passo a passo para o reviewer.

## 9) Plano B (se assinatura automática falhar)
Se a assinatura automática não funcionar no seu time Apple, você pode voltar ao fluxo manual com `.p12` e `.mobileprovision`, mas só como contingência.
