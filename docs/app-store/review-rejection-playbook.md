# Playbook de rejeição (App Store)

## Objetivo
Responder rapidamente a rejeições comuns da Apple com correções objetivas e reenvio sem retrabalho.

## Rejeição 4.2 (funcionalidade insuficiente / app muito parecido com site)
### Sintoma
Apple sinaliza que o app oferece valor limitado por ser essencialmente conteúdo web.

### Ações imediatas
1. Evidenciar no binário os fluxos otimizados mobile (login por CPF, estados de rede, abertura externa segura).
2. Garantir loading/falha/retentativa visíveis no app.
3. Atualizar nota de revisão explicando valor de uso clínico para pacientes.

### Mensagem sugerida ao App Review
Este aplicativo oferece fluxo de acesso clínico otimizado para iOS, com autenticação por CPF, tratamento nativo de falha de rede, experiência de uso dedicada para pacientes e integração segura com nossa plataforma de telemedicina.

## Rejeição por metadata inconsistente
### Sintoma
Nome, descrição ou screenshots não refletem o comportamento real.

### Ações imediatas
1. Verificar copy em app e App Store Connect.
2. Atualizar screenshots para refletir versão atual.
3. Reenviar com changelog curto e objetivo.

## Rejeição por login inacessível ao revisor
### Sintoma
Apple não consegue entrar no app por ausência de credenciais/teste.

### Ações imediatas
1. Fornecer CPF de teste válido.
2. Adicionar instrução passo a passo no campo `Sign-In Information`.
3. Confirmar validade do ambiente de teste antes de reenviar.

## Rejeição por links/política de privacidade
### Sintoma
URL quebrada, redirecionamento inválido ou conteúdo insuficiente.

### Ações imediatas
1. Confirmar disponibilidade de `https://icamedtec.com.br/app/privacy.html`.
2. Garantir URL de suporte ativa.
3. Revisar texto legal para aderência com fluxo real.

## Template curto de resposta para reenvio
Obrigado pelo feedback. Atualizamos o app para resolver os pontos reportados:
1. [ponto 1 corrigido]
2. [ponto 2 corrigido]
3. [ponto 3 corrigido]

Também atualizamos as informações de revisão:
- Credenciais/CPF de teste: [valor]
- Passos de acesso: [passo a passo]

Solicitamos nova análise deste build.
