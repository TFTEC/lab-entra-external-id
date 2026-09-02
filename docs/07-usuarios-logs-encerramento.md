# Módulo 7 — Usuários, logs e encerramento

## Objetivo

Ver do lado do administrador tudo o que o cliente fez: a conta criada com o atributo `Empresa`, os logins
com e sem MFA, o reset de senha e o cadastro. Fechar a aula sabendo o que ficou de fora e por quê.

## Tempo estimado

10 minutos.

## Passos

### A. O cliente no diretório

1. **Entra ID > Users**. O cliente aparece com **User type: Member** e o e-mail de teste como nome principal.
2. Abra o cliente. Em **Properties**, localize **Display name** e, mais abaixo, o atributo customizado
   **Empresa** com o valor informado no cadastro.
3. No menu do usuário, **Authentication methods**: aparece o e-mail como método (é o que recebe o código).
4. Ações que um administrador tem à mão, só para conhecer: **Reset password** (gera senha temporária),
   **Revoke sessions**, **Delete** (recuperável por 30 dias em **Deleted users**).
5. Criar cliente manualmente, sem cadastro pelo app: **+ New user > Create new external user**, método de
   entrada **Email**, e-mail e nome. Não é preciso criar agora.

### B. Logs

6. **Entra ID > Monitoring & health > Sign-in logs**. Filtre por **User** com o e-mail de teste. Abra um
   login recente:
   - Aba **Basic info**: **Application** = `LabExternalId-Web`, **Status** = Success.
   - Aba **Authentication Details**: com o módulo 6 ativo, aparece a etapa **Email** como segundo fator.
   - Aba **Conditional Access**: `MFA-LabExternalId` com resultado **Success**.
7. Encontre também o login que falhou com **AADSTS700054** no módulo 4 (Status = Failure) e leia o
   **Failure reason**: é o mesmo texto que o cliente viu.
8. **Monitoring & health > Audit logs**: filtre **Category** = `UserManagement`. Estão lá o **Add user**
   do cadastro e o **Reset password** do módulo 5. Filtre `Policy` para ver a criação da política de
   Conditional Access.
9. **Monitoring & health > Sign-ups**: relatório exclusivo de tenant externo com os cadastros concluídos e
   abandonados por fluxo de usuário. Pode levar alguns minutos para refletir.
10. Retenção: os logs de tenant externo ficam disponíveis por **7 dias**. Para guardar mais, o caminho é
    exportar para Azure Monitor, fora do escopo.

### C. Encerramento

O que foi construído em 2 horas, sem CLI:

| Camada | O que você fez |
|--------|----------------|
| Diretório | Tenant externo próprio, vinculado à sua assinatura |
| Experiência | Branding, atributo `Empresa`, fluxo `SignUpSignIn` com e-mail e senha |
| Aplicativo | App registration `LabExternalId-Web` com dois redirect URIs, segredo e consentimento; app .NET entrando e saindo; variação sem segredo |
| Segurança | Reset de senha por código por e-mail; MFA imposto por Conditional Access |
| Operação | Usuários, logs de entrada, auditoria e cadastros |

O que ficou de fora, de propósito, e o motivo:

- **Domínio de URL customizado** (`login.suaempresa.com.br` no lugar de `*.ciamlogin.com`): exige Azure
  Front Door, DNS e custo extra. É o próximo passo natural em produção.
- **Passkeys**: dependem do domínio customizado.
- **MFA por SMS**: add-on cobrado por transação, com opt-in por país.
- **Extensões de autenticação customizadas** (chamar uma API sua durante o cadastro ou na emissão do token):
  poderosas, mas precisam de uma API publicada.
- **Autenticação nativa** (tela de login dentro do app mobile): outro modelo de integração.
- **Colaboração B2B**: é o External ID do tenant corporativo, outro assunto.

### D. Limpeza (depois da aula, opcional)

- Desative ou apague a política `MFA-LabExternalId`.
- Apague o app registration e o fluxo, ou o tenant inteiro: `Entra ID > Overview > Manage tenants`,
  selecione o tenant externo, **Delete**. O portal lista o que precisa ser removido antes (usuários,
  aplicativos, assinatura vinculada).
- Se fez o módulo 8, apague o resource group do App Service: o plano B1 é cobrado por hora.

## Checkpoint

- Você localizou o cliente com o atributo `Empresa` preenchido.
- Você abriu um login com a etapa de MFA por e-mail e a política `MFA-LabExternalId` no log.

## Se der errado

- **Login não aparece no Sign-in logs**: atraso de alguns minutos; ajuste o filtro de data para 24 horas.
- **Sign-ups vazio**: o relatório é assíncrono; volte depois.
- **Não consegue apagar o tenant**: remova antes usuários, app registrations e a assinatura vinculada,
  conforme a lista que o portal mostra.
