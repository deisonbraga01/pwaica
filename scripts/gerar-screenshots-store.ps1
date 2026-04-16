Add-Type -AssemblyName System.Drawing

$outDir = "c:\wamp\www\appicamedtec\imgs\store"
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

$outDirIpad = Join-Path $outDir "ipad"
if (-not (Test-Path $outDirIpad)) {
    New-Item -ItemType Directory -Path $outDirIpad | Out-Null
}

$logoPath = Join-Path $env:TEMP "ica-logo.png"
Invoke-WebRequest -Uri "https://icamedtec.com.br/wp-content/uploads/2025/12/logo-tec3-300x218.png" -OutFile $logoPath
$logo = [System.Drawing.Image]::FromFile($logoPath)

function New-StoreScreenshot([int]$w, [int]$h, [string]$outputPath) {
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

    # "Card" central no estilo do app
    $panelW = [int]($w * 0.76)
    $panelH = [int]($h * 0.46)
    $panelX = [int](($w - $panelW) / 2)
    $panelY = [int](($h - $panelH) / 2)
    $panelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 10, 32, 35))
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 30, 155, 146), 2)

    # Desenho manual de retângulo arredondado
    $radius = [int]([Math]::Max(18, [int]($w * 0.02)))
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($panelX, $panelY, $radius, $radius, 180, 90) | Out-Null
    $path.AddArc($panelX + $panelW - $radius, $panelY, $radius, $radius, 270, 90) | Out-Null
    $path.AddArc($panelX + $panelW - $radius, $panelY + $panelH - $radius, $radius, $radius, 0, 90) | Out-Null
    $path.AddArc($panelX, $panelY + $panelH - $radius, $radius, $radius, 90, 90) | Out-Null
    $path.CloseFigure()
    $g.FillPath($panelBrush, $path)
    $g.DrawPath($borderPen, $path)

    # Logo no topo do card
    $logoMaxW = [int]($panelW * 0.26)
    $logoMaxH = [int]($panelH * 0.18)
    $ratio = [Math]::Min($logoMaxW / $logo.Width, $logoMaxH / $logo.Height)
    $lw = [int]($logo.Width * $ratio)
    $lh = [int]($logo.Height * $ratio)
    $lx = $panelX + [int](($panelW - $lw) / 2)
    $ly = $panelY + [int]($panelH * 0.10)
    $g.DrawImage($logo, $lx, $ly, $lw, $lh)

    # Tipografia (sem exagero para não ficar "marketing demais")
    $titleSize = [float]([Math]::Max(28, [int]($w * 0.028)))
    $subSize = [float]([Math]::Max(18, [int]($w * 0.017)))
    $smallSize = [float]([Math]::Max(16, [int]($w * 0.014)))

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", $titleSize, [System.Drawing.FontStyle]::Bold)
    $fontSub = New-Object System.Drawing.Font("Segoe UI", $subSize, [System.Drawing.FontStyle]::Regular)
    $fontSmall = New-Object System.Drawing.Font("Segoe UI", $smallSize, [System.Drawing.FontStyle]::Regular)

    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(242, 228, 247, 245))
    $mutedBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, 155, 194, 191))
    $accentBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 31, 173, 159))

    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center

    $g.DrawString("Acesso por CPF", $fontTitle, $textBrush, [float]($w / 2), [float]($panelY + $panelH * 0.34), $sf)
    $g.DrawString("Receba um link mágico para entrar com segurança", $fontSub, $mutedBrush, [float]($w / 2), [float]($panelY + $panelH * 0.44), $sf)

    # Campo de CPF (mock)
    $fieldW = [int]($panelW * 0.78)
    $fieldH = [int]([Math]::Max(64, [int]($h * 0.03)))
    $fieldX = $panelX + [int](($panelW - $fieldW) / 2)
    $fieldY = $panelY + [int]($panelH * 0.58)
    $fieldRect = [System.Drawing.Rectangle]::new($fieldX, $fieldY, $fieldW, $fieldH)

    $fieldBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 6, 25, 27))
    $fieldPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(110, 80, 153, 148), 2)
    $g.FillRectangle($fieldBrush, $fieldRect)
    $g.DrawRectangle($fieldPen, $fieldRect)
    $g.DrawString("000.000.000-00", $fontSmall, $mutedBrush, [float]($fieldX + 22), [float]($fieldY + ($fieldH * 0.22)))

    # Botão
    $btnW = [int]($fieldW * 0.78)
    $btnH = [int]([Math]::Max(70, [int]($h * 0.034)))
    $btnX = $panelX + [int](($panelW - $btnW) / 2)
    $btnY = $fieldY + $fieldH + [int]([Math]::Max(26, $h * 0.02))
    $btnRect = [System.Drawing.Rectangle]::new($btnX, $btnY, $btnW, $btnH)

    $btnBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $btnRect,
        [System.Drawing.Color]::FromArgb(255, 31, 173, 159),
        [System.Drawing.Color]::FromArgb(255, 15, 122, 115),
        0
    )
    $g.FillRectangle($btnBrush, $btnRect)
    $g.DrawString("Receber link mágico", $fontSub, $textBrush, [float]($w / 2), [float]($btnY + ($btnH * 0.22)), $sf)

    # Rodapé discreto
    $g.DrawString("PWA ICA Med Tec • Telemedicina", $fontSmall, $mutedBrush, [float]($w / 2), [float]($panelY + $panelH * 0.90), $sf)

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
    $accentBrush.Dispose()
    $sf.Dispose()
    $fieldBrush.Dispose()
    $fieldPen.Dispose()
    $btnBrush.Dispose()
    $g.Dispose()
    $bmp.Dispose()
}

$targets = @(
    @{ w = 1242; h = 2688; name = "iphone-65-1242x2688.png" },
    @{ w = 2688; h = 1242; name = "iphone-65-2688x1242.png" },
    @{ w = 1284; h = 2778; name = "iphone-67-1284x2778.png" },
    @{ w = 2778; h = 1284; name = "iphone-67-2778x1284.png" }
)

foreach ($t in $targets) {
    $out = Join-Path $outDir $t.name
    Write-Host ("Gerando " + $t.name + "...")
    New-StoreScreenshot -w $t.w -h $t.h -outputPath $out
}

$targetsIpad = @(
    @{ w = 2064; h = 2752; name = "ipad-13-2064x2752.png" },
    @{ w = 2752; h = 2064; name = "ipad-13-2752x2064.png" },
    @{ w = 2048; h = 2732; name = "ipad-129-2048x2732.png" },
    @{ w = 2732; h = 2048; name = "ipad-129-2732x2048.png" }
)

foreach ($t in $targetsIpad) {
    $out = Join-Path $outDirIpad $t.name
    Write-Host ("Gerando ipad/" + $t.name + "...")
    New-StoreScreenshot -w $t.w -h $t.h -outputPath $out
}

$logo.Dispose()
Write-Host "Screenshots gerados em $outDir e $outDirIpad"

