# Módulo 3 — Atributo customizado e fluxo de usuário

## Objetivo

Criar o atributo `Empresa` e o fluxo de usuário `SignUpSignIn`, que define como o cliente se cadastra e entra:
e-mail com senha, nome de exibição e empresa obrigatórios.

## Tempo estimado

15 minutos.

## Pré-requisitos

- Módulo 1 concluído (você está no tenant externo).

## Passos

### A. Atributo customizado

1. **Entra ID > External Identities > Overview**. Abra a aba **Custom user attributes**.
2. Clique em **+ Add**.
   - **Name**: `Empresa`
   - **Data type**: `String`
   - **Description**: `Empresa em que o cliente trabalha`
3. **Save**. O atributo aparece na lista com a origem **Custom**.

### B. Fluxo de usuário

4. **Entra ID > External Identities > User flows**. Clique em **+ New user flow**.
5. **Name**: `SignUpSignIn`.
6. **Identity providers**: em **Email Accounts**, marque **Email with password**. Deixe **Email one-time
   passcode** desmarcado: a senha é necessária para o módulo 5 (reset de senha).
7. **User attributes**: marque **Display Name**. Clique em **Show more**, marque **Empresa** na lista
   (fica junto dos atributos internos, identificado como Custom) e clique em **OK**.
8. **Create**. O fluxo aparece na lista.

### C. Layout da página de cadastro

9. Abra o fluxo `SignUpSignIn`. No menu do fluxo, em **Customize**, clique em **Page layouts**.
10. Na lista de atributos coletados:
    - **Display Name**: **Label** `Nome`, **Required** marcado.
    - **Empresa**: **Label** `Empresa`, **Required** marcado.
    - Ordem: **Nome** acima de **Empresa** (use **Move up** / **Move down**).
11. **Save**.

### D. Provedores do fluxo (só conferir)

12. No menu do fluxo, em **Settings**, clique em **Identity providers**. **Email with password** está
    selecionado. É aqui que Google e Facebook entram nos módulos bônus.

## Sobre o teste do fluxo

O botão **Run user flow** do painel do fluxo só funciona depois que um app registration é associado a ele,
o que acontece no módulo 4. O primeiro cadastro real será feito pelo app .NET.

Atributos customizados são gravados no perfil do cliente (`Entra ID > Users > cliente > Properties`). Para
que `Empresa` apareça também como claim no token, o passo extra é `App registrations > LabExternalId-Web >
Token configuration > Add optional claim > ID > Empresa`. Não faz parte do tempo do lab; fica como tarefa.

## Checkpoint

- `External Identities > User flows` lista `SignUpSignIn`.
- Em `SignUpSignIn > Customize > Page layouts`, **Nome** e **Empresa** aparecem marcados como Required.

## Se der errado

- **`Empresa` não aparece em User attributes**: você criou o atributo em outro tenant, ou não clicou em
  **Show more**. Confira em `External Identities > Overview > Custom user attributes`.
- **Não consegue desmarcar Email one-time passcode / marcar Email with password**: a escolha é feita na
  criação. Apague o fluxo e crie de novo; ainda não há app associado.
- **Nome do fluxo recusado**: use só letras e números, sem espaços.
