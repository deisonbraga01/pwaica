Add-Type -AssemblyName System.Drawing

$imgs = "c:\wamp\www\appicamedtec\imgs"
if (-not (Test-Path $imgs)) {
    New-Item -ItemType Directory -Path $imgs | Out-Null
}

$logoPath = Join-Path $env:TEMP "ica-logo.png"
Invoke-WebRequest -Uri "https://icamedtec.com.br/wp-content/uploads/2025/12/logo-tec3-300x218.png" -OutFile $logoPath
$logo = [System.Drawing.Image]::FromFile($logoPath)

function New-PwaIcon([int]$size, [string]$output, [int]$padding) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        [System.Drawing.Color]::FromArgb(255, 15, 65, 70),
        [System.Drawing.Color]::FromArgb(255, 9, 34, 37),
        45
    )
    $g.FillRectangle($brush, $rect)

    $innerRect = [System.Drawing.Rectangle]::new(10, 10, ($size - 20), ($size - 20))
    $innerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, 31, 169, 159))
    $g.FillEllipse($innerBrush, $innerRect)

    $drawSize = $size - (2 * $padding)
    $ratio = [Math]::Min($drawSize / $logo.Width, $drawSize / $logo.Height)
    $w = [int]($logo.Width * $ratio)
    $h = [int]($logo.Height * $ratio)
    $x = [int](($size - $w) / 2)
    $y = [int](($size - $h) / 2)
    $g.DrawImage($logo, $x, $y, $w, $h)

    $bmp.Save($output, [System.Drawing.Imaging.ImageFormat]::Png)

    $brush.Dispose()
    $innerBrush.Dispose()
    $g.Dispose()
    $bmp.Dispose()
}

function New-Screenshot([int]$w, [int]$h, [string]$output, [string]$title, [string]$subtitle) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        [System.Drawing.Color]::FromArgb(255, 8, 42, 46),
        [System.Drawing.Color]::FromArgb(255, 6, 22, 24),
        90
    )
    $g.FillRectangle($bg, $rect)

    $panelW = [int]($w * 0.72)
    $panelH = [int]($h * 0.46)
    $panelX = [int](($w - $panelW) / 2)
    $panelY = [int](($h - $panelH) / 2)
    $panel = New-Object System.Drawing.Rectangle($panelX, $panelY, $panelW, $panelH)
    $panelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, 14, 53, 56))
    $g.FillRectangle($panelBrush, $panel)

    $logoW = [int]($panelW * 0.24)
    $ratio = [Math]::Min($logoW / $logo.Width, ($panelH * 0.32) / $logo.Height)
    $lw = [int]($logo.Width * $ratio)
    $lh = [int]($logo.Height * $ratio)
    $lx = $panelX + [int](($panelW - $lw) / 2)
    $ly = $panelY + 32
    $g.DrawImage($logo, $lx, $ly, $lw, $lh)

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", [float]([Math]::Max(20, [int]($w * 0.028))), [System.Drawing.FontStyle]::Bold)
    $fontSub = New-Object System.Drawing.Font("Segoe UI", [float]([Math]::Max(14, [int]($w * 0.016))), [System.Drawing.FontStyle]::Regular)
    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 228, 247, 245))

    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center

    $g.DrawString($title, $fontTitle, $textBrush, [float]($w / 2), [float]($panelY + $panelH * 0.58), $sf)
    $g.DrawString($subtitle, $fontSub, $textBrush, [float]($w / 2), [float]($panelY + $panelH * 0.73), $sf)

    $bmp.Save($output, [System.Drawing.Imaging.ImageFormat]::Png)

    $bg.Dispose()
    $panelBrush.Dispose()
    $fontTitle.Dispose()
    $fontSub.Dispose()
    $textBrush.Dispose()
    $sf.Dispose()
    $g.Dispose()
    $bmp.Dispose()
}

New-PwaIcon -size 192 -output (Join-Path $imgs "icon-192.png") -padding 22
New-PwaIcon -size 512 -output (Join-Path $imgs "icon-512.png") -padding 62
New-PwaIcon -size 512 -output (Join-Path $imgs "icon-maskable-512.png") -padding 132
New-PwaIcon -size 180 -output (Join-Path $imgs "apple-touch-icon.png") -padding 20

New-Screenshot -w 1280 -h 720 -output (Join-Path $imgs "pwa-screenshot-wide.png") -title "ICA Med Tec - Telemedicina" -subtitle "Acesso rapido por CPF e link magico"
New-Screenshot -w 720 -h 1280 -output (Join-Path $imgs "pwa-screenshot-narrow.png") -title "ICA Med Tec" -subtitle "Consulta online com seguranca"

$logo.Dispose()
Write-Host "Assets PWA gerados em $imgs"
