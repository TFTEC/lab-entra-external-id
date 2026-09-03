# Módulo 9 (opcional) — Provisionar o ambiente com GitHub Actions e Bicep

## Objetivo

Criar o App Service do lab e publicar o `LabExternalId.Web` nele com um clique na aba **Actions**, em vez
de montar tudo pelo portal como no módulo 8. Serve para o aluno, no repositório criado pelo template, e para
o instrutor, no repositório da TFTEC: cada um com o próprio conjunto de secrets e a própria assinatura.

## Tempo estimado

15 minutos de setup único pelo portal, depois 5 minutos por execução.

## Pré-requisitos

- Módulos 3 e 4 concluídos (fluxo `SignUpSignIn` e app registration `LabExternalId-Web` no tenant externo).
- Seu repositório no GitHub: **Use this template > Create a new repository** a partir do repositório do lab
  (o instrutor usa o repositório da TFTEC diretamente).
- Papel **Owner** na assinatura, só para o setup único (criar o resource group e dar permissão à identidade
  do GitHub). O workflow em si recebe apenas **Contributor no resource group**.

## O que os workflows fazem

| Workflow (aba Actions) | Arquivo | O que faz |
|------------------------|---------|-----------|
| **Provisionar ambiente** | `.github/workflows/provision.yml` | Login no Azure por OIDC, implanta `infra/main.bicep` (App Service Plan **Basic B1 Windows** + Web App **.NET 10**, HTTPS only, app settings `AzureAd__*`), publica o app e imprime no Summary os redirect URIs a registrar. Idempotente: rodar de novo atualiza. |
| **Desprovisionar ambiente** | `.github/workflows/deprovision.yml` | Remove tudo do resource group (modo Complete de `infra/empty.bicep`), preservando o grupo e a permissão. Exige digitar o nome do grupo. |

Login por **OIDC com credencial federada**: nenhuma senha do Azure fica no GitHub. O único segredo de
verdade é o client secret do app registration do tenant externo, e ele é opcional.

Custo: B1 Windows é cobrado por hora (ordem de US$ 55 por mês ligado). Desprovisione ao terminar.

## Passos

### A. Setup único: resource group

1. `https://portal.azure.com` > **Resource groups > + Create**.
2. **Subscription**: a sua. **Resource group**: `rg-lab-externalid`. **Region**: `Brazil South`.
3. **Review + create > Create**.
4. Anote o **Subscription ID** (menu **Subscriptions**, coluna Subscription ID).
   Ainda em **Subscriptions > sua assinatura > Settings > Resource providers**, procure `Microsoft.Web`; se o
   status for **NotRegistered**, selecione e clique em **Register**. Assinaturas que nunca tiveram App Service
   vêm assim, e a identidade do workflow (Contributor só no resource group) não consegue registrar sozinha.

### B. Setup único: identidade do GitHub no Entra

Feito no **tenant corporativo** onde está a assinatura, não no tenant externo do lab.

5. `https://entra.microsoft.com` > confirme o diretório no topo > **Entra ID > App registrations > + New registration**.
   - **Name**: `github-lab-entra-external-id`
   - **Supported account types**: Accounts in this organizational directory only
   - Sem redirect URI. **Register**.
6. Em **Overview**, anote **Application (client) ID** e **Directory (tenant) ID**.
7. Descubra o **subject** exato que o GitHub apresenta para o seu repositório. Desde 2026 o GitHub inclui os
   IDs numéricos do dono e do repositório no subject, no formato
   `repo:<conta>@<id-da-conta>/<repositorio>@<id-do-repositorio>:ref:refs/heads/main`, e o assistente do Entra
   ainda gera o formato antigo, sem IDs. Para obter os dois números, abra no navegador
   `https://api.github.com/repos/<conta>/<repositorio>` e anote `"id"` (do repositório, no topo) e
   `"owner": { "id" }` (da conta). Monte o subject, por exemplo:
   `repo:TFTEC@198601153/lab-entra-external-id@1355151308:ref:refs/heads/main`.
8. **Certificates & secrets > Federated credentials > + Add credential**:
   - **Federated credential scenario**: `Other issuer`
   - **Issuer**: `https://token.actions.githubusercontent.com`
   - **Subject identifier**: o subject montado no passo 7
   - **Name**: `github-main`
   - **Audience**: mantenha `api://AzureADTokenExchange`
   - **Add**. O workflow só autentica quando executado a partir da branch `main`.
   Se preferir o cenário `GitHub Actions deploying Azure resources` (Organization, Repository, Entity type
   Branch `main`), confira depois de salvar se o **Subject identifier** ficou igual ao do passo 7; se não, edite
   a credencial e cole o valor correto. Se errar, o primeiro run falha com **AADSTS700213** mostrando o subject
   exato apresentado; copie dali.
   Não crie client secret neste app: a credencial federada substitui a senha.

### C. Setup único: permissão no resource group

9. `https://portal.azure.com` > **Resource groups > rg-lab-externalid > Access control (IAM) > + Add > Add role assignment**.
10. Aba **Privileged administrator roles** > **Contributor** > **Next**.
11. **Assign access to**: `User, group, or service principal` > **+ Select members** > procure
    `github-lab-entra-external-id` > **Select** > **Review + assign** (duas vezes).

### D. Setup único: secrets e variáveis no seu repositório

12. GitHub > seu repositório > **Settings > Secrets and variables > Actions**.
13. Aba **Secrets > New repository secret**, um por vez:

    | Secret | Valor |
    |--------|-------|
    | `AZURE_CLIENT_ID` | Application (client) ID do passo 6 |
    | `AZURE_TENANT_ID` | Directory (tenant) ID do passo 6 |
    | `AZURE_SUBSCRIPTION_ID` | Subscription ID do passo 4 |
    | `AZUREAD_CLIENT_SECRET` | opcional: client secret do app registration `LabExternalId-Web` **do tenant externo** (módulo 4). Sem ele, o app publicado roda sem secret e o app registration precisa de **ID tokens** marcado |

14. Aba **Variables > New repository variable**, opcionais (evitam digitar a cada execução):

    | Variável | Valor |
    |----------|-------|
    | `AZURE_RESOURCE_GROUP` | `rg-lab-externalid` |
    | `WEBAPP_NAME` | nome único do Web App, por exemplo `lab-externalid-<seu-nome>` |
    | `AZUREAD_AUTHORITY` | `https://<subdominio>.ciamlogin.com/` do seu tenant externo |
    | `AZUREAD_CLIENT_ID` | Client ID do app registration `LabExternalId-Web` |

### E. Executar

15. Aba **Actions**. Se o GitHub perguntar se você quer habilitar workflows no repositório criado do template,
    clique em **I understand my workflows, go ahead and enable them**.
16. **Provisionar ambiente > Run workflow**, branch `main`. Preencha os campos ou deixe em branco para usar as
    variáveis. **Run workflow**.
17. Ao terminar (4 a 6 min), abra o run e leia o **Summary**: URL do app e os três valores a registrar.
18. No tenant externo: **Entra ID > App registrations > LabExternalId-Web > Authentication (Preview)**:
    - Aba **Redirect URI configuration > + Add a redirect URI** (Web): `https://<host>/signin-oidc`
    - Idem: `https://<host>/signout-callback-oidc`
    - Aba **Settings > Front-channel logout URL**: `https://<host>/signout-oidc`
    - **Save**. O `<host>` tem um sufixo único gerado pelo Azure; copie do Summary.
19. Abra a URL do app, **Entrar**, entre como cliente, **Meu perfil**, **Sair**.

### F. Desprovisionar

20. **Actions > Desprovisionar ambiente > Run workflow**, digite o nome do resource group no campo de confirmação.
    O Web App e o plano somem; grupo, identidade e permissão ficam para a próxima vez. O workflow se recusa a
    rodar se o grupo contiver um recurso de diretório (o vínculo do tenant externo), por isso o tenant fica em
    `rg-lab-externalid-tenant` (pré-aula) e o App Service em `rg-lab-externalid`.

## Checkpoint

- Run verde de **Provisionar ambiente** com o Summary mostrando a URL e os redirect URIs.
- Login e logout funcionam no endereço `azurewebsites.net`, com as mesmas claims do `localhost`.
- **Desprovisionar ambiente** executado ao final (ou anotado para depois).

## Se der errado

- **`AADSTS700213` ou `AADSTS70021: No matching federated identity record found for presented assertion
  subject '...'`**: o subject da credencial federada não é idêntico ao apresentado. A mensagem traz o subject
  exato (com os IDs numéricos); edite a credencial `github-main` e cole esse valor no **Subject identifier**.
  Também acontece se o workflow rodou fora da branch `main`. Confira os passos 7 e 8.
- **`AADSTS70025: The client '...'(LabExternalId-Web) has no configured federated identity credentials`**:
  o secret `AZURE_CLIENT_ID` recebeu o Client ID do app do cliente (`LabExternalId-Web`, tenant externo) em vez
  do app `github-lab-entra-external-id` (tenant corporativo, passo 6). São dois app registrations com papéis
  diferentes: `AZURE_*` = identidade do GitHub no Azure; `AZUREAD_*` = app do cliente no tenant externo.
- **`AuthorizationFailed`**: Contributor não atribuído no resource group, ou `AZURE_SUBSCRIPTION_ID` de outra
  assinatura. Confira os passos 4 e 9 a 11.
- **`MissingSubscriptionRegistration` para `Microsoft.Web`**: registre o resource provider na assinatura
  (passo 4) e rode de novo.
- **`ResourceGroupNotFound`**: o grupo não existe nessa assinatura ou o nome difere do informado.
- **Nome do Web App em uso**: o nome é global; troque `WEBAPP_NAME`.
- **Quota de VMs Basic na região**: crie o resource group em outra região (por exemplo `East US 2`) e rode de novo.
- **Deploy falha por autenticação básica desabilitada**: o `azure/webapps-deploy@v3` publica pela sessão do
  `azure/login`, sem publish profile; confira se o job **Publicar o app** fez login antes do deploy.
- **App mostra "Configuração pendente"**: `AZUREAD_AUTHORITY` e `AZUREAD_CLIENT_ID` (ou os inputs) vazios.

## Por que o workflow não cria nem configura o tenant externo

Criar o tenant por ARM é possível, mas leva até 30 minutos, o tenant nasce criado por uma identidade de
serviço, e a pré-aula já cobre a criação pelo portal. Configurar o tenant (fluxo, atributo, branding, MFA)
por Microsoft Graph exigiria outra identidade dentro do tenant externo e duplicaria em código o que o lab
ensina à mão. Fica como evolução separada, se um dia valer a pena.
