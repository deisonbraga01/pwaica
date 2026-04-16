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
$outIphone = Join-Path $baseDir "imgs\store\apple\iphone"
$outIpad = Join-Path $baseDir "imgs\store\apple\ipad"

New-Item -ItemType Directory -Force -Path $outIphone, $outIpad | Out-Null

$edge = Get-EdgePath

function Capture([int]$w, [int]$h, [string]$outPath) {
    $args = @(
        "--headless",
        "--disable-gpu",
        "--hide-scrollbars",
        "--force-device-scale-factor=1",
        ("--window-size=" + $w + "," + $h),
        ("--virtual-time-budget=" + 7000),
        ("--screenshot=" + $outPath),
        $Url
    )
    & $edge @args | Out-Null

    if (-not (Test-Path $outPath)) { throw "Falhou ao gerar $outPath" }
    if ((Get-Item $outPath).Length -lt 2048) { throw "Arquivo inválido: $outPath" }
}

# iPhone (tamanhos aceitos no App Store Connect)
$iphoneTargets = @(
    @{ w = 1242; h = 2688; name = "iphone-65-1242x2688.png" },
    @{ w = 2688; h = 1242; name = "iphone-65-2688x1242.png" },
    @{ w = 1284; h = 2778; name = "iphone-67-1284x2778.png" },
    @{ w = 2778; h = 1284; name = "iphone-67-2778x1284.png" }
)

foreach ($t in $iphoneTargets) {
    $out = Join-Path $outIphone $t.name
    Write-Host ("Capturando iphone/" + $t.name + "...")
    Capture -w $t.w -h $t.h -outPath $out
}

# iPad (12,9 e 13)
$ipadTargets = @(
    @{ w = 2064; h = 2752; name = "ipad-13-2064x2752.png" },
    @{ w = 2752; h = 2064; name = "ipad-13-2752x2064.png" },
    @{ w = 2048; h = 2732; name = "ipad-129-2048x2732.png" },
    @{ w = 2732; h = 2048; name = "ipad-129-2732x2048.png" }
)

foreach ($t in $ipadTargets) {
    $out = Join-Path $outIpad $t.name
    Write-Host ("Capturando ipad/" + $t.name + "...")
    Capture -w $t.w -h $t.h -outPath $out
}

Write-Host "Concluído. Screenshots Apple em $outIphone e $outIpad"

