# Módulo 5 — Reset de senha pelo próprio cliente

## Objetivo

Habilitar o link "Esqueceu a senha?" na página de login e executar o reset como cliente, validando o código
por e-mail. Nenhuma linha de código no app: tudo acontece no tenant.

## Tempo estimado

10 minutos.

## Pré-requisitos

- Módulo 4 concluído: existe um cliente cadastrado com e-mail e senha.
- O fluxo `SignUpSignIn` usa **Email with password** (decidido no módulo 3). O reset só existe para contas
  com senha.

## Como funciona

O reset de senha em tenant externo depende de duas coisas: o método de autenticação **Email OTP** habilitado
para os usuários (é por ele que o cliente prova que é dono do e-mail) e o fluxo usando e-mail com senha.
O link na página de login é controlado pelo Company Branding, e já ficou marcado no módulo 2.

## Passos

### A. Habilitar o código por e-mail como método de autenticação

1. **Entra ID > Authentication methods > Policies**.
2. Na lista de métodos, localize **Email OTP**. Em tenant externo criado em 2026 ele já pode aparecer com
   **Target = All users** e **Enabled = Yes** (foi assim no tenant de validação); nesse caso só confira e siga
   para o passo 6. Se estiver **No**, clique em **Email OTP**.
3. Aba **Enable and Target**: mude **Enable** para **On**.
4. Em **Include**, mantenha **All users** (ou clique em **Add target** e escolha **All users**).
5. **Save**.

### B. Conferir o link na página de login

6. **Entra ID > Custom Branding > Default sign-in experience > Edit > Sign-in form**. Em
   **Self-service password reset**, **Show self-service password reset** deve estar marcado. Se não, marque e
   **Review + save**.

### C. Executar o reset como cliente

7. No app (F5 no Visual Studio, se não estiver rodando), se estiver autenticado clique em **Sair**.
8. Clique em **Entrar**. Informe o e-mail de teste e avance até a tela de senha.
9. Clique em **Forgot password?** (ou "Esqueceu a senha?").
10. O tenant pede o código enviado ao e-mail. Pegue na caixa de entrada e informe.
11. Defina a nova senha e conclua. O tenant entra e devolve para o app: **Olá, <nome>**.
12. Anote a nova senha para o módulo 6.

## Checkpoint

- `Authentication methods > Policies > Email OTP` mostra **Enabled** para **All users**.
- Você completou o reset e entrou no app com a senha nova.

## Se der errado

- **O link "Forgot password?" não aparece**: Email OTP ainda desabilitado (passo 3) ou a opção do branding
  desmarcada (passo 6). Propagação leva alguns minutos; teste em janela anônima.
- **Aparece o link, mas o fluxo pede código e depois erra**: a conta não tem senha (foi criada com Email
  one-time passcode). Confira em `Users > cliente > Authentication methods`. Crie outro cliente pelo fluxo
  com senha.
- **Código não chega**: pasta de spam; e-mail corporativo bloqueando. Use o e-mail pessoal.
- **Mensagem sobre SMS**: SMS é um add-on pago e não faz parte do lab. Use somente o código por e-mail.
