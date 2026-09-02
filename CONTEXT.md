# Lab Entra External ID

Vocabulário do laboratório hands-on de Microsoft Entra External ID em tenant externo. Existe para que guia,
roteiro, app e conversa em sala usem a mesma palavra para a mesma coisa. Os nomes de menus do portal ficam
em inglês, como aparecem na tela.

## Language

### Diretórios

**External ID**:
O produto Microsoft Entra External ID, que existe em dois sabores: dentro do tenant corporativo (B2B) e como
tenant externo (clientes). Neste lab, sempre o segundo.
_Avoid_: Azure AD B2C, CIAM (como nome do produto), Azure AD for customers

**Tenant externo**:
Diretório separado, criado a partir de uma assinatura Azure, que guarda contas de clientes e os app
registrations dos aplicativos voltados a eles.
_Avoid_: tenant CIAM, tenant de clientes, tenant B2C, customer tenant

**Tenant corporativo**:
O diretório da empresa, com funcionários, Microsoft 365 e a assinatura Azure que paga o tenant externo.
_Avoid_: workforce tenant, tenant principal, "admin 365"

**Subdomínio**:
O nome escolhido na criação do tenant externo, que forma `<subdominio>.onmicrosoft.com` e
`<subdominio>.ciamlogin.com`. Aparece no `Authority` do app.
_Avoid_: nome do tenant, domínio primário, tenant name

### Identidades

**Cliente**:
Usuário final que se cadastra e entra pelo aplicativo. No lab, o aluno faz esse papel com um e-mail pessoal.
_Avoid_: usuário externo, identidade externa, consumidor, convidado

**Administrador**:
A conta que criou o tenant externo e o gerencia pelo Entra admin center. No lab, a conta do aluno.
_Avoid_: admin, global admin (como nome do papel na aula), dono

**Convidado B2B**:
Usuário de outra organização convidado para o tenant corporativo. Não existe neste lab; é o que "identidade
externa" significa no tenant corporativo, por isso o termo é evitado aqui.
_Avoid_: identidade externa, usuário externo

### Experiência de entrada

**Fluxo de usuário**:
Configuração da experiência de cadastro e entrada: quais provedores de identidade, quais atributos, qual
layout. O lab cria um só, chamado `SignUpSignIn`.
_Avoid_: user journey, política, policy, custom policy

**Provedor de identidade**:
Origem da autenticação aceita pelo fluxo de usuário: e-mail com senha (local), código por e-mail, Google,
Facebook.
_Avoid_: IdP social, identidade externa, federação, login social

**Atributo customizado**:
Campo extra definido pelo administrador e coletado no cadastro. O lab cria `Empresa`.
_Avoid_: extension attribute, claim customizada, propriedade

**Branding**:
Aparência da página de login do tenant externo: fundo, cores, logos, textos. Configurado em Company Branding.
_Avoid_: tema, white label, personalização visual

### Aplicativo

**App registration**:
A identidade do aplicativo no tenant externo: client ID, redirect URIs, segredos, permissões. O lab cria
`LabExternalId-Web`.
_Avoid_: aplicativo, enterprise application, service principal, registro

**Client secret**:
Credencial do app registration usada pelo app para trocar o código de autorização por tokens. Nunca vai
para o repositório.
_Avoid_: senha do app, chave, API key

**Redirect URI**:
Endereço do app para onde o tenant devolve o usuário após entrar (`/signin-oidc`) ou sair
(`/signout-callback-oidc`). Precisa bater exatamente com o registrado.
_Avoid_: callback, reply URL, URL de retorno

**Claim**:
Par nome/valor dentro do ID token que descreve o cliente autenticado (`oid`, `sub`, `preferred_username`,
`name`). A página Meu perfil do app lista todas.
_Avoid_: atributo do token, propriedade do usuário

### Segurança

**Código por e-mail**:
Código de uso único enviado ao e-mail do cliente. É o segundo fator do MFA e o meio do reset de senha neste
lab. No portal chama-se Email OTP.
_Avoid_: OTP (isolado), passcode, token por e-mail

**Reset de senha**:
O cliente troca a própria senha pelo link "Esqueceu a senha?" da página de login, validando o código por
e-mail. No portal chama-se self-service password reset.
_Avoid_: SSPR (na fala), recuperação de senha, redefinição

**MFA**:
Exigência de um segundo fator além da senha. No tenant externo é imposto por uma política de Conditional
Access; o lab cria `MFA-LabExternalId`.
_Avoid_: 2FA, dupla autenticação, verificação em duas etapas

**Conditional Access**:
Motor de políticas que decide, a cada entrada, se exige MFA, bloqueia ou libera. Em tenant externo tem um
conjunto reduzido de condições.
_Avoid_: acesso condicional (na escrita, para bater com o portal), CA policy

### Aula

**Módulo**:
Bloco do lab com objetivo, passos, checkpoint e tempo próprios. Numerados de 0 a 8, mais bônus.
_Avoid_: capítulo, etapa, exercício

**Checkpoint**:
O que o aluno deve estar vendo na tela ao terminar um módulo; a turma só avança quando todos chegam lá.
_Avoid_: validação, teste, critério de aceite

**Plano B**:
Aluno sem tenant ou sem app funcionando entra como cliente no app publicado do instrutor e acompanha os
módulos 5 e 6 por ali.
_Avoid_: fallback, contingência
