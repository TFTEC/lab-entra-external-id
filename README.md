# Laboratório: Microsoft Entra External ID (tenant externo)

Aula prática de 2 horas, 100% pelo portal, sem linha de comando. Cada aluno cria o próprio tenant externo
do Microsoft Entra External ID, configura branding, fluxo de usuário, reset de senha e MFA, e conecta um
app ASP.NET Core mínimo para ver o app registration funcionando: entrar, ver as claims, sair.

Público: profissionais que já conhecem Azure e Entra ID. O guia não explica conceitos básicos de Azure.

## Pré-requisitos do aluno

Traga tudo pronto antes da aula. A criação do tenant leva até 30 minutos e é feita **antes** (pré-aula).

| Item | Detalhe |
|------|---------|
| Assinatura Azure | Você precisa ser **Owner** da assinatura (cria o tenant externo, o resource group e, no módulo opcional, o App Service). |
| Tenant externo criado | Siga [docs/pre-aula.md](docs/pre-aula.md) antes da aula. |
| Visual Studio 2026 | Edição Community serve. Workload **ASP.NET e desenvolvimento web**. O app é .NET 10; o Visual Studio 2022 não compila. |
| Conta GitHub | Para clonar o repositório e, no módulo 8, criar o seu a partir deste template. |
| E-mail pessoal | Gmail, Outlook.com ou similar, diferente da conta de administrador. É a identidade do "cliente" que recebe código de MFA e link de reset. Alternativa: sufixo `+cliente` no seu e-mail, se o provedor entregar. |
| Opcional | Conta Google (bônus Google) e conta Meta for Developers (bônus Facebook). |

## Módulos

| # | Módulo | Min | Guia |
|---|--------|-----|------|
| pré | Preparação: pré-requisitos e criação do tenant externo (pré-aula) | pré-aula | [docs/pre-aula.md](docs/pre-aula.md) |
| 0 | Introdução: agenda, conceitos, External ID versus B2C, preços, arquitetura | 10 | [docs/00-introducao.md](docs/00-introducao.md) |
| 1 | Tour do tenant no Microsoft Entra admin center | 5 | [docs/01-tour-tenant.md](docs/01-tour-tenant.md) |
| 2 | Company Branding | 10 | [docs/02-branding.md](docs/02-branding.md) |
| 3 | Atributo customizado e fluxo de usuário de cadastro/entrada | 15 | [docs/03-fluxo-de-usuario.md](docs/03-fluxo-de-usuario.md) |
| 4 | App registration e app .NET: entrar, claims, sair; variação sem client secret | 30 | [docs/04-app-registration-e-app-dotnet.md](docs/04-app-registration-e-app-dotnet.md) |
| 5 | Reset de senha pelo próprio cliente | 10 | [docs/05-reset-de-senha.md](docs/05-reset-de-senha.md) |
| 6 | MFA com Conditional Access | 15 | [docs/06-mfa-conditional-access.md](docs/06-mfa-conditional-access.md) |
| 7 | Usuários, logs e encerramento | 10 | [docs/07-usuarios-logs-encerramento.md](docs/07-usuarios-logs-encerramento.md) |
| 8 | Opcional: deploy do app em Azure App Service via GitHub Actions | 15 | [docs/08-opcional-deploy-app-service.md](docs/08-opcional-deploy-app-service.md) |
| 9 | Opcional: provisionar o ambiente com GitHub Actions e Bicep (workflows prontos, secrets por repositório) | 15 + 5 | [docs/09-opcional-provisionamento-actions.md](docs/09-opcional-provisionamento-actions.md) |
| B | Bônus: Google como provedor de identidade | 20–25 | [docs/bonus-google.md](docs/bonus-google.md) |
| B | Bônus: Facebook como provedor de identidade | 30–45 | [docs/bonus-facebook.md](docs/bonus-facebook.md) |

Deu erro? [docs/troubleshooting.md](docs/troubleshooting.md). Vocabulário do lab: [CONTEXT.md](CONTEXT.md).

## O app

`src/LabExternalId.Web` é um ASP.NET Core 10 MVC com `Microsoft.Identity.Web`. Página inicial pública com
o botão **Entrar**, página **Meu perfil** protegida que lista as claims do ID token, botão **Sair**.

- Abra `LabExternalId.slnx` no Visual Studio 2026 e pressione F5. O perfil de execução usa
  `https://localhost:7100` (porta fixa, para o redirect URI do guia bater).
- Configure `src/LabExternalId.Web/appsettings.json`, seção `AzureAd`: `Authority`
  (`https://<subdominio>.ciamlogin.com/`), `ClientId` e `ClientSecret`.
- Com `ClientSecret` preenchido o app usa authorization code + PKCE. Com `ClientSecret` vazio usa o fluxo
  implícito de ID token e o app registration precisa ter **ID tokens** marcado. A página inicial mostra qual
  modo está ativo.
- No App Service as mesmas chaves entram como variáveis de ambiente `AzureAd__Authority`,
  `AzureAd__ClientId`, `AzureAd__ClientSecret`.

**Nunca faça commit do client secret.** O `appsettings.json` do repositório só tem placeholders.

## Como obter o código sem terminal

- Visual Studio 2026: tela inicial, **Clone a repository**, cole a URL do repositório, **Clone**.
- GitHub: botão **Code > Download ZIP**, extraia e abra `LabExternalId.slnx`.
- Módulo 8: botão **Use this template > Create a new repository** cria uma cópia na sua conta.

## Estrutura

```
docs/         guia do aluno, um arquivo por módulo, mais troubleshooting
instrutor/    roteiro minuto a minuto, checklist pré-aula, riscos e plano B
src/          LabExternalId.Web (ASP.NET Core 10 MVC)
assets/       imagens de branding TFTEC e onde usá-las
tools/        scripts que geram as imagens de branding
infra/        Bicep do ambiente (App Service Plan B1 Windows + Web App .NET 10) e template vazio de limpeza
.github/      workflows: CI (build e artefato), Provisionar ambiente e Desprovisionar ambiente (módulo 9)
```

## Fora do escopo, de propósito

Domínio de URL customizado (exige Azure Front Door), extensões de autenticação customizadas, autenticação
nativa, MFA por SMS (add-on pago), passkeys (exigem domínio customizado), colaboração B2B em tenant
corporativo. O módulo 7 explica o porquê de cada um.

## Referências

- [Microsoft Entra External ID: tipos de tenant](https://learn.microsoft.com/entra/external-id/tenant-configurations)
- [Criar um tenant externo](https://learn.microsoft.com/entra/external-id/customers/how-to-create-external-tenant-portal)
- [Fluxos de usuário de cadastro e entrada](https://learn.microsoft.com/entra/external-id/customers/how-to-user-flow-sign-up-sign-in-customers)
- [Reset de senha](https://learn.microsoft.com/entra/external-id/customers/how-to-enable-password-reset-customers)
- [MFA em tenant externo](https://learn.microsoft.com/entra/external-id/customers/how-to-multifactor-authentication-customers)
- [Branding](https://learn.microsoft.com/entra/external-id/customers/how-to-customize-branding-customers)
- [Recursos suportados em tenant externo](https://learn.microsoft.com/entra/external-id/customers/concept-supported-features-customers)
- [Microsoft.Identity.Web](https://github.com/AzureAD/microsoft-identity-web)
