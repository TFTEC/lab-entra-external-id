# Registro do ambiente do instrutor (montado em 2026-09-02)

Tudo o que foi criado para o instrutor durante o ensaio geral, com o **como** de cada passo, para você
auditar, repetir ou desfazer o que não acompanhou ao vivo. Nenhum segredo está neste arquivo: o client
secret do app e a senha do cliente de teste ficaram só no arquivo temporário
`%USERPROFILE%\.claude\jobs\f0410da5\tmp\graph\ids.env` (apagado junto com a sessão) e, no caso das
credenciais do GitHub Actions, nos **Secrets** do repositório. IDs de tenant, de app e nomes não são segredo.

## 1. Resumo do ambiente

| Item | Valor / estado |
|------|----------------|
| Assinatura Azure | **Microsoft - Github - 26/27** (`576a4046-3f48-40a7-95e0-b30c50d00af9`), no tenant corporativo `tftec.com.br` (`5e0359c1-7b10-463e-b064-b424568db5e9`) |
| Resource group do App Service | `rg-lab-externalid` (Brazil South). Esvaziado pelo workflow **Desprovisionar ambiente**; grupo e permissão preservados |
| Resource group do tenant | `rg-lab-externalid-tenant` (Brazil South). Guarda o recurso `Microsoft.AzureActiveDirectory/ciamDirectories` que vincula o tenant externo à assinatura |
| Tenant externo | `labextidtftec.onmicrosoft.com` (`9fc5e79e-4757-4949-9d69-f95155bf09db`), display **Lab External ID - TFTEC**, authority `https://labextidtftec.ciamlogin.com/`, país `US` (o ARM recusou `BR`; pelo portal, Brasil é aceito) |
| App registration | `LabExternalId-Web`: appId `4edc8e05-c315-4d60-85ae-2e3061e00087`, objectId `56a3bdd5-bb57-476e-a5b3-c363ab64609e`, service principal `a4868500-10e2-4976-b4d0-4c13ee32eeb6`; redirect URIs `https://localhost:7100/signin-oidc` e `/signout-callback-oidc`; front-channel logout `https://localhost:7100/signout-oidc`; ID tokens desmarcado; `openid` e `offline_access` com consentimento de admin; client secret "lab" com 90 dias (valor fora do repo) |
| Atributo customizado | `Empresa` (String), id interno `extension_dd5b577dcc9b43a897f6d4c41f4bc7f0_Empresa` |
| Fluxo de usuário | `SignUpSignIn`: Email with password; atributos Email Address, Display Name (obrigatório), Empresa (obrigatório); app `LabExternalId-Web` associado |
| Email OTP | Já vinha **habilitado para All users** no tenant novo; nada foi alterado |
| Security defaults | **Desabilitado** (motivo: "Minha organização está planejando usar o acesso condicional"), pré-requisito para Conditional Access |
| Política de Conditional Access | `MFA-LabExternalId` — estado a confirmar, ver seção 6 |
| Cliente de teste | `guilherme.campos+labcliente@tftec.com.br` (Guilherme Campos, Empresa = TFTEC), criado 21:21 UTC pelo cadastro do app; senha redefinida via "Esqueceu a senha?" (valor fora do repo) |
| Identidade do GitHub Actions | app registration `github-lab-entra-external-id` no tenant corporativo: appId `a15eb099-9bc8-427c-a064-b4f57fab48ec`, service principal `00e0d24c-23df-43cb-a214-4243391a5361`; federated credential `github-main`, subject `repo:TFTEC@198601153/lab-entra-external-id@1355151308:ref:refs/heads/main`; papel **Contributor** só em `rg-lab-externalid` |
| Resource providers registrados | `Microsoft.Web` e `Microsoft.AzureActiveDirectory` (ambos vinham `NotRegistered`) |
| GitHub: secrets | `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` |
| GitHub: variables | `AZURE_RESOURCE_GROUP=rg-lab-externalid`, `WEBAPP_NAME=lab-externalid-tftec`. **Ainda sem** `AZUREAD_AUTHORITY`, `AZUREAD_CLIENT_ID` e o secret `AZUREAD_CLIENT_SECRET` |

## 2. GitHub Actions: como foi configurado

O caminho pelo portal está em `docs/09-opcional-provisionamento-actions.md` (seções A a D). O que foi feito
de fato usou a sua sessão do Azure CLI e do `gh`, em Git Bash. Comandos, na ordem:

```bash
export MSYS_NO_PATHCONV=1   # Git Bash converte "/subscriptions/..." em caminho de arquivo; isso desliga a conversão
az account set --subscription "Microsoft - Github - 26/27"
az group create -n rg-lab-externalid -l brazilsouth --tags projeto=lab-entra-external-id gerenciadoPor=github-actions

az ad app create --display-name github-lab-entra-external-id --sign-in-audience AzureADMyOrg --query appId -o tsv
az ad sp create --id <appId> --query id -o tsv

# federated credential (arquivo fic.json)
# {"name":"github-main","issuer":"https://token.actions.githubusercontent.com",
#  "subject":"repo:TFTEC@198601153/lab-entra-external-id@1355151308:ref:refs/heads/main",
#  "audiences":["api://AzureADTokenExchange"]}
az ad app federated-credential create --id <appId> --parameters @fic.json

az role assignment create --assignee-object-id <spObjectId> --assignee-principal-type ServicePrincipal \
  --role Contributor --scope /subscriptions/576a4046-3f48-40a7-95e0-b30c50d00af9/resourceGroups/rg-lab-externalid

az provider register --namespace Microsoft.Web --wait

gh secret set AZURE_CLIENT_ID       --repo TFTEC/lab-entra-external-id --body <appId>
gh secret set AZURE_TENANT_ID       --repo TFTEC/lab-entra-external-id --body 5e0359c1-7b10-463e-b064-b424568db5e9
gh secret set AZURE_SUBSCRIPTION_ID --repo TFTEC/lab-entra-external-id --body 576a4046-3f48-40a7-95e0-b30c50d00af9
gh variable set AZURE_RESOURCE_GROUP --repo TFTEC/lab-entra-external-id --body rg-lab-externalid
gh variable set WEBAPP_NAME          --repo TFTEC/lab-entra-external-id --body lab-externalid-tftec
```

Duas falhas no caminho, já corrigidas e documentadas no módulo 9:

1. **AADSTS700213** no `azure/login`: o subject apresentado pelo GitHub agora traz os IDs numéricos
   (`repo:TFTEC@198601153/lab-entra-external-id@1355151308:ref:refs/heads/main`); a credencial criada no formato
   antigo (`repo:TFTEC/lab-entra-external-id:...`) não batia. Correção: `az ad app federated-credential update`
   com o subject exato da mensagem de erro. Os IDs também saem de `https://api.github.com/repos/TFTEC/lab-entra-external-id`.
2. **MissingSubscriptionRegistration** para `Microsoft.Web`: a assinatura nunca tinha usado App Service e
   Contributor no resource group não registra provider. Correção: `az provider register` como Owner (acima);
   o workflow agora checa isso antes de implantar e explica o caminho do portal.

Validação: run **33676043125** de *Provisionar ambiente* (verde: OIDC, Bicep B1 Windows .NET 10, publish, HTTP 200
em `lab-externalid-tftec-btavfagzcrgkcmed.brazilsouth-01.azurewebsites.net`) e run **33676814559** de
*Desprovisionar ambiente* (verde; `az resource list -g rg-lab-externalid` voltou vazio). Para rever: aba
**Actions** do repositório, filtro por workflow, ou `gh run list --repo TFTEC/lab-entra-external-id`.

## 3. Tenant externo: como foi criado

Template `infra/tenant.bicep` (opcional para o instrutor; aluno cria pelo portal, `docs/pre-aula.md`):

```bash
az provider register --namespace Microsoft.AzureActiveDirectory --wait
az group create -n rg-lab-externalid-tenant -l brazilsouth
az deployment group create --name tenant-labextidtftec -g rg-lab-externalid-tenant \
  --template-file infra/tenant.bicep \
  --parameters subdominio=labextidtftec displayName="Lab External ID - TFTEC" countryCode=US dataLocation="United States"
```

Levou cerca de 2 minutos (o portal fala em até 30). Armadilhas encontradas:

- SKU aceito só como `name: Base`, `tier: A0` (o preflight recusa `Standard`).
- O nome do recurso precisa do sufixo `.onmicrosoft.com`, apesar do aviso de tamanho do Bicep.
- `countryCode: BR` é recusado pela API ("Invalid value provided for parameter 'CountryCode'"); `US` passou.
- O app interno `b2c-extensions-app` (que guarda atributos customizados) só foi provisionado ~25 minutos depois,
  ao primeiro uso; até lá, criar atributo dava erro de serviço. Vale criar o tenant bem antes da aula.
- Quem executa a implantação (você, usuário interativo) fica como Global Administrator do tenant novo.

## 4. Configuração do tenant: Graph versus portal

**Via Microsoft Graph** (token do Azure CLI obtido com `az account get-access-token --tenant 9fc5e79e-... --resource https://graph.microsoft.com`, chamadas com `az rest`):

- `POST /v1.0/applications` com `displayName LabExternalId-Web`, `signInAudience AzureADMyOrg`, `web.redirectUris`
  (`signin-oidc`, `signout-callback-oidc`), `web.logoutUrl` (`signout-oidc`), implicit grant desligado,
  `requiredResourceAccess` Microsoft Graph `openid` (`37f7f235-...`) e `offline_access` (`7427e0e9-...`).
- `POST /v1.0/servicePrincipals` (appId do app) e `POST /v1.0/servicePrincipals` do Microsoft Graph (ainda não existia no tenant).
- `POST /v1.0/oauth2PermissionGrants` com `consentType AllPrincipals`, `scope "openid offline_access"` (= Grant admin consent).
- `POST /v1.0/applications/<objectId>/addPassword` (secret "lab", 90 dias).

**Via portal** (o que validou o guia passo a passo, no Entra admin center do tenant externo):

- Atributo `Empresa` em *Identidades Externas > Atributos de usuário personalizados* (módulo 3).
- Fluxo `SignUpSignIn` em *Fluxos dos usuários > Novo fluxo de usuário*; *Layouts de página* com Nome e Empresa
  obrigatórios; *Aplicativos > Adicionar o aplicativo* (módulos 3 e 4).
- *Padrões de segurança* desabilitado a partir do aviso do assistente de Acesso Condicional (módulo 6).
- Política `MFA-LabExternalId`: iniciada no assistente; estado final na seção 6.

Motivo da divisão: o token do Azure CLI não tem os escopos `IdentityUserFlow.ReadWrite.All`,
`Policy.ReadWrite.AuthenticationMethod`, `Policy.ReadWrite.ConditionalAccess` nem `Organization.ReadWrite.All`.
Existe um script `configure-tenant.ps1` (Graph PowerShell com login por código de dispositivo) só na pasta
temporária da sessão; ele aplica as quatro imagens e os textos do branding e pula o que já existe. Se não
for executado, o branding se faz pelo portal seguindo `docs/02-branding.md` com os arquivos de `assets/`.

## 5. Testes executados e resultados (UTC, 2026-09-02)

| Hora | Teste | Resultado |
|------|-------|-----------|
| 20:15 | Criação do tenant via ARM | Succeeded em ~2 min |
| 20:18 | App registration + SP + consentimento + secret via Graph | OK; conferido no portal (Authentication (Preview), Permissões de APIs "Concedido") |
| 20:39–20:41 | Atributo `Empresa` pelo portal | 1ª tentativa: erro de serviço (tenant novo); 2ª: criado |
| 20:45–20:55 | Fluxo `SignUpSignIn`, layouts, associação do app | OK; botão "Executar fluxo de usuário" existe |
| 21:05 | App local com tenant real | `/` 200; `/Perfil` 302 para `labextidtftec.ciamlogin.com` com `response_type=code` e PKCE |
| 21:20 | Cadastro do cliente | Código chegou em segundos no alias `+labcliente` (plus addressing funciona). Retorno ao app deu **Correlation failed** porque passaram >15 min; documentado em troubleshooting |
| 21:25 | Login + claims | "Olá, Guilherme Campos"; `/Perfil` com `name`, `oid`, `preferred_username`, `sub`, `tid` (sem `iss`/`aud`); usuário no diretório com `Empresa = TFTEC` |
| 21:27 | Sair | Tenant mostra seletor "escolha a conta para sair"; depois página "Você saiu" do app |
| 21:28–21:31 | Reset de senha | Link "Esqueceu a senha?" presente; código por e-mail; nova senha; tela "Continuar conectado?" exibiu branding do domínio `tftec.com.br` (não do tenant); app autenticado |
| 21:33 | Logs de entrada via Graph | Eventos do `LabExternalId-Web` visíveis; códigos 300004 e 50140 são interrupções esperadas (reset e "continuar conectado") |
| 20:50 | Checkpoint admin 365 | Botão "TFTEC" do cabeçalho abre *Configurações > Informações da organização*; não há seletor de diretórios e o tenant externo não aparece |

## 6. Pendências

- [ ] Confirmar o estado da política `MFA-LabExternalId` em *Acesso Condicional > Políticas* (All users menos
      o admin, recurso `LabExternalId-Web`, Grant = MFA, **Ativado**) e testar o desafio por e-mail como cliente.
- [ ] Branding do tenant: rodar o script (código de dispositivo) ou seguir `docs/02-branding.md` pelo portal.
- [ ] GitHub: variables `AZUREAD_AUTHORITY=https://labextidtftec.ciamlogin.com/`, `AZUREAD_CLIENT_ID=4edc8e05-c315-4d60-85ae-2e3061e00087`
      e secret `AZUREAD_CLIENT_SECRET`; rodar **Provisionar ambiente** para ter o app publicado (plano B da aula).
- [ ] No app registration, adicionar os redirect URIs do App Service que o Summary do run imprimir.
- [ ] No dia: tornar o repositório público; enviar aos alunos os pré-requisitos.
- [ ] Depois da aula: **Desprovisionar ambiente** (B1 é cobrado por hora).
- [ ] Quando não precisar mais: apagar o cliente de teste, o app registration e, se quiser, o tenant (seção 7).

## 7. Como desfazer tudo

1. App Service: workflow **Desprovisionar ambiente** (ou `az group delete -n rg-lab-externalid --yes`, que também
   remove a permissão da identidade do GitHub).
2. Tenant externo: no Entra admin center do tenant, apague usuários e app registrations; depois
   *Entra ID > Overview > Manage tenants*, selecione o tenant e **Delete**. Em seguida
   `az group delete -n rg-lab-externalid-tenant --yes` remove o vínculo com a assinatura.
3. Identidade do GitHub Actions: `az ad app delete --id a15eb099-9bc8-427c-a064-b4f57fab48ec` (apaga também a
   credencial federada e o service principal).
4. GitHub: *Settings > Secrets and variables > Actions*, remover `AZURE_*` e `AZUREAD_*`.
5. Local: apagar a pasta temporária `%USERPROFILE%\.claude\jobs\f0410da5` se ainda existir.

## Deploy do plano B (durante a aula, 2026-09-03 02:10 UTC)

- Tenant externo usado pelo instrutor na aula: `ciammasters` (authority `https://ciammasters.ciamlogin.com/`, app registration `cd7ba530-70ca-49ca-b668-3a0f735d5e57`), configurado nas variaveis `AZUREAD_AUTHORITY` / `AZUREAD_CLIENT_ID` e no secret `AZUREAD_CLIENT_SECRET`.
- Resource group novo `rg-lab-ciam` (brazilsouth) com Contributor para `github-lab-entra-external-id`; App Service `lab-ciam-tftec` (B1 Windows) criado em **eastus2** via variavel `AZURE_LOCATION`, porque a assinatura tem cota zero de B1 em Brazil South.
- Duas falhas antes do sucesso: `AZURE_CLIENT_ID` apontando para o app do cliente (AADSTS70025) e cota de B1; ambas documentadas em `docs/09`.
- Run verde: 33706474561. URL: `https://lab-ciam-tftec-dkcwe4bvfqfug5ed.eastus2-01.azurewebsites.net/` (HTTP 200).
- Pendente no tenant `ciammasters`: redirect URIs `/signin-oidc` e `/signout-callback-oidc` do host acima e front-channel logout `/signout-oidc`; associar o app ao fluxo. Depois da aula: **Desprovisionar ambiente** com `rg-lab-ciam` (B1 e cobrado por hora).
