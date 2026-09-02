# Riscos e plano B

Mantenha este arquivo aberto durante a aula. Cada linha traz o sinal que o aluno vê, o que fazer em
menos de 2 minutos e, quando a correção não cabe no tempo, o plano B.

## Plano B padrão

Aluno que não consegue seguir no próprio ambiente (tenant não criado, Visual Studio 2022, máquina travada)
**entra como cliente no App Service do instrutor**: cadastra-se com o e-mail pessoal, vê `/Perfil`, sai,
faz o reset de senha (M5) e recebe o desafio de MFA (M6) como cliente. Ele perde o lado administrador
desses módulos, mas vê toda a experiência do cliente e pode refazer o lab em casa com o guia. A URL do
App Service do instrutor fica no `checklist-pre-aula.md`, seção 4.

## Tabela de riscos

| # | Risco | Sinal | Mitigação rápida | Plano B |
|---|-------|-------|------------------|---------|
| 1 | Tenant externo do aluno não criado ou ainda provisionando | `Manage tenants` mostra o tenant com status de criação; alternar diretório falha | Criar agora (`docs/00`); provisionamento leva até 30 min | Plano B padrão até o tenant ficar pronto; aluno retoma no módulo em que a sala estiver |
| 2 | Aluno só tem **Visual Studio 2022** | Erro ao abrir o projeto: SDK .NET 10 não suportado / `global.json` não resolvido | Nenhuma em sala: VS 2022 não compila .NET 10 | Plano B padrão. O ZIP do CI **não** resolve: rodar o binário exige runtime .NET 10 instalado e certificado dev confiável, e nenhum dos dois se instala sem SDK ou Visual Studio |
| 3 | Código por e-mail não chega | Cadastro, reset ou MFA param na tela do código | Conferir spam/lixo eletrônico; aguardar 1 min; reenviar código; caixa corporativa pode bloquear remetente da Microsoft | Usar outro e-mail pessoal ou sufixo `+` (`aluno+lab@gmail.com`) |
| 4 | **AADSTS50011** redirect URI mismatch | Página do Entra com o erro, mostrando a URI que o app enviou | Comparar a URI do erro com `Authentication > Web > Redirect URIs`. Causas: porta diferente de 7100 (aluno alterou `launchSettings.json`), falta do segundo URI `/signout-callback-oidc` (erro aparece no Sair), URI do App Service não cadastrada (M8) | Adicionar a URI exatamente como aparece no erro e tentar de novo; não precisa reiniciar o app |
| 5 | **AADSTS700054** response_type id_token not enabled | Erro ao clicar Entrar | Esperado na variação sem secret. Fora dela: `ClientSecret` vazio ou com espaço no `appsettings.json` → preencher e F5; ou marcar `Authentication > Implicit grant > ID tokens` | Seguir sem secret com "ID tokens" marcado; a faixa da página inicial confirma o modo |
| 6 | **IDX20803** não conseguiu obter metadados | Exceção no F5 ou ao clicar Entrar, no console do Visual Studio | Authority com placeholder `SEU-SUBDOMINIO` ou erro de digitação. Formato: `https://<subdominio>.ciamlogin.com/` com barra final; subdomínio é o começo do domínio `.onmicrosoft.com` do tenant | Copiar o subdomínio de `Overview > Domain name` e colar |
| 7 | Certificado de desenvolvimento recusado | Navegador mostra `ERR_CERT_AUTHORITY_INVALID` em `localhost:7100` | Aluno clicou "Não" no prompt do Visual Studio. Fechar, apagar `bin/` e `obj/` não ajuda; no VS: `Debug > LabExternalId.Web Debug Properties`, desmarcar e marcar "Enable SSL", F5 e aceitar | Clicar "Avançado > Continuar" no navegador; o login funciona mesmo com aviso |
| 8 | Conditional Access travou o administrador | Admin não consegue entrar no Entra admin center do tenant externo ou recebe pedido de MFA sem método disponível | Política `MFA-LabExternalId` deve ter o admin em **Exclude** e recurso = `LabExternalId-Web`. Se travou: entrar pelo tenant corporativo (conta original), alternar diretório; se não der, usar outra conta de administrador do tenant | Instrutor desativa a política do aluno se tiver acesso; senão, aluno segue no plano B e conserta em casa com a conta original |
| 9 | Botão **Run now** não aparece no fluxo | Painel do fluxo `SignUpSignIn` sem o botão | Nome pode ser `Run user flow`; ou o botão só aparece após salvar o fluxo. Recarregar a página | Pular o teste sem app; o cadastro real acontece no M4 pelo app e mostra o mesmo branding |
| 10 | Aluno se cadastrou com o e-mail do administrador | Erro de conta existente ou o cliente "vira" o admin | Cliente precisa de e-mail diferente da conta admin | Usar e-mail pessoal ou sufixo `+` |
| 11 | Deployment Center não lista o repositório | Após autorizar o GitHub, Organization/Repository vazios | Para repo na organização TFTEC: aprovar o GitHub App "Azure App Service" em Settings > Third-party access da org. Para repo do aluno (template): conferir se autorizou a conta certa | Aluno cria o repo pelo `Use this template` na própria conta (fora da org) e repete a autorização |
| 12 | Deployment Center falha ao salvar com identidade gerenciada | Erro de permissão ao criar identidade ou atribuição de papel | Exige **Owner** ou User Access Administrator na assinatura; Contributor não basta | Instrutor faz a demo no próprio App Service; aluno termina em casa após ajustar o papel |
| 13 | App Service mostra a página padrão do Azure | "Your web app is running and waiting for your content" | Deploy ainda rodando: abrir `Actions` no repo do aluno, esperar 3 a 6 min; ou o workflow falhou (checar log) | Recarregar depois; se o workflow falhou por runtime, conferir que o Web App é **.NET 10 (LTS)** e **Windows** |
| 14 | App publicado abre mas login falha | AADSTS50011 com hostname do App Service | Redirect URIs do App Service não cadastradas; copiar `Default domain` (tem hash) do Overview e adicionar `/signin-oidc` e `/signout-callback-oidc` | Testar com o localhost enquanto ajusta |
| 15 | App publicado não lê configuração | Página inicial com "Configuração pendente" no App Service | `Environment variables > App settings` com chaves `AzureAd__Authority`, `AzureAd__ClientId`, `AzureAd__ClientSecret` (dois sublinhados); Apply e reiniciar | — |
| 16 | Google: tela "app não verificado" ou acesso negado | Login com Google bloqueado para o aluno | Tela de consentimento em modo **Testing** exige o e-mail do aluno em **Test users** | Adicionar o e-mail e tentar de novo; bônus é pós-aula |
| 17 | Facebook: "app em modo de desenvolvimento" | Login com Facebook recusa contas comuns | App Meta em Development mode só aceita quem tem papel no app: adicionar o aluno como **Tester** em `App roles` | Manter em Development mode; não tentar publicar o app em sala (exige verificação de negócio e política de privacidade) |
| 18 | Tempo estourando no M4 | Menos de 80% da sala em `/Perfil` aos 1:10 | Usar a folga (5 min) agora; adiar a variação sem secret para o fim | Cortar M8; se necessário, encurtar M7 para 5 min (só Users e Sign-in logs) |
| 19 | Logs não mostram o evento | `Sign-in logs` vazio para o cliente | Atraso de alguns minutos; ampliar o filtro de data; conferir que está no tenant externo, não no corporativo | Mostrar os logs do instrutor no projetor |
| 20 | Repositório ainda privado no dia | Aluno recebe 404 no GitHub | `Settings > General > Danger Zone > Change visibility > Make public` | Distribuir o ZIP baixado na véspera; abrir a solução direto no Visual Studio |

## Sequência de diagnóstico para erro de login (30 segundos)

1. Leia o código `AADSTS` na página do Entra: 50011 é URI, 700054 é response_type, "application not associated" é fluxo sem app.
2. Se não há página do Entra e o app quebra no F5, é configuração local: Authority (IDX20803), certificado (ERR_CERT), porta.
3. Se o login passa e `/Perfil` está vazio ou o Sair não volta, é redirect URI faltando ou `Grant admin consent` não concedido.
4. Se nada disso resolve em 2 minutos, plano B padrão e segue a sala.
