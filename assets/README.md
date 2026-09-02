# Imagens de branding

Imagens da marca TFTEC para o módulo 2 (Company Branding), derivadas dos arquivos oficiais de rebranding
(logo horizontal, ícone e gradiente escuro) por `tools/Import-TftecBranding.ps1`, que só redimensiona e
recorta. `tools/New-BrandingAssets.ps1` gera placeholders equivalentes para quem não tem os originais.

| Arquivo | Dimensões | Onde entra no Entra admin center | Limite |
|---------|-----------|----------------------------------|--------|
| `tftec-banner-logo.png` | 245 x 36, fundo transparente, logo colorido | `Custom Branding > Default sign-in > Edit > Sign-in form > Banner logo` | 50 KB, PNG/JPG |
| `tftec-header-logo.png` | 245 x 36, fundo transparente, logo branco | `Custom Branding > Default sign-in > Edit > Header > Header logo` (fica sobre o fundo escuro) | 50 KB, PNG/JPG |
| `tftec-square-logo.png` | 240 x 240, fundo transparente, ícone | `Custom Branding > Default sign-in > Edit > Sign-in form > Square logo (light theme)` | 50 KB, PNG/JPG |
| `tftec-background.jpg` | 1920 x 1080, gradiente escuro | `Custom Branding > Default sign-in > Edit > Basics > Background image` | 300 KB, PNG/JPG |

Dicas:

- O portal recusa o upload se o arquivo passar do limite; ele mostra o limite ao lado do campo.
- O logo de banner aparece no topo da caixa de login; o logo quadrado aparece na tela de "escolher conta" e em telas de erro.
- A imagem de fundo é cortada conforme a tela do usuário; mantenha o conteúdo importante no centro.
