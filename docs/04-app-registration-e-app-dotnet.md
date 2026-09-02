# Módulo 4 — App registration e app .NET

## Objetivo

Registrar o aplicativo no tenant externo, associá-lo ao fluxo de usuário e rodar o app ASP.NET Core para
ver o ciclo completo: cadastro, entrada, claims e saída. No fim, uma variação de 5 minutos mostra o mesmo
app funcionando sem client secret.

## Tempo estimado

30 minutos (20 com secret, 5 de variação sem secret, 5 de folga).

## Pré-requisitos

- Módulo 3 concluído.
- Visual Studio 2026 instalado com a workload ASP.NET e desenvolvimento web.
- Anotados: subdomínio do tenant e e-mail de teste.

## Passos

### A. Registrar o aplicativo

1. **Entra ID > App registrations > + New registration**.
2. **Name**: `LabExternalId-Web`.
3. **Supported account types**: em tenant externo só existe a opção de contas deste diretório; mantenha.
4. **Redirect URI**: plataforma **Web**, valor `https://localhost:7100/signin-oidc`.
5. **Register**. Na página **Overview**, copie o **Application (client) ID**.

### B. Redirect URIs, logout e segredo

6. Menu do app: **Authentication**.
   - Em **Web > Redirect URIs**, clique em **Add URI** e informe `https://localhost:7100/signout-callback-oidc`.
     É para onde o tenant devolve o navegador depois do logout; sem ela, a página "Você saiu" não aparece.
   - **Front-channel logout URL**: `https://localhost:7100/signout-oidc`.
   - Em **Implicit grant and hybrid flows**, deixe **ID tokens** desmarcado por enquanto.
   - **Save**.
7. Menu do app: **Certificates & secrets > Client secrets > + New client secret**.
   - **Description**: `lab`
   - **Expires**: `90 days`
   - **Add**. Copie a coluna **Value** agora. Ela não é mostrada de novo. Não confunda com **Secret ID**.
8. Menu do app: **API permissions > + Add a permission > Microsoft Graph > Delegated permissions**.
   Marque **openid** e **offline_access** e clique em **Add permissions**.
   Clique em **Grant admin consent for <nome do tenant>** e confirme com **Yes**. A coluna Status fica verde.
   Em tenant externo o cliente não consegue consentir sozinho; sem este passo o login falha.

### C. Associar ao fluxo de usuário

9. **Entra ID > External Identities > User flows > SignUpSignIn**. No menu do fluxo, em **Use**, clique em
   **Applications > + Add application**. Selecione **LabExternalId-Web** e clique em **Select**.
   Um app só pode estar em um fluxo; um fluxo atende vários apps.
10. Opcional, 1 minuto: no painel do fluxo, **Run user flow**, escolha **LabExternalId-Web** e a reply URL
    `https://localhost:7100/signin-oidc`, clique em **Run user flow**. Abre a página de login com o branding
    do módulo 2. Só olhe e feche: o app ainda não está rodando para receber o retorno.

### D. Rodar o app .NET

11. Visual Studio 2026, tela inicial: **Clone a repository**. Cole a URL deste repositório, **Clone**.
    A solução `LabExternalId.slnx` abre sozinha.
12. No Solution Explorer, abra `src/LabExternalId.Web/appsettings.json` e preencha a seção `AzureAd`:
    - `"Authority": "https://<subdominio>.ciamlogin.com/"` (com a barra final)
    - `"ClientId": "<Application (client) ID copiado no passo 5>"`
    - `"ClientSecret": "<Value copiado no passo 7>"`
    Salve com Ctrl+S.
13. Pressione **F5**. Na primeira vez o Visual Studio pergunta **Trust ASP.NET Core SSL Certificate?**:
    responda **Yes** e, no aviso de segurança do Windows, **Yes** de novo.
14. O navegador abre `https://localhost:7100`. A página inicial mostra o cartão **Como este app está
    configurado** com o seu Authority, o Client ID e o fluxo **Authorization code + PKCE (com client secret)**.
    Se houver um aviso amarelo de configuração pendente, volte ao passo 12.

### E. Cadastro, entrada, claims e saída

15. Clique em **Entrar**. Observe a URL: começa com `https://<subdominio>.ciamlogin.com/`. A página traz
    o fundo, o logo e o texto do módulo 2.
16. Clique em **No account? Create one** (ou "Não tem conta? Crie uma").
    - E-mail: o seu **e-mail de teste**. Clique em **Send verification code**, pegue o código na caixa de
      entrada e informe.
    - Senha: crie uma senha. Anote, ela é usada nos módulos 5 e 6.
    - **Nome** e **Empresa**: preencha. Os dois são obrigatórios por causa do módulo 3.
    - Conclua. O navegador volta para o app com **Olá, <nome>** no topo.
17. Clique em **Meu perfil**. A tabela lista as claims do ID token. Localize:
    - `oid`: o ID do cliente no diretório.
    - `preferred_username`: o e-mail de teste.
    - `name`: o nome informado.
    - `iss`: `https://<tenant-id>.ciamlogin.com/<tenant-id>/v2.0`.
    - `aud`: o Client ID do app.
18. Clique em **Sair**. O app encerra a sessão local, avisa o tenant e mostra a página **Você saiu**.
19. Clique em **Entrar** de novo. O tenant pede as credenciais outra vez: a sessão do tenant também acabou.
    Entre e confirme que **Meu perfil** volta a funcionar.

### F. Variação: sem client secret (5 minutos)

20. Pare o app (Shift+F5). Em `appsettings.json`, deixe `"ClientSecret": ""`. Salve e pressione F5.
21. A página inicial agora mostra **ID token (fluxo implícito, sem client secret)**. Clique em **Entrar**.
    O tenant responde com o erro **AADSTS700054**: `response_type 'id_token' is not enabled for the application`.
22. No portal: **App registrations > LabExternalId-Web > Authentication > Implicit grant and hybrid flows**,
    marque **ID tokens (used for implicit and hybrid flows)** e **Save**.
23. Volte ao app, clique em **Entrar** de novo. Funciona. **Meu perfil** mostra as mesmas claims. A diferença
    está no que o app não recebeu: sem código de autorização, sem refresh token, sem como chamar APIs depois.
24. Restaure para os próximos módulos: coloque o secret de volta em `appsettings.json` e salve. Pode deixar
    **ID tokens** marcado; não atrapalha.

## Checkpoint

- `App registrations > LabExternalId-Web > Authentication` tem dois Redirect URIs e o Front-channel logout URL.
- `User flows > SignUpSignIn > Applications` lista `LabExternalId-Web`.
- No app: cadastro concluído, **Meu perfil** com `oid`, `preferred_username`, `name`; **Sair** leva a "Você saiu".
- Você viu o AADSTS700054 e o corrigiu marcando **ID tokens**.

## Se der errado

- **AADSTS50011 (redirect URI mismatch)**: o app está em outra porta (confira `Properties/launchSettings.json`:
  `https://localhost:7100`) ou falta uma das duas URIs no portal. Copie e cole; sem barra final.
- **AADSTS7000215 (invalid client secret)**: foi colado o **Secret ID** em vez do **Value**, ou o valor
  expirou. Crie outro segredo.
- **AADSTS90002 (tenant not found)** ou erro **IDX20803** no Visual Studio: `Authority` errado. Formato
  exato: `https://<subdominio>.ciamlogin.com/`.
- **Erro dizendo que o aplicativo não está associado a um fluxo de usuário**: passo 9 não foi feito.
- **Pedido de consentimento ou erro de permissão ao entrar**: passo 8 (Grant admin consent) não foi feito.
- **Navegador reclama do certificado (ERR_CERT_AUTHORITY_INVALID)**: você respondeu **No** no passo 13.
  Feche o app, no Visual Studio vá em **Tools > Options > Projects and Solutions > Web Projects** ou apenas
  rode F5 de novo e aceite quando perguntar.
- **Código de verificação não chega**: confira a pasta de spam; e-mail corporativo costuma bloquear.
  Use um e-mail pessoal.
