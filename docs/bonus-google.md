# Bônus — Google como provedor de identidade

## Objetivo

Permitir que o cliente se cadastre e entre no `LabExternalId.Web` com uma conta Google, sem criar senha local,
federando o tenant externo com o Google pelo protocolo OpenID Connect.

## Tempo estimado

20 a 25 minutos.

## Pré-requisitos

- Módulos 3 e 4 concluídos: fluxo `SignUpSignIn` e app registration `LabExternalId-Web` funcionando.
- Uma conta Google (pessoal ou Workspace) para acessar o Google Cloud console.
- Dois valores do seu tenant externo, ambos em **Entra ID > Overview**:
  - `<tenant-ID>`: o GUID exibido em **Tenant ID**.
  - `<subdominio>`: a primeira parte do **Primary domain** (o que vem antes de `.onmicrosoft.com`).

## Passos

### Parte A — Google Cloud console

1. Acesse `https://console.cloud.google.com` e entre com sua conta Google.
2. No seletor de projetos (topo), clique em **New project**. **Project name** = `lab-entra-external-id`. Clique em **Create**
   e, quando terminar, selecione o projeto.
3. No menu lateral, abra **APIs & Services > OAuth consent screen**.
4. Se aparecer o assistente **Google Auth Platform**, clique em **Get started** e preencha:
   - **App name**: `Lab External ID`.
   - **User support email**: seu e-mail.
   - **Audience**: `External`.
   - **Contact information**: seu e-mail.
   Aceite a política e clique em **Create**.
   (Em consoles com o formulário antigo: **User Type** = `External` > **Create**, depois preencha **App name** e os e-mails.)
5. Em **Branding** (ou na mesma tela, seção **Authorized domains**), clique em **Add domain** e adicione, um por vez:
   - `ciamlogin.com`
   - `microsoftonline.com`
   Clique em **Save**.
6. Em **Audience**, confirme que **Publishing status** está em `Testing`. Em **Test users**, clique em **Add users** e
   inclua o e-mail Google que você usará para testar o login. Clique em **Save**. Enquanto o app estiver em `Testing`,
   apenas os test users conseguem entrar; isso é suficiente para o laboratório.
7. Abra **APIs & Services > Credentials > Create credentials > OAuth client ID**.
8. Preencha:
   - **Application type**: `Web application`.
   - **Name**: `Entra External ID`.
9. Em **Authorized redirect URIs**, clique em **Add URI** sete vezes e cole exatamente estes valores, substituindo
   `<tenant-ID>` e `<subdominio>`:

   ```
   https://login.microsoftonline.com
   https://login.microsoftonline.com/te/<tenant-ID>/oauth2/authresp
   https://login.microsoftonline.com/te/<subdominio>.onmicrosoft.com/oauth2/authresp
   https://<tenant-ID>.ciamlogin.com/<tenant-ID>/federation/oidc/accounts.google.com
   https://<tenant-ID>.ciamlogin.com/<subdominio>.onmicrosoft.com/federation/oidc/accounts.google.com
   https://<subdominio>.ciamlogin.com/<tenant-ID>/federation/oauth2
   https://<subdominio>.ciamlogin.com/<subdominio>.onmicrosoft.com/federation/oauth2
   ```

10. Clique em **Create**. Na janela **OAuth client created**, copie **Client ID** e **Client secret**. Guarde os dois;
    o secret não é exibido de novo (é possível gerar outro depois em **Credentials**).

### Parte B — Entra admin center

11. Acesse `https://entra.microsoft.com` e confirme que está no tenant externo (ícone de configurações no topo >
    **Directories + subscriptions**).
12. Abra **Entra ID > External Identities > All identity providers**.
13. Na aba **Built-in**, na linha **Google**, clique em **Configure**.
14. Preencha:
    - **Name**: `Google`.
    - **Client ID**: o Client ID copiado no passo 10.
    - **Client secret**: o Client secret copiado no passo 10.
15. Clique em **Save**.
16. Abra **Entra ID > External Identities > User flows** e clique em `SignUpSignIn`.
17. No menu do fluxo, abra **Settings > Identity providers**.
18. Em **Other Identity Providers**, marque **Google** e clique em **Save**.

### Parte C — Teste

19. Com o `LabExternalId.Web` rodando (F5 no Visual Studio), abra `https://localhost:7100/` e clique em **Entrar**.
20. A página de login do tenant agora exibe o botão **Google** abaixo do formulário de e-mail. Clique nele.
21. Entre com a conta Google adicionada como test user no passo 6 e aceite o consentimento.
22. Na primeira vez, o fluxo pede os atributos configurados no módulo 3 (ex.: **Empresa**). Preencha e continue.
23. Em **Meu perfil**, observe as claims: `idp` = `google.com` e `preferred_username` com o e-mail Google.

## Checkpoint

- Botão **Google** visível na página de login do tenant externo.
- Login com a conta Google conclui e cria um cliente em **Entra ID > Users** com **Identities** = `google.com`.
- `/Perfil` mostra a claim `idp` apontando para o Google.

## Se der errado

- **Google exibe `Error 400: redirect_uri_mismatch`**: um dos sete URIs do passo 9 está errado ou faltando. Abra
  **Credentials > seu client > Authorized redirect URIs** e compare caractere a caractere, principalmente
  `<tenant-ID>` (GUID) versus `<subdominio>` (texto), e o `.onmicrosoft.com`.
- **Google exibe `Error 403: access_denied` ou "app not verified"**: o app está em `Testing` e o e-mail usado não é
  test user. Volte ao passo 6 e adicione o e-mail.
- **Google exibe `invalid_request` mencionando domínio não autorizado**: falta `ciamlogin.com` ou
  `microsoftonline.com` em **Authorized domains** (passo 5).
- **O botão Google não aparece no login**: o provedor foi configurado mas não foi adicionado ao fluxo. Refaça os
  passos 16 a 18 e recarregue a página de login (abra em janela anônima para evitar cache de sessão).
