# Roteiro do instrutor — Lab Microsoft Entra External ID (2 horas)

Aula 100% hands-on, sem slides. Cada aluno trabalha no próprio tenant externo, criado antes da aula
(`docs/00-preparacao.md`). Público sênior: não explique Azure, explique External ID.

| Módulo | Início | Fim | Min | Guia do aluno |
|--------|--------|-----|-----|---------------|
| M0 Boas-vindas e conceito | 0:00 | 0:10 | 10 | — |
| M1 Tour do tenant | 0:10 | 0:15 | 5 | `docs/01-tour-tenant.md` |
| M2 Company Branding | 0:15 | 0:25 | 10 | `docs/02-branding.md` |
| M3 Atributo + fluxo de usuário | 0:25 | 0:40 | 15 | `docs/03-fluxo-de-usuario.md` |
| M4 App registration + app .NET | 0:40 | 1:10 | 30 | `docs/04-app-registration-e-app-dotnet.md` |
| M5 Reset de senha | 1:10 | 1:20 | 10 | `docs/05-reset-de-senha.md` |
| M6 MFA com Conditional Access | 1:20 | 1:35 | 15 | `docs/06-mfa-conditional-access.md` |
| M7 Usuários, logs, encerramento | 1:35 | 1:45 | 10 | `docs/07-usuarios-logs-encerramento.md` |
| Folga | 1:45 | 1:50 | 5 | — |
| **Total obrigatório** | | | **110** | |
| M8 Opcional: deploy em App Service | 1:50 | 2:05 | 15 | `docs/08-opcional-deploy-app-service.md` |

M8 só entra se sobrar tempo. Senão, vira tarefa pós-aula; a demo fica no App Service do instrutor.
Tenha o `instrutor/riscos-plano-b.md` aberto em outra aba durante a aula inteira.

---

## M0 — Boas-vindas e conceito (0:00–0:10)

**Objetivo:** alinhar o que é tenant externo, confirmar pré-requisitos e disparar a criação para quem chegou sem tenant.

**O instrutor fala (5 min):**
- Microsoft Entra External ID tem dois sabores. **Tenant corporativo (workforce)** com B2B: convidados de outras organizações entram no *seu* diretório, colaboração, acesso entre tenants. **Tenant externo (CIAM)**: diretório separado, só para clientes, com fluxos de cadastro/entrada, branding próprio, IdPs sociais. Hoje é só o segundo.
- Tenant externo é o sucessor do Azure AD B2C, fechado para novos clientes desde maio de 2025. Quem tem B2C continua suportado até pelo menos 2030, mas projeto novo nasce em External ID.
- O termo "identidade externa" muda de sentido conforme o tenant: no corporativo é convidado; no externo é conta de cliente ou provedor social. Nesta aula usamos **cliente** e **provedor de identidade** para não confundir.
- Console é o **Entra admin center** (`entra.microsoft.com`). O **Microsoft 365 admin center não entra**: tenant externo não tem superfície de administração lá, não tem SSO para M365 e add-ons pagos são comprados no tenant corporativo. Portal do Azure só aparece no M8 para o App Service.
- O app .NET existe para mostrar o que o app registration faz. Não é aula de .NET.

**O aluno faz (5 min):** confere pré-requisitos (Visual Studio 2026 aberto, tenant externo criado, e-mail pessoal acessível). Quem não criou o tenant começa agora por `docs/00-preparacao.md` e acompanha os módulos 2 a 7 como cliente no app do instrutor (plano B) até o tenant ficar pronto.

**Checkpoint coletivo:** "Todo mundo consegue abrir `entra.microsoft.com` e alternar para o tenant externo?"

**Armadilhas:** aluno logado no tenant corporativo sem perceber; criação de tenant que ainda está provisionando (até 30 min).

---

## M1 — Tour do tenant (0:10–0:15)

**Objetivo:** localizar em 5 minutos os seis menus que a aula usa.

**O instrutor fala:**
- `Entra ID > External Identities` (fluxos, provedores, atributos customizados), `Users`, `App registrations`, `Custom Branding`, `Authentication methods`, `Conditional Access`, `Monitoring & health`.
- O guia "Get started" em `Overview > Get started` cria fluxo, usuário e app sozinho. **Não usar**: ele esconde exatamente os passos da aula e cria objetos que colidem com os nossos.
- Retenção de logs em tenant externo é de 7 dias; tudo que fizermos hoje aparece em `Sign-in logs`, `Audit logs` e `Sign-ups (preview)`.

**Checkpoint do admin 365 (instrutor, 1 min):** abra `admin.microsoft.com` com a conta que criou o tenant externo e verifique se ele aparece no seletor de organizações. Registre o resultado aqui na primeira turma e ajuste a fala de M0 se aparecer:

> Resultado observado em ____/____/____: [ ] aparece [ ] não aparece. Observação: ______________________

**O aluno faz:** `docs/01-tour-tenant.md`.

**Checkpoint coletivo:** "Todo mundo achou `External Identities > User flows` vazio?"

**Armadilhas:** menu lateral recolhido esconde `External Identities`; busca global do portal resolve.

---

## M2 — Company Branding (0:15–0:25)

**Objetivo:** aplicar logo, fundo e cores da TFTEC à página de login antes de existir qualquer fluxo.

**O instrutor fala:**
- Branding é por tenant e vale para todos os fluxos; é o primeiro impacto visual e custa 10 minutos.
- Imagens estão em `assets/` com as dimensões certas (banner 245x36, quadrado 240x240, fundo 1920x1080). Não perca tempo procurando arquivo.
- Idioma da página segue o navegador; personalização por idioma existe em `Browser language customizations`, fora do escopo.
- Domínio customizado (`login.suaempresa.com`) exige Azure Front Door e assinatura; fica fora.

**O aluno faz:** `docs/02-branding.md` até `Review + save`.

**Checkpoint coletivo:** "Salvou sem erro de tamanho de imagem?" Ninguém vê o resultado ainda; aparece no M4, no primeiro **Entrar** do app (ou no **Run user flow**, depois que o app estiver associado ao fluxo).

**Armadilhas:** upload de PNG acima do limite falha em silêncio parcial; nome do tenant só muda em `Tenant properties`.

---

## M3 — Atributo customizado + fluxo de usuário (0:25–0:40)

**Objetivo:** criar o atributo `Empresa` e o fluxo `SignUpSignIn` com e-mail e senha, pronto para receber o app no M4.

**O instrutor fala:**
- Atributo customizado vem **antes** do fluxo; senão ele não aparece na lista de atributos.
- Fluxo = provedores + atributos coletados + layout da página. Um fluxo serve vários apps; um app só tem um fluxo.
- Escolha **Email with password** (não Email OTP como primeiro fator): é o que habilita reset de senha no M5.
- `Customize > Page layouts` é onde `Empresa` vira obrigatório e ganha rótulo em português.
- O botão **Run user flow** do painel do fluxo só funciona depois que um app registration é associado, o que acontece no M4. Não perca tempo com ele agora; o branding do M2 aparece no primeiro **Entrar** do app.
- Atributo customizado fica gravado no perfil do cliente; virar claim no token é um passo extra em `Token configuration`, fora do tempo da aula.

**O aluno faz:** `docs/03-fluxo-de-usuario.md`. Ainda **não** se cadastra: o cadastro real é no M4, pelo app.

**Checkpoint coletivo:** "Todo mundo tem `SignUpSignIn` na lista e `Empresa` marcado como Required em Page layouts?"

**Armadilhas:** atributo criado depois do fluxo exige editar o fluxo em `User attributes`; quem marcou Email one-time passcode em vez de Email with password precisa recriar o fluxo (a escolha é feita na criação).

---

## M4 — App registration + app .NET (0:40–1:10)

**Objetivo:** registrar `LabExternalId-Web`, rodar o app no Visual Studio, cadastrar-se como cliente, ver claims, sair.

**O instrutor fala (demonstra primeiro, aluno acompanha):**
- App registration é a identidade do app no tenant: Client ID, redirect URIs, credenciais, permissões. Em tenant externo é sempre single tenant.
- **Dois** redirect URIs (`/signin-oidc` e `/signout-callback-oidc`) mais o **Front-channel logout URL** (`/signout-oidc`). Sem o segundo, o Sair termina numa página genérica da Microsoft e nunca volta ao app.
- Consentimento: em tenant externo só administrador consente; `Grant admin consent` é obrigatório para `openid` e `offline_access`.
- Client secret é copiado uma vez só; vai no `appsettings.json` local e **nunca** no repositório.
- Associar o app ao fluxo `SignUpSignIn` em `User flows > Applications`; sem isso o login dá erro de app não associado.
- No Visual Studio 2026: `Clone a repository`, editar `appsettings.json` (Authority `https://<subdominio>.ciamlogin.com/`, ClientId, ClientSecret), F5, "Trust ASP.NET Core SSL Certificate?" → **Sim, duas vezes**.
- Cadastro com o e-mail pessoal: código por e-mail chega, `Empresa` é obrigatório, `/Perfil` mostra `oid`, `sub`, `preferred_username`, `name`. Sair volta para "Você saiu".

**Variação sem secret (últimos 5 min):**
1. Apague o valor de `ClientSecret` no `appsettings.json`, F5, clique Entrar → **AADSTS700054** ("response_type 'id_token' is not enabled").
2. `App registrations > LabExternalId-Web > Authentication (Preview) > aba Settings > Implicit grant and hybrid flows > ID tokens` → Save.
3. F5 de novo → funciona. A faixa na página inicial muda de "Authorization code + PKCE" para "ID token (fluxo implícito)".
4. Fale o trade-off: menos passos, mas fluxo legado e não é o caminho documentado; o app decide sozinho pela presença do secret.

**O aluno faz:** `docs/04-app-registration-e-app-dotnet.md` inteiro.

**Checkpoint coletivo:** "Todo mundo chegou em `/Perfil` com o próprio e-mail em `preferred_username`?" Este é o checkpoint mais importante da aula; não avance com menos de 80% da sala.

**Armadilhas:** porta diferente de 7100 (aluno mudou `launchSettings.json`) → AADSTS50011; Authority com placeholder → IDX20803; certificado recusado → `ERR_CERT_AUTHORITY_INVALID`; secret colado com espaço. Veja `riscos-plano-b.md`.

---

## M5 — Reset de senha (1:10–1:20)

**Objetivo:** habilitar o método Email OTP e testar "Esqueceu a senha?" com o cliente criado no M4.

**O instrutor fala:**
- Reset de senha em tenant externo **não** é um IdP; é o método de autenticação **Email OTP** habilitado em `Authentication methods > Policies` para todos os usuários, combinado com um fluxo que usa e-mail e senha.
- O link "Esqueceu a senha?" aparece sozinho; a visibilidade é controlada em `Custom Branding > Sign-in form > Self-service password reset`.
- SMS também serve, mas é add-on pago com assinatura vinculada; hoje só e-mail.

**O aluno faz:** `docs/05-reset-de-senha.md`; faz o reset no próprio app (Sair, Entrar, "Esqueceu a senha?", código no e-mail pessoal, nova senha, login).

**Checkpoint coletivo:** "Todo mundo conseguiu entrar com a senha nova?"

**Armadilhas:** código no spam; política de método salva mas leva um minuto para valer; aluno testando com a conta de administrador em vez do cliente.

---

## M6 — MFA com Conditional Access (1:20–1:35)

**Objetivo:** exigir segundo fator por código por e-mail para clientes do app, sem travar o administrador.

**O instrutor fala:**
- Único segundo fator gratuito em tenant externo é **Email OTP**. SMS é pago; passkey exige domínio customizado; Microsoft Authenticator não é suportado para clientes.
- Conditional Access em tenant externo é reduzido de propósito: usuários com exclusões, recursos, condições de plataforma e localização, concessão de bloquear/MFA/reset. Sem Security defaults documentado.
- **Exclua a conta do administrador** da política `MFA-LabExternalId` e mire só no recurso `LabExternalId-Web`. "All users" sem exclusão inclui o admin, que é convidado no tenant externo e não tem Authenticator disponível: você se tranca fora.
- Política nova pega na próxima emissão de token: Sair e Entrar de novo.

**O aluno faz:** `docs/06-mfa-conditional-access.md`.

**Checkpoint coletivo:** "Todo mundo recebeu o código por e-mail no segundo login? Alguém travou a conta admin?"

**Armadilhas:** política em `Report-only` em vez de `On`; recurso errado selecionado; sessão antiga ainda válida (precisa Sair).

---

## M7 — Usuários, logs e encerramento (1:35–1:45)

**Objetivo:** mostrar o lado administrativo do que foi feito e fechar a aula.

**O instrutor fala:**
- `Entra ID > Users`: o cliente criado no M4, com `Empresa` em Properties; `New user > Create new external user` cria cliente pelo admin; reset e delete (30 dias de restauração).
- `Monitoring & health > Sign-in logs` (o login com MFA), `Audit logs` (política criada), `Sign-ups (preview)` (funil de cadastro, exclusivo de tenant externo). Retenção de 7 dias; exportar exige Azure Monitor.
- **O que construímos:** tenant externo, branding, atributo, fluxo, app registration, app .NET com login/logout, reset, MFA.
- **O que ficou de fora e por quê:** domínio customizado (Azure Front Door, assinatura, DNS); extensões de autenticação customizadas (evento externo, código); autenticação nativa (UI no app, só contas locais); SMS (add-on pago); passkey (exige domínio customizado); Google e Facebook (bônus em `docs/bonus-*.md`, 20 a 45 min cada).
- Limpeza opcional: desativar a política, apagar o app, apagar o tenant. Quem for fazer o M8 mantém tudo.

**O aluno faz:** `docs/07-usuarios-logs-encerramento.md`.

**Checkpoint coletivo:** "Todo mundo achou o próprio login com MFA em Sign-in logs?"

**Armadilhas:** logs demoram alguns minutos para aparecer; filtro de data padrão pode esconder o evento.

---

## Folga (1:45–1:50)

Use para quem ficou para trás no M4 ou M6. Se a sala inteira está em dia, entre no M8.

---

## M8 — Opcional: deploy em App Service (1:50–2:05)

**Objetivo:** cada aluno publica o próprio app no Azure via GitHub Actions configurado pelo Deployment Center, sem CLI.

**O instrutor fala (demonstra no próprio App Service já publicado):**
- Repositório da TFTEC é template: `Use this template` cria o repo do aluno em três cliques.
- Web App: Publish Code, runtime **.NET 10 (LTS)**, **Windows**, plano **Basic B1**. Windows porque o wizard já configura GitHub e o IIS trata os cabeçalhos de proxy; B1 porque F1 tem cota de CPU e cold start.
- Hostname padrão tem hash único: copiar `Default domain` do Overview, nunca adivinhar.
- `Deployment Center` com **User-assigned identity**: o portal cria identidade, credencial federada, secrets no GitHub e commita o workflow. Basic auth vem desabilitado em app novo, então é o único caminho sem CLI. Exige Owner na assinatura.
- Configuração em `Environment variables > App settings` com `AzureAd__Authority`, `AzureAd__ClientId`, `AzureAd__ClientSecret`; no app registration, dois redirect URIs novos com o hostname do App Service.
- B1 é cobrado por hora: apagar o resource group ao terminar.

**O aluno faz:** `docs/08-opcional-deploy-app-service.md`. Quem não terminar em 15 min continua em casa; o guia é autossuficiente.

**Checkpoint coletivo:** "Alguém já viu a página inicial do app no `azurewebsites.net`?"

**Armadilhas:** Actions ainda rodando (3 a 6 min) e o aluno vê a página padrão do App Service; autorização do GitHub falhando por política de OAuth da organização; App Service Linux escolhido por engano.
