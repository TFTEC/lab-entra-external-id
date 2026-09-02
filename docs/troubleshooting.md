# Troubleshooting

Erros mais prováveis durante o lab, em ordem de frequência em sala. Os códigos `AADSTS` aparecem na página de
erro do próprio Entra; os `IDX` aparecem no Visual Studio (janela Output) ou na página de erro do app.

## Sequência de 30 segundos para qualquer erro de login

1. Leia o código: `AADSTS`, `IDX` ou nenhum.
2. Confira `appsettings.json`: `Authority` termina com `/`, `ClientId` é o **Application (client) ID**,
   `ClientSecret` é o **Value** (não o Secret ID).
3. Confira `App registrations > LabExternalId-Web > Authentication`: dois Redirect URIs com porta `7100`.
4. Confira `User flows > SignUpSignIn > Applications`: o app está associado.
5. Tente em janela anônima.

## Códigos e causas

| Código / sintoma | Causa | Correção |
|------------------|-------|----------|
| **AADSTS50011** `redirect URI ... does not match` | Porta diferente de 7100, ou falta o URI `/signout-callback-oidc`, ou barra final sobrando | `Properties/launchSettings.json` com `https://localhost:7100`; registre os dois URIs exatamente como no módulo 4 |
| **AADSTS700054** `response_type 'id_token' is not enabled` | App rodando sem `ClientSecret` e a caixa **ID tokens** desmarcada | Preencha o secret (fluxo code) ou marque `Authentication > Implicit grant and hybrid flows > ID tokens` |
| **AADSTS7000215** `Invalid client secret` | Colou o **Secret ID** em vez do **Value**, ou o segredo expirou | Crie outro segredo em `Certificates & secrets` e copie a coluna Value na hora |
| **AADSTS90002** `Tenant ... not found` | Subdomínio errado no `Authority` | `https://<subdominio>.ciamlogin.com/`; confira o Primary domain em `Entra ID > Overview` |
| **AADSTS65001** ou tela de consentimento que falha | Falta o **Grant admin consent** para `openid` e `offline_access` | `API permissions > Grant admin consent for <tenant>` |
| **AADSTS50020** `User account ... does not exist in tenant` | Tentou entrar com a conta administradora (tenant corporativo) no fluxo de cliente | Use o e-mail de teste; a conta admin não é cliente |
| Erro dizendo que o app não está associado a um fluxo de usuário | Passo de associação não feito | `User flows > SignUpSignIn > Applications > Add application` |
| **IDX20803** `Unable to obtain configuration from ...` | `Authority` com placeholder, erro de digitação ou sem internet | Corrija o `Authority`; a URL de metadados que o app tentou aparece no erro |
| **IDX10501 / IDX10214** (assinatura ou audience inválida) | `ClientId` não bate com o app que emitiu o token | Copie de novo o Application (client) ID |
| `ERR_CERT_AUTHORITY_INVALID` no navegador | Respondeu **No** ao pedido de confiar no certificado de desenvolvimento | Pare o app, rode F5 de novo e responda **Yes** duas vezes |
| Página do Entra sem branding | Propagação (minutos) ou cache | Aguarde e use janela anônima |
| Código de verificação não chega | Spam ou e-mail corporativo bloqueando remetente da Microsoft | Use e-mail pessoal; verifique spam; reenvie |
| Link "Forgot password?" ausente | **Email OTP** desabilitado ou opção desmarcada no branding | Módulo 5, passos 3 e 6 |
| MFA não pede código | Política em Report-only, app errado em Target resources, sessão antiga | Módulo 6; janela anônima; aguarde alguns minutos |
| Administrador travado pelo MFA | Não excluiu a própria conta da política | Entre pelo tenant corporativo, troque de diretório e edite a política |
| **Run user flow** não aparece ou não funciona | Sem app associado ao fluxo, ou botão não disponível na sua versão do portal | Associe o app; teste direto pelo app .NET |
| Visual Studio não abre `LabExternalId.slnx` ou não compila | Visual Studio 2022 (não suporta .NET 10) | Instale o Visual Studio 2026 com a workload ASP.NET |
| App Service mostra página padrão do Azure | Deploy ainda rodando ou falhou | `Deployment Center > Logs`; aba Actions no GitHub |
| App Service redireciona para login e volta com **AADSTS50011** | Redirect URIs do App Service não registrados | Adicione `https://<dominio>/signin-oidc` e `/signout-callback-oidc` no app registration |
| Deployment Center não lista a organização/repositório | GitHub App "Azure App Service" não autorizado na organização, ou repositório privado sem acesso | Autorize em GitHub `Settings > Third-party access`; use o repositório da sua conta criado por "Use this template" |
| Google: `redirect_uri_mismatch` | Faltou um dos 7 redirect URIs ou o domínio autorizado | Bônus Google, lista completa |
| Facebook: `App not active` ou login negado | App em Development mode e o usuário não é Tester | Adicione o usuário em App roles > Testers |

## Onde olhar

- **Visual Studio > Output** (Show output from: Debug ou ASP.NET Core Web Server): erros `IDX` e a URL de
  metadados usada pelo app.
- **Entra ID > Monitoring & health > Sign-in logs**: cada tentativa, com **Failure reason** em texto claro.
  Em tenant externo os logs ficam 7 dias.
- **App registration > Authentication**: a fonte da verdade para redirect URIs e a caixa **ID tokens**.
