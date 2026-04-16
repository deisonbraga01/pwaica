param(
    [string]$Url = "https://icamedtec.com.br/app/"
)

$ErrorActionPreference = "Stop"

function Get-EdgePath {
    $cmd = Get-Command "msedge.exe" -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) { return $cmd.Source }

    $candidates = @(
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    throw "Microsoft Edge (msedge.exe) não encontrado."
}

$baseDir = "c:\wamp\www\appicamedtec"
$outDir = Join-Path $baseDir "imgs\store\playstore"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$edge = Get-EdgePath

$targets = @(
    @{ w = 1080; h = 1920; name = "phone-1080x1920.png" },
    @{ w = 1920; h = 1080; name = "phone-1920x1080.png" },
    @{ w = 1200; h = 1920; name = "tablet-1200x1920.png" },
    @{ w = 1920; h = 1200; name = "tablet-1920x1200.png" }
)

foreach ($t in $targets) {
    $outPath = Join-Path $outDir $t.name
    Write-Host ("Capturando " + $t.name + "...")

    $args = @(
        "--headless",
        "--disable-gpu",
        "--hide-scrollbars",
        "--force-device-scale-factor=1",
        ("--window-size=" + $t.w + "," + $t.h),
        ("--virtual-time-budget=" + 6000),
        ("--screenshot=" + $outPath),
        $Url
    )

    & $edge @args | Out-Null

    if (-not (Test-Path $outPath)) { throw "Falhou ao gerar $($t.name)." }
    if ((Get-Item $outPath).Length -lt 1024) { throw "Arquivo $($t.name) parece inválido." }
}

# Feature graphic 1024x500 (recortado do landscape 1920x1080)
Add-Type -AssemblyName System.Drawing
$landscape = Join-Path $outDir "phone-1920x1080.png"
$featureOut = Join-Path $outDir "feature-graphic-1024x500.png"
if (Test-Path $landscape) {
    $img = [System.Drawing.Image]::FromFile($landscape)
    $targetW = 1024
    $targetH = 500
    $targetRatio = $targetW / $targetH

    $cropW = $img.Width
    $cropH = [int]([Math]::Round($cropW / $targetRatio))
    if ($cropH -gt $img.Height) {
        $cropH = $img.Height
        $cropW = [int]([Math]::Round($cropH * $targetRatio))
    }

    $cropX = [int](($img.Width - $cropW) / 2)
    $cropY = [int](($img.Height - $cropH) / 2)

    $bmp = New-Object System.Drawing.Bitmap($targetW, $targetH)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $g.DrawImage(
        $img,
        [System.Drawing.Rectangle]::new(0, 0, $targetW, $targetH),
        [System.Drawing.Rectangle]::new($cropX, $cropY, $cropW, $cropH),
        [System.Drawing.GraphicsUnit]::Pixel
    )

    $bmp.Save($featureOut, [System.Drawing.Imaging.ImageFormat]::Png)

    $g.Dispose()
    $bmp.Dispose()
    $img.Dispose()
}

# Copia do ícone 512x512 para facilitar upload no Play Console
$iconSrc = Join-Path $baseDir "imgs\\icon-512.png"
$iconOut = Join-Path $outDir "playstore-icon-512.png"
if (Test-Path $iconSrc) {
    $icon = [System.Drawing.Image]::FromFile($iconSrc)
    $icon.Save($iconOut, [System.Drawing.Imaging.ImageFormat]::Png)
    $icon.Dispose()
}

Write-Host "Concluído. Assets em $outDir"

