<#
.SYNOPSIS
    Gera as imagens placeholder de branding usadas no módulo 2 (Company Branding).

.DESCRIPTION
    Cria em ..\assets, com as dimensões recomendadas pelo Entra External ID:
      - tftec-banner-logo.png   245 x 36   (fundo transparente, escuro)  -> Sign-in form > Banner logo
      - tftec-header-logo.png   245 x 36   (fundo transparente, branco)  -> Header > Header logo
      - tftec-square-logo.png   240 x 240  (fundo transparente)          -> Sign-in form > Square logo
      - tftec-background.jpg    1920 x 1080                              -> Basics > Background image
    Usa apenas System.Drawing (Windows). Rode no PowerShell 7 ou 5.1:
      pwsh -File .\tools\New-BrandingAssets.ps1
    Os arquivos versionados em assets/ vieram dos originais da marca (tools/Import-TftecBranding.ps1);
    este script é a alternativa para quem não tem os originais. Mantenha nomes e dimensões.
#>
[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\assets'),
    [string]$Brand = 'TFTEC',
    [string]$Tagline = 'Lab External ID'
)

Add-Type -AssemblyName System.Drawing

$OutputDir = (Resolve-Path -LiteralPath (New-Item -ItemType Directory -Force -Path $OutputDir)).Path

$navy   = [System.Drawing.Color]::FromArgb(255, 11, 37, 69)     # #0B2545
$cyan   = [System.Drawing.Color]::FromArgb(255, 19, 164, 236)   # #13A4EC
$white  = [System.Drawing.Color]::White
$clear  = [System.Drawing.Color]::Transparent

function New-Canvas([int]$w, [int]$h, [System.Drawing.Color]$bg) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear($bg)
    return @($bmp, $g)
}

function Save-Png([System.Drawing.Bitmap]$bmp, [string]$name) {
    $path = Join-Path $OutputDir $name
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $kb = [math]::Round((Get-Item $path).Length / 1KB, 1)
    Write-Host ("{0,-26} {1,4}x{2,-4} {3,6} KB" -f $name, $bmp.Width, $bmp.Height, $kb)
}

function Save-Jpg([System.Drawing.Bitmap]$bmp, [string]$name, [int]$quality = 85) {
    $path = Join-Path $OutputDir $name
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
    $bmp.Save($path, $codec, $params)
    $kb = [math]::Round((Get-Item $path).Length / 1KB, 1)
    Write-Host ("{0,-26} {1,4}x{2,-4} {3,6} KB" -f $name, $bmp.Width, $bmp.Height, $kb)
}

function New-HorizontalLogo([System.Drawing.Color]$textColor, [string]$name) {
    $bmp, $g = New-Canvas 245 36 $clear
    $fontBrand = New-Object System.Drawing.Font('Segoe UI', 18, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $fontTag   = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $g.FillRectangle((New-Object System.Drawing.SolidBrush($cyan)), 0, 6, 6, 24)
    $g.DrawString($Brand, $fontBrand, (New-Object System.Drawing.SolidBrush($textColor)), 12, 4)
    $g.DrawString($Tagline, $fontTag, (New-Object System.Drawing.SolidBrush($textColor)), 88, 10)
    $g.Dispose(); Save-Png $bmp $name; $bmp.Dispose()
}

# 1) Banner logo (escuro, sobre a caixa branca) e header logo (branco, sobre o fundo escuro), 245x36
New-HorizontalLogo $navy  'tftec-banner-logo.png'
New-HorizontalLogo $white 'tftec-header-logo.png'

# 2) Square logo 240x240, transparente
$bmp, $g = New-Canvas 240 240 $clear
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$r = 40; $rect = New-Object System.Drawing.Rectangle(10, 10, 220, 220)
$path.AddArc($rect.X, $rect.Y, $r, $r, 180, 90)
$path.AddArc($rect.Right - $r, $rect.Y, $r, $r, 270, 90)
$path.AddArc($rect.Right - $r, $rect.Bottom - $r, $r, $r, 0, 90)
$path.AddArc($rect.X, $rect.Bottom - $r, $r, $r, 90, 90)
$path.CloseFigure()
$g.FillPath((New-Object System.Drawing.SolidBrush($navy)), $path)
$fontBig = New-Object System.Drawing.Font('Segoe UI', 64, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
$g.DrawString($Brand, $fontBig, (New-Object System.Drawing.SolidBrush($white)), (New-Object System.Drawing.RectangleF(0, 0, 240, 200)), $sf)
$g.FillRectangle((New-Object System.Drawing.SolidBrush($cyan)), 60, 170, 120, 8)
$g.Dispose(); Save-Png $bmp 'tftec-square-logo.png'; $bmp.Dispose()

# 3) Background 1920x1080 (gradiente vertical: comprime muito bem em PNG)
$bmp, $g = New-Canvas 1920 1080 $navy
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, 0)), (New-Object System.Drawing.Point(0, 1080)),
    $navy, [System.Drawing.Color]::FromArgb(255, 6, 90, 140))
$g.FillRectangle($grad, 0, 0, 1920, 1080)
$accent = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 19, 164, 236))
$g.FillEllipse($accent, 1250, -300, 1100, 1100)
$g.FillEllipse($accent, -400, 600, 900, 900)
$fontBg = New-Object System.Drawing.Font('Segoe UI', 44, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("$Brand  |  $Tagline", $fontBg, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(160, 255, 255, 255))), 80, 960)
$g.Dispose(); Save-Jpg $bmp 'tftec-background.jpg'; $bmp.Dispose()

Write-Host "Imagens geradas em $OutputDir"
