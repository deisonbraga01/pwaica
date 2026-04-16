Add-Type -AssemblyName System.Drawing

$baseDir = "c:\wamp\www\appicamedtec"
$outDir = Join-Path $baseDir "imgs\store\playstore"
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

$logoPath = Join-Path $env:TEMP "ica-logo.png"
Invoke-WebRequest -Uri "https://icamedtec.com.br/wp-content/uploads/2025/12/logo-tec3-300x218.png" -OutFile $logoPath
$logo = [System.Drawing.Image]::FromFile($logoPath)

function New-MockScreen([int]$w, [int]$h, [string]$outputPath, [string]$headline) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $rect = [System.Drawing.Rectangle]::new(0, 0, $w, $h)
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        [System.Drawing.Color]::FromArgb(255, 16, 63, 68),
        [System.Drawing.Color]::FromArgb(255, 6, 21, 25),
        90
    )
    $g.FillRectangle($bg, $rect)

    # Card central
    $panelW = [int]($w * 0.78)
    $panelH = [int]($h * 0.52)
    $panelX = [int](($w - $panelW) / 2)
    $panelY = [int](($h - $panelH) / 2)

    $panelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(205, 10, 32, 35))
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 30, 155, 146), 2)
    $radius = [int]([Math]::Max(18, [int]($w * 0.02)))

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($panelX, $panelY, $radius, $radius, 180, 90) | Out-Null
    $path.AddArc($panelX + $panelW - $radius, $panelY, $radius, $radius, 270, 90) | Out-Null
    $path.AddArc($panelX + $panelW - $radius, $panelY + $panelH - $radius, $radius, $radius, 0, 90) | Out-Null
    $path.AddArc($panelX, $panelY + $panelH - $radius, $radius, $radius, 90, 90) | Out-Null
    $path.CloseFigure()
    $g.FillPath($panelBrush, $path)
    $g.DrawPath($borderPen, $path)

    # Logo
    $logoMaxW = [int]($panelW * 0.28)
    $logoMaxH = [int]($panelH * 0.18)
    $ratio = [Math]::Min($logoMaxW / $logo.Width, $logoMaxH / $logo.Height)
    $lw = [int]($logo.Width * $ratio)
    $lh = [int]($logo.Height * $ratio)
    $lx = $panelX + [int](($panelW - $lw) / 2)
    $ly = $panelY + [int]($panelH * 0.10)
    $g.DrawImage($logo, $lx, $ly, $lw, $lh)

    # Fonts/brushes
    $titleSize = [float]([Math]::Max(26, [int]($w * 0.032)))
    $subSize = [float]([Math]::Max(18, [int]($w * 0.018)))
    $smallSize = [float]([Math]::Max(16, [int]($w * 0.015)))

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", $titleSize, [System.Drawing.FontStyle]::Bold)
    $fontSub = New-Object System.Drawing.Font("Segoe UI", $subSize, [System.Drawing.FontStyle]::Regular)
    $fontSmall = New-Object System.Drawing.Font("Segoe UI", $smallSize, [System.Drawing.FontStyle]::Regular)

    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(242, 228, 247, 245))
    $mutedBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, 155, 194, 191))

    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center

    $g.DrawString($headline, $fontTitle, $textBrush, [float]($w / 2), [float]($panelY + $panelH * 0.34), $sf)
    $g.DrawString("Acesso do paciente por CPF e link mágico", $fontSub, $mutedBrush, [float]($w / 2), [float]($panelY + $panelH * 0.45), $sf)

    # Campo
    $fieldW = [int]($panelW * 0.78)
    $fieldH = [int]([Math]::Max(62, [int]($h * 0.035)))
    $fieldX = $panelX + [int](($panelW - $fieldW) / 2)
    $fieldY = $panelY + [int]($panelH * 0.60)
    $fieldRect = [System.Drawing.Rectangle]::new($fieldX, $fieldY, $fieldW, $fieldH)

    $fieldBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 6, 25, 27))
    $fieldPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(110, 80, 153, 148), 2)
    $g.FillRectangle($fieldBrush, $fieldRect)
    $g.DrawRectangle($fieldPen, $fieldRect)
    $g.DrawString("000.000.000-00", $fontSmall, $mutedBrush, [float]($fieldX + 22), [float]($fieldY + ($fieldH * 0.22)))

    # Botão
    $btnW = [int]($fieldW * 0.78)
    $btnH = [int]([Math]::Max(64, [int]($h * 0.04)))
    $btnX = $panelX + [int](($panelW - $btnW) / 2)
    $btnY = $fieldY + $fieldH + [int]([Math]::Max(24, $h * 0.02))
    $btnRect = [System.Drawing.Rectangle]::new($btnX, $btnY, $btnW, $btnH)
    $btnBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $btnRect,
        [System.Drawing.Color]::FromArgb(255, 31, 173, 159),
        [System.Drawing.Color]::FromArgb(255, 15, 122, 115),
        0
    )
    $g.FillRectangle($btnBrush, $btnRect)
    $g.DrawString("Receber link mágico", $fontSub, $textBrush, [float]($w / 2), [float]($btnY + ($btnH * 0.22)), $sf)

    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    $bg.Dispose()
    $panelBrush.Dispose()
    $borderPen.Dispose()
    $path.Dispose()
    $fontTitle.Dispose()
    $fontSub.Dispose()
    $fontSmall.Dispose()
    $textBrush.Dispose()
    $mutedBrush.Dispose()
    $sf.Dispose()
    $fieldBrush.Dispose()
    $fieldPen.Dispose()
    $btnBrush.Dispose()
    $g.Dispose()
    $bmp.Dispose()
}

function New-FeatureGraphic([string]$outputPath) {
    $w = 1024
    $h = 500
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $rect = [System.Drawing.Rectangle]::new(0, 0, $w, $h)
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        [System.Drawing.Color]::FromArgb(255, 12, 48, 52),
        [System.Drawing.Color]::FromArgb(255, 6, 21, 25),
        0
    )
    $g.FillRectangle($bg, $rect)

    # Logo à esquerda
    $logoMaxW = 360
    $logoMaxH = 180
    $ratio = [Math]::Min($logoMaxW / $logo.Width, $logoMaxH / $logo.Height)
    $lw = [int]($logo.Width * $ratio)
    $lh = [int]($logo.Height * $ratio)
    $lx = 80
    $ly = [int](($h - $lh) / 2)
    $g.DrawImage($logo, $lx, $ly, $lw, $lh)

    # Textos à direita
    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 44, [System.Drawing.FontStyle]::Bold)
    $fontSub = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Regular)
    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(242, 228, 247, 245))
    $mutedBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, 155, 194, 191))

    $g.DrawString("ICA Med Tec", $fontTitle, $textBrush, 480, 170)
    $g.DrawString("Telemedicina • Acesso por CPF", $fontSub, $mutedBrush, 480, 245)

    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    $bg.Dispose()
    $fontTitle.Dispose()
    $fontSub.Dispose()
    $textBrush.Dispose()
    $mutedBrush.Dispose()
    $g.Dispose()
    $bmp.Dispose()
}

# Play Store costuma aceitar qualquer tamanho dentro da faixa; aqui uso tamanhos comuns.
$targets = @(
    @{ w = 1080; h = 1920; name = "phone-1080x1920.png"; headline = "Acesso rápido à telemedicina" },
    @{ w = 1920; h = 1080; name = "phone-1920x1080.png"; headline = "Consulta online com segurança" },
    @{ w = 1200; h = 1920; name = "tablet-1200x1920.png"; headline = "Experiência otimizada" },
    @{ w = 1920; h = 1200; name = "tablet-1920x1200.png"; headline = "Telemedicina em qualquer tela" }
)

foreach ($t in $targets) {
    $out = Join-Path $outDir $t.name
    Write-Host ("Gerando " + $t.name + "...")
    New-MockScreen -w $t.w -h $t.h -outputPath $out -headline $t.headline
}

Write-Host "Gerando feature graphic 1024x500..."
New-FeatureGraphic -outputPath (Join-Path $outDir "feature-graphic-1024x500.png")

# Copia do ícone 512x512 para facilitar upload no Play Console
$iconSrc = Join-Path $baseDir "imgs\\icon-512.png"
if (Test-Path $iconSrc) {
    $icon = [System.Drawing.Image]::FromFile($iconSrc)
    $icon.Save((Join-Path $outDir "playstore-icon-512.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $icon.Dispose()
}

$logo.Dispose()
Write-Host "Assets do Play Store gerados em $outDir"

