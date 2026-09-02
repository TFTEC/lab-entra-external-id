# Módulo 1 — Tour do tenant externo

## Objetivo

Localizar, no Microsoft Entra admin center, cada painel que o lab vai usar. Cinco minutos para não perder
tempo procurando menu nos módulos seguintes.

## Tempo estimado

5 minutos. Quem chegou sem o tenant criado: abra o módulo 0, dispare a criação agora e acompanhe o
instrutor pelo app publicado dele (plano B) até o seu tenant ficar pronto.

## Passos

1. Abra `https://entra.microsoft.com`. Engrenagem no topo > **Directories + subscriptions** > **Switch** no
   tenant `Lab External ID - <seu nome>`. Confirme no topo da página que o nome do tenant mudou.
2. **Entra ID > Overview**: veja **Tenant type: External**, **Tenant ID** e **Primary domain**.
   Na aba **Get started** existe um assistente que cria fluxo, usuário e app automaticamente. **Não use**:
   ele cria objetos que colidem com os que você vai criar à mão.
3. Percorra os painéis abaixo só para localizar. Se algum não estiver no lugar indicado, use a caixa
   **Search** no topo do portal com o nome do painel.

| Painel | Caminho (portal em inglês) | Rótulo no portal em português | Usado no módulo |
|--------|----------------------------|-------------------------------|-----------------|
| Usuários (clientes e administradores) | `Entra ID > Users` | Usuários | 7 |
| App registrations | `Entra ID > App registrations` | Registros de aplicativo | 4 |
| Fluxos de usuário | `Entra ID > External Identities > User flows` | Identidades Externas | 3 |
| Provedores de identidade | `Entra ID > External Identities > All identity providers` | Identidades Externas | bônus |
| Atributos customizados | `Entra ID > External Identities > Custom user attributes` (seção Self-service sign up) | Identidades Externas > Atributos de usuário personalizados | 3 |
| Company Branding | `Entra ID > Custom Branding` (busque "Company branding" se não achar) | Identidade visual personalizada | 2 |
| Métodos de autenticação | `Entra ID > Authentication methods > Policies` | Métodos de autenticação | 5 |
| Conditional Access | `Entra ID > Conditional Access > Policies` | Acesso Condicional | 6 |
| Logs | `Entra ID > Monitoring & health > Sign-in logs / Audit logs / Sign-ups` | Monitoramento e integridade | 7 |

Todos são filhos diretos de **Entra ID** no menu lateral (verificado no portal em setembro de 2026).

4. Repare no que **não** existe aqui em comparação com o tenant corporativo: nenhuma licença Microsoft 365,
   nenhum Microsoft 365 admin center para este diretório, nenhum Identity Protection. O tenant externo é um
   diretório de clientes com app registrations; ele não hospeda serviços Microsoft 365.

## Vocabulário que vale fixar agora

- **Tenant externo**: este diretório. Guarda contas de clientes e os app registrations dos seus apps.
- **Tenant corporativo** (workforce): o diretório da sua empresa, com funcionários e Microsoft 365. Lá,
  "identidade externa" significa convidado B2B. Aqui, significa cliente ou provedor de identidade social.
- **Fluxo de usuário**: a experiência de cadastro e entrada (quais provedores, quais atributos, qual layout).
- **Cliente**: usuário final que se cadastra pelo app. **Administrador**: você, gerenciando o tenant.

## Checkpoint

Você consegue abrir `Entra ID > External Identities > User flows` e a lista está vazia.

## Se der errado

- **Não aparece "External Identities > User flows"**: você está no tenant corporativo. Repita o passo 1.
- **"Custom Branding" não aparece no menu**: use a busca do portal por "Company branding".
- **Portal em inglês ou português**: os caminhos deste guia usam os nomes em inglês. Para alinhar com a
  turma, mude o idioma do portal em engrenagem > **Language + region** > **English**.
