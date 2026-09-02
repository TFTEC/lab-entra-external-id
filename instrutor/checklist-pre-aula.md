# Checklist pré-aula (rodar 1 a 2 dias antes)

Objetivo: chegar na aula com o lab validado de ponta a ponta no seu próprio tenant, o App Service do
instrutor no ar (plano B dos alunos) e o repositório pronto para a turma. Marque cada item.

## 1. Máquina do instrutor

- [ ] Instalar **Visual Studio 2026 Community** com a workload **"ASP.NET e desenvolvimento web"**, se ainda não tiver. O aluno vai usar exatamente esse caminho, então valide por ele e não pelo VS Code ou pela CLI.
- [ ] Clonar o repositório pelo Visual Studio (`Clone a repository`), abrir `LabExternalId.slnx`, apertar F5 e aceitar o certificado ("Sim" duas vezes). A página inicial deve abrir em `https://localhost:7100` com o aviso "Configuração pendente".
- [ ] Ter um e-mail pessoal (Gmail/Outlook.com) aberto em outra aba para o papel de cliente.

## 2. Tenant externo do instrutor

- [ ] Criar o tenant externo seguindo `docs/00-preparacao.md` (pode levar até 30 min). País/região não muda depois.
- [ ] Rodar `docs/01` a `docs/07` inteiros no próprio tenant. Marcar cada verificação abaixo conforme acontece:
  - [ ] **Admin 365:** abrir `admin.microsoft.com` e anotar no `roteiro.md` (M1) se o tenant externo aparece no seletor de organizações.
  - [ ] O botão **Run now** (ou `Run user flow`) existe no painel do fluxo `SignUpSignIn`. Se o nome for outro, corrigir `docs/03`.
  - [ ] Company Branding aceita os 4 arquivos de `assets/` (3 PNG e 1 JPG) sem erro de tamanho.
  - [ ] Cadastro pelo app exige `Empresa`; código por e-mail chega em menos de 1 minuto na caixa pessoal (conferir spam).
  - [ ] `/Perfil` mostra `oid`, `sub`, `preferred_username`, `name`.
  - [ ] **Sair** volta para a página "Você saiu" do app (prova que o segundo redirect URI `/signout-callback-oidc` está certo).
  - [ ] Sem `ClientSecret` e sem "ID tokens" marcado → erro **AADSTS700054**; com a caixa marcada → login funciona e a faixa da página inicial muda para "ID token".
  - [ ] Link "Esqueceu a senha?" visível; reset completa; login com a senha nova funciona.
  - [ ] Política `MFA-LabExternalId` pede código por e-mail ao cliente **e não trava a conta do administrador** (admin excluído da política; recurso = `LabExternalId-Web`).
  - [ ] `Sign-in logs`, `Audit logs` e `Sign-ups (preview)` mostram os eventos (podem levar alguns minutos).
- [ ] Anotar em `docs/troubleshooting.md` qualquer erro novo que apareceu e como resolveu.

## 3. Repositório GitHub (organização TFTEC)

- [ ] Em `github.com/organizations/TFTEC/settings/oauth_application_policy` (Settings > Third-party access), aprovar o GitHub App **"Azure App Service"** quando o Deployment Center pedir autorização; sem isso o portal não lista os repositórios da organização.
- [ ] Confirmar que **Template repository** está marcado em `Settings > General`. É o que permite `Use this template` no M8.
- [ ] Confirmar que a Action de CI está verde em `Actions` e que o artefato `LabExternalId.Web` é baixável.
- [ ] Opcional: substituir os PNGs placeholder em `assets/` pelos oficiais da TFTEC, mantendo nomes e dimensões (245x36, 240x240, 1920x1080). Commitar pela interface web ou pelo Visual Studio.
- [ ] **No dia da aula, antes de começar:** tornar o repositório público em `Settings > General > Danger Zone > Change visibility > Make public`. Alunos não são membros da organização e precisam clonar sem convite. Ter um ZIP do repositório baixado como reserva (`Code > Download ZIP`).

## 4. App Service do instrutor (demo e plano B)

- [ ] Criar o app registration `LabExternalId-Web` no tenant do instrutor (já feito na seção 2) e anotar Client ID e um client secret dedicado ao App Service.
- [ ] **Caminho rápido (recomendado para o instrutor):** fazer o setup único de `docs/09-opcional-provisionamento-actions.md` (resource group, identidade do GitHub com credencial federada, Contributor no grupo, secrets no repositório da TFTEC) e rodar **Actions > Provisionar ambiente**. Ele cria o B1 Windows, publica o app e imprime os redirect URIs; pule para o item dos redirect URIs abaixo. Ao final da aula, **Actions > Desprovisionar ambiente**.
- [ ] **Caminho pelo portal (o mesmo do aluno no M8):** `portal.azure.com > App Services > Create > Web App`: Publish **Code**, Runtime **.NET 10 (LTS)** (confirmar que aparece no dropdown), OS **Windows**, região próxima, plano **Basic B1**.
- [ ] Copiar o **Default domain** do Overview (tem hash único, ex.: `nome-abc123.brazilsouth-01.azurewebsites.net`).
- [ ] `Deployment Center > Settings`: Source **GitHub**, autorizar, Organization **TFTEC**, Repository `lab-entra-external-id`, Branch `main`, Authentication type **User-assigned identity**, Save. Confirmar que o workflow foi commitado em `.github/workflows/` e rodou verde (3 a 6 min).
- [ ] `Settings > Environment variables > App settings`: `AzureAd__Authority` = `https://<subdominio>.ciamlogin.com/`, `AzureAd__ClientId`, `AzureAd__ClientSecret`. Apply e reiniciar.
- [ ] No app registration do instrutor, `Authentication (Preview) > Redirect URI configuration > + Add a redirect URI`: adicionar `https://<default-domain>/signin-oidc` e `https://<default-domain>/signout-callback-oidc`; na aba Settings, o Front-channel logout URL pode continuar o de localhost ou ganhar o do App Service.
- [ ] Abrir o app publicado, cadastrar um cliente, entrar, ver `/Perfil`, sair. Este endereço é o **plano B** para aluno sem tenant ou sem Visual Studio 2026: guardar a URL para colar no chat da aula.
- [ ] Anotar o custo: B1 Windows é cobrado por hora. **Apagar o resource group depois da aula.**

## 5. Comunicação com a turma (enviar com antecedência)

- [ ] Pré-requisitos obrigatórios: assinatura Azure própria com papel **Owner**; **tenant externo já criado** seguindo `docs/00-preparacao.md` (até 30 min de provisionamento, por isso é pré-aula); **Visual Studio 2026** (Community serve) com workload "ASP.NET e desenvolvimento web"; conta **GitHub**; um **e-mail pessoal** acessível durante a aula para o papel de cliente.
- [ ] Opcionais, só para os bônus: conta Google (`bonus-google.md`), conta Meta for Developers com verificação por telefone (`bonus-facebook.md`).
- [ ] Avisar explicitamente: **Visual Studio 2022 não compila .NET 10**. Quem só tiver 2022 acompanha pelo plano B.
- [ ] Link do repositório (será público no dia) e horário.

## 6. Última hora (dia da aula)

- [ ] Repositório público (seção 3).
- [ ] App Service do instrutor respondendo (abrir a URL; B1 não tem cold start, mas confirme).
- [ ] `roteiro.md` e `riscos-plano-b.md` abertos em abas separadas.
- [ ] Tenant do instrutor com a política `MFA-LabExternalId` **desativada** até o M6, para a demo do M4 não pedir MFA antes da hora.
