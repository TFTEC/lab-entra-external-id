# Módulo 2 — Company Branding

## Objetivo

Trocar a aparência padrão da página de login do tenant externo pela marca do lab: fundo, cores, logos e
texto. É a primeira coisa que o cliente vê e a mudança mais visível da aula.

## Tempo estimado

10 minutos. O efeito aparece no módulo 3, quando o fluxo de usuário for testado.

## Pré-requisitos

- Imagens em `assets/` do repositório: `tftec-banner-logo.png`, `tftec-header-logo.png`,
  `tftec-square-logo.png`, `tftec-background.jpg`. Baixe o repositório ou só a pasta `assets` antes de começar.

## Passos

1. **Entra ID > Custom Branding**. Se não encontrar, busque **Company branding** no topo do portal.
2. Na seção **Default sign-in experience**, clique em **Edit** (ou **Customize**, se for a primeira vez).
3. Aba **Basics**:
   - **Background image**: **Browse** e escolha `tftec-background.jpg` (limite 300 KB).
   - **Page background color**: `#0B2545` (cor de espera enquanto a imagem carrega).
   - **Next: Layout**.
4. Aba **Layout**:
   - **Visual Templates**: mantenha **Full-screen background**.
   - **Header** e **Footer**: mantenha **Show header** e **Show footer** marcados.
   - **Next: Header**.
5. Aba **Header**:
   - **Header logo**: **Browse** e escolha `tftec-header-logo.png` (versão branca, fica sobre o fundo escuro).
   - **Next: Footer**.
6. Aba **Footer**:
   - Deixe **Show 'Privacy & Cookies'** e **Show 'Terms of Use'** marcados. Não é preciso informar URL.
   - **Next: Sign-in form**.
7. Aba **Sign-in form**:
   - **Banner logo**: `tftec-banner-logo.png` (versão colorida, fica sobre a caixa branca; limite 50 KB).
   - **Square logo (light theme)**: `tftec-square-logo.png` (limite 50 KB).
   - **Username hint text**: `seu e-mail`
   - **Sign-in page text**: `Bem-vindo ao Portal do Cliente TFTEC. Entre com o e-mail cadastrado.`
   - Mantenha **Show self-service password reset** marcado. Esse é o link "Esqueceu a senha?" do módulo 5.
   - **Next: Text**.
8. Aba **Text**: nada a fazer. **Review + save** e depois **Save**.
9. Nome que aparece no cabeçalho da página neutra: busque **Tenant properties** no portal, clique em
   **Manage tenant properties** ou no lápis ao lado de **Name**, altere para `TFTEC Portal do Cliente` e
   **Save**.

## Checkpoint

A seção **Default sign-in experience** mostra as imagens carregadas e o botão vira **Edit**. A aparência
real você confere no módulo 3 com o botão **Run now** do fluxo de usuário.

## Se der errado

- **Upload recusado**: arquivo maior que o limite mostrado ao lado do campo. Os arquivos de `assets/`
  estão dentro dos limites; se você trocou pelos oficiais, reduza o tamanho.
- **A página de login continua com a aparência antiga**: propagação leva alguns minutos e o navegador
  guarda cache. Abra uma janela anônima.
- **Não achou a aba Header**: em algumas versões do portal o logo do cabeçalho fica dentro de **Layout**.
  Use o campo que se chamar **Header logo**.
