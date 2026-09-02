# Bônus — Facebook como provedor de identidade

> Este bônus **pode não terminar em aula**: a Meta pede verificação de segurança ao criar a conta de desenvolvedor,
> e a criação do app tem mais telas que o Google. Faça com calma, em casa se preciso.

## Objetivo

Permitir que o cliente entre no `LabExternalId.Web` com a conta do Facebook, mantendo o app da Meta em modo de
desenvolvimento para evitar App Review e verificação de negócio.

## Tempo estimado

30 a 45 minutos (mais 10 se ainda não tiver conta em Meta for Developers).

## Pré-requisitos

- Módulos 3 e 4 concluídos: fluxo `SignUpSignIn` e app registration `LabExternalId-Web` funcionando.
- Conta pessoal do Facebook, registrada em `https://developers.facebook.com` como desenvolvedor.
- Uma URL pública qualquer para servir de **Privacy Policy URL** (a Meta exige o campo preenchido; para o laboratório
  pode ser a página de privacidade do site da sua empresa).
- Dois valores do seu tenant externo, em **Entra ID > Overview**: `<tenant-ID>` (GUID em **Tenant ID**) e
  `<subdominio>` (parte antes de `.onmicrosoft.com` em **Primary domain**).

## Passos

### Parte A — Meta for Developers

1. Acesse `https://developers.facebook.com/apps` e clique em **Create App**.
2. Em **What do you want your app to do?**, selecione **Authenticate and request data from users with Facebook Login**
   e clique em **Next**.
3. Em **Are you building a game?**, selecione **No, I'm not building a game** e clique em **Next**.
4. Preencha **App name** = `Lab External ID` e **App contact email** = seu e-mail. Clique em **Create app** e
   confirme a senha do Facebook se solicitado.
5. No menu lateral do app, abra **App settings > Basic**.
6. Copie **App ID** e clique em **Show** ao lado de **App secret** para copiá-lo. Guarde os dois.
7. Ainda em **Basic**, preencha:
   - **Privacy Policy URL**: a URL do pré-requisito (campo obrigatório).
   - **Terms of Service URL**: a mesma URL ou a de termos da sua empresa.
   - **User Data Deletion**: selecione `Data deletion instructions URL` e informe a mesma URL.
   - **Category**: `Business and pages`.
8. No fim da página, clique em **Add platform > Website** e preencha **Site URL** = `https://<subdominio>.ciamlogin.com/`.
9. Clique em **Save changes**.
10. No menu lateral, abra **Use cases**. Na linha **Authentication and account creation**, clique em **Customize**.
11. Em **Permissions**, na linha **email**, clique em **Add**. (`public_profile` já vem incluído.)
12. Na mesma tela, em **Settings** de **Facebook Login**, clique em **Go to settings**.
13. Em **Valid OAuth Redirect URIs**, cole os seis valores abaixo, substituindo `<tenant-ID>` e `<subdominio>`:

    ```
    https://login.microsoftonline.com/te/<tenant-ID>/oauth2/authresp
    https://login.microsoftonline.com/te/<subdominio>.onmicrosoft.com/oauth2/authresp
    https://<subdominio>.ciamlogin.com/<tenant-ID>/federation/oidc/www.facebook.com
    https://<subdominio>.ciamlogin.com/<subdominio>.onmicrosoft.com/federation/oidc/www.facebook.com
    https://<subdominio>.ciamlogin.com/<tenant-ID>/federation/oauth2
    https://<subdominio>.ciamlogin.com/<subdominio>.onmicrosoft.com/federation/oauth2
    ```

14. Clique em **Save changes**.
15. **Não** mude o app para `Live`. No topo da página, o seletor **App Mode** deve permanecer em `Development`.
    Em modo Live a Meta exige perguntas de tratamento de dados e verificação de negócio; em Development, apenas
    pessoas com papel no app conseguem entrar, o que é suficiente para o laboratório.
16. No menu lateral, abra **App roles > Roles**. Em **Testers**, clique em **Add People**, informe o nome ou perfil
    do Facebook de quem vai testar (você mesmo já é Administrator e não precisa) e confirme. O convidado precisa
    aceitar o convite em `https://developers.facebook.com/requests`.

### Parte B — Entra admin center

17. Acesse `https://entra.microsoft.com` e confirme que está no tenant externo (ícone de configurações no topo >
    **Directories + subscriptions**).
18. Abra **Entra ID > External Identities > All identity providers**.
19. Na aba **Built-in**, na linha **Facebook**, clique em **Configure**.
20. Preencha:
    - **Name**: `Facebook`.
    - **Client ID**: o **App ID** copiado no passo 6.
    - **Client secret**: o **App secret** copiado no passo 6.
21. Clique em **Save**.
22. Abra **Entra ID > External Identities > User flows** e clique em `SignUpSignIn`.
23. No menu do fluxo, abra **Settings > Identity providers**.
24. Em **Other Identity Providers**, marque **Facebook** e clique em **Save**.

### Parte C — Teste

25. Com o `LabExternalId.Web` rodando (F5 no Visual Studio), abra `https://localhost:7100/` e clique em **Entrar**.
26. A página de login do tenant agora exibe o botão **Facebook**. Clique nele.
27. Entre com a conta do Facebook que é Administrator ou Tester do app e aceite o consentimento.
28. Na primeira vez, o fluxo pede os atributos configurados no módulo 3 (ex.: **Empresa**). Preencha e continue.
29. Em **Meu perfil**, observe as claims: `idp` = `facebook.com`.

## Checkpoint

- App da Meta em modo `Development`, com **email** adicionado em Permissions e os seis redirect URIs salvos.
- Botão **Facebook** visível na página de login do tenant externo.
- Login com a conta Administrator ou Tester conclui e cria um cliente em **Entra ID > Users** com **Identities** = `facebook.com`.

## Se der errado

- **Facebook exibe "App not active" ou "This app is in development mode"**: a conta usada não tem papel no app.
  Adicione-a em **App roles > Roles > Testers** (passo 16) e aceite o convite antes de tentar de novo.
- **Facebook exibe "URL Blocked: This redirect failed because the redirect URI is not whitelisted"**: um dos seis
  URIs do passo 13 está errado. Compare `<tenant-ID>` (GUID) com `<subdominio>` (texto) e confira `www.facebook.com`.
- **Facebook exibe "Invalid Scopes: email"**: a permissão **email** não foi adicionada no caso de uso (passo 11).
- **O botão Facebook não aparece no login**: o provedor foi configurado, mas não adicionado ao fluxo. Refaça os
  passos 22 a 24 e teste em janela anônima.
