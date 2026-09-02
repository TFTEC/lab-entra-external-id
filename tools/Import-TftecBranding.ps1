<#
.SYNOPSIS
    Gera os assets de branding do lab a partir dos arquivos oficiais da marca TFTEC.

.DESCRIPTION
    Lê a pasta "Rebranding TFTEC" (logos RGB em PNG e gradientes em JPG) e produz em ..\assets:
      - tftec-banner-logo.png   245 x 36, transparente  (logo horizontal principal)   -> Sign-in form > Banner logo
      - tftec-header-logo.png   245 x 36, transparente  (logo horizontal negativo)    -> Header > Header logo
      - tftec-square-logo.png   240 x 240, transparente (ícone principal)             -> Sign-in form > Square logo
      - tftec-background.jpg    1920 x 1080             (gradiente escuro, recortado)  -> Basics > Background image
    Só redimensiona e recorta; não altera cores. Use New-BrandingAssets.ps1 se não tiver os arquivos oficiais.

.EXAMPLE
    pwsh -File .\tools\Import-TftecBranding.ps1 -SourceDir "C:\...\Rebranding TFTEC"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$SourceDir,
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\assets')
)

Add-Type -AssemblyName System.Drawing

$OutputDir = (Resolve-Path -LiteralPath (New-Item -ItemType Directory -Force -Path $OutputDir)).Path
$logos = Join-Path $SourceDir '1. Logos\RGB (digital)\PNG'
$grad  = Join-Path $SourceDir '3. Gradientes\JPG'

function Get-Source([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Arquivo não encontrado: $path" }
    return [System.Drawing.Image]::FromFile($path)
}

function New-Graphics([System.Drawing.Bitmap]$bmp) {
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    return $g
}

# Encaixa a imagem dentro de w x h mantendo proporção, centralizada, fundo transparente.
function Save-Fit([System.Drawing.Image]$src, [int]$w, [int]$h, [string]$name) {
    $scale = [math]::Min($w / $src.Width, $h / $src.Height)
    $dw = [int][math]::Round($src.Width * $scale); $dh = [int][math]::Round($src.Height * $scale)
    $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = New-Graphics $bmp
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($src, [int](($w - $dw) / 2), [int](($h - $dh) / 2), $dw, $dh)
    $g.Dispose()
    $path = Join-Path $OutputDir $name
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host ("{0,-24} {1,4}x{2,-4} {3,6:N1} KB" -f $name, $w, $h, ((Get-Item $path).Length / 1KB))
}

# Preenche w x h recortando o excesso (cover), salva JPG com qualidade controlada para ficar < 300 KB.
function Save-Cover([System.Drawing.Image]$src, [int]$w, [int]$h, [string]$name, [int]$quality = 85) {
    $scale = [math]::Max($w / $src.Width, $h / $src.Height)
    $dw = [int][math]::Ceiling($src.Width * $scale); $dh = [int][math]::Ceiling($src.Height * $scale)
    $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = New-Graphics $bmp
    $g.DrawImage($src, [int](($w - $dw) / 2), [int](($h - $dh) / 2), $dw, $dh)
    $g.Dispose()
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
    $path = Join-Path $OutputDir $name
    $bmp.Save($path, $codec, $params)
    $bmp.Dispose()
    Write-Host ("{0,-24} {1,4}x{2,-4} {3,6:N1} KB" -f $name, $w, $h, ((Get-Item $path).Length / 1KB))
}

$logoPrincipal = Get-Source (Join-Path $logos 'LOGO-TFTEC-CLOUD-PRINCIPAL.png')
$logoNegativo  = Get-Source (Join-Path $logos 'LOGO-TFTEC-CLOUD-MONOCROMATICO-NEGATIVO.png')
$iconePrincipal = Get-Source (Join-Path $logos 'ICONE-TFTEC-CLOUD-PRINCIPAL.png')
$gradiente = Get-Source (Join-Path $grad 'GRADIENTE-ESCURO-TFTEC-CLOUD.jpg')

Save-Fit   $logoPrincipal 245 36  'tftec-banner-logo.png'
Save-Fit   $logoNegativo  245 36  'tftec-header-logo.png'
Save-Fit   $iconePrincipal 240 240 'tftec-square-logo.png'
Save-Cover $gradiente 1920 1080 'tftec-background.jpg'

$logoPrincipal.Dispose(); $logoNegativo.Dispose(); $iconePrincipal.Dispose(); $gradiente.Dispose()

# Remove o placeholder PNG do fundo, se existir, para não confundir.
Remove-Item -LiteralPath (Join-Path $OutputDir 'tftec-background.png') -ErrorAction SilentlyContinue
Write-Host "Assets gerados em $OutputDir"
