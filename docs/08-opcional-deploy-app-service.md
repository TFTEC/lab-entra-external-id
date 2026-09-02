# Módulo 8 (opcional) — Deploy do app em Azure App Service via GitHub Actions

## Objetivo

Publicar o `LabExternalId.Web` do seu próprio repositório em um App Service, com o pipeline de GitHub Actions
gerado inteiramente pelo portal do Azure, e fazer login nele a partir do seu tenant externo.

## Tempo estimado

15 minutos (cerca de 5 deles esperando o primeiro run do Actions).

## Pré-requisitos

- Módulos 3 e 4 concluídos: fluxo `SignUpSignIn` e app registration `LabExternalId-Web` funcionando em `localhost`.
- Conta GitHub própria.
- Papel **Owner** ou **User Access Administrator** na assinatura Azure. **Contributor não basta**: o Deployment Center
  cria uma identidade gerenciada e uma atribuição de papel, e isso exige `roleAssignments/write`.
- Este módulo cria um plano **Basic B1**, cobrado por hora. O último passo apaga tudo.

## Passos

### Parte A — Seu próprio repositório no GitHub

1. Abra o repositório do laboratório no GitHub (o instrutor informa a URL; ele estará público e marcado como template).
2. Clique em **Use this template > Create a new repository**.
3. Preencha: **Owner** = sua conta; **Repository name** = `lab-entra-external-id`; **Visibility** = `Private`.
4. Clique em **Create repository**. Você fica com uma cópia independente, sem vínculo de fork.

### Parte B — Criar o Web App

5. Acesse `portal.azure.com` com a conta dona da assinatura.
6. Na busca superior, digite **App Services** e abra o serviço.
7. Clique em **Create > Web App**.
8. Aba **Basics**:
   - **Subscription**: sua assinatura.
   - **Resource Group**: **Create new** > `rg-lab-externalid`.
   - **Name**: `lab-externalid-<seu-nome>` (minúsculas, sem espaços; precisa ser único).
   - **Publish**: `Code`.
   - **Runtime stack**: `.NET 10 (LTS)`.
   - **Operating System**: `Windows`. (No Linux, o wizard de criação não oferece o passo do GitHub e o app ainda
     precisaria da variável `ASPNETCORE_FORWARDEDHEADERS_ENABLED=true`; no Windows a integração com o IIS resolve
     os cabeçalhos encaminhados sozinha.)
   - **Region**: a mesma do seu tenant ou a mais próxima (ex.: `Brazil South`).
   - **Windows Plan**: **Create new** > `plan-lab-externalid`.
   - **Pricing plan**: clique em **Explore pricing plans** e escolha **Basic B1**.
9. Clique em **Review + create > Create**. Aguarde o "Your deployment is complete" e clique em **Go to resource**.
10. Na página **Overview**, copie o valor de **Default domain**. Ele tem um sufixo único, no formato
    `lab-externalid-<seu-nome>-<hash>.<regiao>-01.azurewebsites.net`. Guarde-o: é o `<dominio>` dos próximos passos.
    Não tente adivinhar o hostname; copie do portal.

### Parte C — Deployment Center (gera o workflow do GitHub Actions)

11. No menu lateral do Web App, abra **Deployment Center**.
12. Na aba **Settings**, em **Source**, selecione `GitHub`.
13. Clique em **Authorize** e conclua o login no GitHub na janela que abrir. Se pedir, autorize o aplicativo
    **Azure App Service** a acessar sua conta.
14. Preencha:
    - **Organization**: sua conta GitHub.
    - **Repository**: `lab-entra-external-id`.
    - **Branch**: `main`.
15. Em **Authentication type**, selecione **User-assigned identity**. (Autenticação básica com publish profile vem
    desabilitada em App Services novos; a identidade gerenciada é o caminho suportado.)
16. Clique em **Save** no topo. O portal:
    - cria uma identidade gerenciada e a credencial federada para o seu repositório e branch;
    - cria os secrets `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` e `AZURE_SUBSCRIPTION_ID` no repositório;
    - faz um commit em `.github/workflows/` com um arquivo cujo nome contém o nome do Web App.
17. No GitHub, abra a aba **Actions** do seu repositório. O workflow gerado já deve estar em execução.
    Aguarde ficar verde (3 a 6 minutos). Enquanto isso, siga para a Parte D.

### Parte D — Configuração do app no App Service

18. De volta ao Web App, abra **Settings > Environment variables**, aba **App settings**.
19. Clique em **Add** três vezes e crie (atenção ao **duplo sublinhado**, que o ASP.NET Core converte em `:`):

    | Name | Value |
    |------|-------|
    | `AzureAd__Authority` | `https://<subdominio>.ciamlogin.com/` |
    | `AzureAd__ClientId` | Client ID do app registration `LabExternalId-Web` |
    | `AzureAd__ClientSecret` | o valor do client secret criado no módulo 4 |

20. Clique em **Apply** e confirme em **Confirm**. O app reinicia.

### Parte E — Redirect URIs no app registration

21. No Entra admin center do tenant externo, abra **Entra ID > App registrations > LabExternalId-Web > Authentication**.
22. Em **Web > Redirect URIs**, clique em **Add URI** e adicione, substituindo `<dominio>` pelo valor copiado no passo 10:
    - `https://<dominio>/signin-oidc`
    - `https://<dominio>/signout-callback-oidc`
23. Em **Front-channel logout URL**, o campo aceita um único valor. Troque-o por `https://<dominio>/signout-oidc`
    (o logout do `localhost` deixa de ser notificado, mas continua funcionando pelo redirect).
24. Clique em **Save**.

### Parte F — Teste

25. Confirme na aba **Actions** do GitHub que o run terminou com sucesso.
26. Abra `https://<dominio>/` no navegador. A página inicial deve mostrar o card "Como este app está configurado"
    com o seu Authority e Client ID, e o fluxo "Authorization code + PKCE (com client secret)".
27. Clique em **Entrar**, autentique-se com o cliente criado no módulo 4 e abra **Meu perfil**.
28. Clique em **Sair** e confirme a página "Você saiu".

### Parte G — Limpeza (não pule)

29. No portal do Azure, abra **Resource groups > rg-lab-externalid > Delete resource group**.
30. Digite o nome do grupo para confirmar e clique em **Delete**. Isso remove o Web App, o plano B1 e a identidade
    gerenciada. O workflow no seu repositório GitHub pode ficar; ele só falhará se for executado de novo.

## Checkpoint

- Aba **Actions** do seu repositório com um run verde do workflow gerado pelo portal.
- `https://<dominio>/` carrega sem aviso de "Configuração pendente".
- Login e logout funcionam a partir do App Service, com as mesmas claims vistas em `localhost`.
- Resource group apagado ao final.

## Se der errado

- **Erro ao salvar no Deployment Center mencionando permissão ou `roleAssignments`**: sua conta é Contributor na
  assinatura. Peça Owner ou User Access Administrator, ou use a assinatura em que você é Owner.
- **Workflow do Actions falha em "Login" ou "Deploy"**: abra o run e leia o passo vermelho. Se for `AADSTS700016` ou
  `federated identity`, o Deployment Center não concluiu a credencial federada; em **Deployment Center**, clique em
  **Disconnect**, depois refaça os passos 12 a 16.
- **`AADSTS50011` ao clicar em Entrar**: o redirect URI enviado não bate com o registrado. Compare o `<dominio>` do
  passo 10 com os URIs do passo 22, incluindo o sufixo com hash e a região.
- **Página inicial mostra "Configuração pendente" no App Service**: as variáveis do passo 19 não foram aplicadas
  ou o nome está com um sublinhado só. Confira `AzureAd__Authority` e `AzureAd__ClientId` e clique em **Apply**.
- **Site responde 503 ou "Application Error"**: abra **Monitoring > Log stream** e procure a exceção. A causa mais
  comum é `Authority` sem a barra final ou com `https://` faltando.
