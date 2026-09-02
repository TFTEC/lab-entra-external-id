# Pré-aula — Preparação do ambiente (antes da aula)

## Objetivo

Chegar na aula com o tenant externo criado, o Visual Studio 2026 instalado e um e-mail de teste separado.
A criação do tenant leva até 30 minutos, por isso é feita antes. A aula em si começa pelo
[módulo 0, Introdução](00-introducao.md).

## Tempo estimado

30 a 45 minutos, a maior parte de espera.

## Pré-requisitos

- Conta que seja **Owner** de uma assinatura Azure. O papel mínimo para criar tenant externo é
  Tenant Creator na assinatura ou no resource group; Owner já inclui.
- Um e-mail pessoal (Gmail, Outlook.com) para o papel de cliente, diferente da conta acima.
- Conta GitHub.

## Passos

### 1. Instalar o Visual Studio 2026

1. Baixe o **Visual Studio 2026 Community** em `https://visualstudio.microsoft.com/`.
2. No instalador, marque a workload **ASP.NET e desenvolvimento web**. Ela traz o SDK do .NET 10.
3. Abra o Visual Studio uma vez e entre com qualquer conta Microsoft para ativar a licença Community.

O Visual Studio 2022 não serve: ele não compila projetos .NET 10.

### 2. Criar o tenant externo

1. Abra `https://entra.microsoft.com` e entre com a conta que é Owner da assinatura.
2. No menu esquerdo: **Entra ID > Overview**. No topo da página, **Manage tenants**.
3. Clique em **Create**.
4. Em "Select a tenant type", escolha **External** e clique em **Continue**.
   Se o portal oferecer um trial gratuito de 30 dias, recuse e escolha a opção de usar uma assinatura Azure.
   O trial é apagado ao fim do período e não serve para este lab.
5. Aba **Basics**:
   - **Tenant name**: `Lab External ID - <seu nome>`
   - **Domain name**: `labextid<iniciais><4 dígitos>` (só letras minúsculas e números; exemplo `labextidgc2026`).
     Esse valor vira o seu **subdomínio**: `<subdominio>.onmicrosoft.com` e `<subdominio>.ciamlogin.com`.
     Anote, ele é usado em todos os módulos.
   - **Country/Region**: `Brazil`. Não pode ser alterado depois.
   - **Next: Add a subscription**.
6. Aba **Add a subscription**:
   - **Subscription**: a sua.
   - **Resource group**: **Create new** com o nome `rg-lab-externalid-tenant`. Use um grupo só para o tenant:
     os módulos 8 e 9 usam `rg-lab-externalid` para o App Service e o esvaziam ao final, e o vínculo do tenant
     com a assinatura não pode estar lá.
   - **Resource group location**: `Brazil South`.
   - **Next: Review + create**.
7. Confira e clique em **Create**. O portal avisa que pode levar até 30 minutos. Pode fechar a aba.

### 3. Entrar no tenant externo e anotar os identificadores

1. Volte a `https://entra.microsoft.com`. Clique no ícone de **engrenagem** no topo, depois em
   **Directories + subscriptions**.
2. Localize o tenant `Lab External ID - <seu nome>` e clique em **Switch**.
3. Em **Entra ID > Overview**, aba **Overview**, anote:
   - **Tenant ID** (GUID)
   - **Primary domain** (`<subdominio>.onmicrosoft.com`)
   - O tipo do tenant aparece como **External**.

### 4. Separar o e-mail de teste

Escolha o e-mail que será o "cliente" durante a aula. Ele precisa ser lido em outra aba do navegador ou no
celular, porque recebe código de verificação no cadastro, código de MFA e link de reset de senha.

- Recomendado: Gmail ou Outlook.com pessoal.
- Alternativa: `seunome+cliente@empresa.com`, se o seu provedor entregar endereços com `+`.
- Não use o e-mail da conta administradora: ela já existe no tenant e o cadastro como cliente entra em conflito.

## Checkpoint

- No Entra admin center, com o tenant externo selecionado, o menu **Entra ID > External Identities** mostra
  **User flows** e **All identity providers**.
- Você anotou: subdomínio, Tenant ID e o e-mail de teste.

## Se der errado

- **"You don't have permission to create a tenant"**: a conta não é Owner nem Tenant Creator na assinatura.
  Peça o papel ou use outra assinatura.
- **Domain name já em uso**: troque os dígitos finais. O nome é global.
- **O tenant não aparece em Directories + subscriptions após 30 minutos**: saia e entre de novo no portal.
  Se persistir, abra `Entra ID > Overview > Manage tenants` na conta original e verifique o status.
- **O portal só oferece o trial**: a assinatura não está visível para a conta logada. Confira em
  `https://portal.azure.com` > Subscriptions se ela aparece; se não, entre com a conta certa.
- **Erro ao criar atributo ou fluxo nos primeiros minutos após a criação** ("Há um problema com o
  serviço... aguarde alguns minutos"): o tenant ainda está provisionando componentes internos. Observado até
  20 minutos após a criação. Mais um motivo para criar o tenant na véspera.
