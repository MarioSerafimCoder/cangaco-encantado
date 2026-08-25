$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$errors = [System.Collections.Generic.List[string]]::new()
$requiredFiles = @(
    'project.godot',
    'scenes/main.tscn',
    'scenes/player/player.tscn',
    'scenes/enemies/saqueador.tscn',
    'scenes/enemies/pistoleiro.tscn',
    'scenes/bosses/ze_tranca.tscn',
    'scenes/world/vila_do_umbuzeiro/vila_do_umbuzeiro.tscn',
    'README.md',
    'docs/IMPLEMENTATION.md'
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $projectRoot $relativePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        $errors.Add("Arquivo obrigatório ausente: $relativePath")
    }
}

$projectText = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'project.godot')
$requiredActions = @(
    'move_left', 'move_right', 'move_up', 'move_down', 'jump', 'crouch',
    'melee', 'shoot_revolver', 'shoot_shotgun', 'aim', 'heal',
    'interact', 'pause', 'toggle_debug'
)
foreach ($action in $requiredActions) {
    if ($projectText -notmatch [regex]::Escape("$action=")) {
        $errors.Add("Ação ausente no InputMap: $action")
    }
}

$textFiles = Get-ChildItem -LiteralPath $projectRoot -Recurse -File | Where-Object {
    $_.Extension -in @('.gd', '.tscn', '.tres', '.godot') -and
    $_.FullName -notmatch '[\\/]\.godot[\\/]'
}
$referencePattern = [regex]'res://[^"''\s\)\]]+'
foreach ($file in $textFiles) {
    $content = Get-Content -Raw -LiteralPath $file.FullName
    foreach ($match in $referencePattern.Matches($content)) {
        $relativeReference = $match.Value.Substring(6).Replace('/', [IO.Path]::DirectorySeparatorChar)
        $target = Join-Path $projectRoot $relativeReference
        if (-not (Test-Path -LiteralPath $target)) {
            $errors.Add("Referência quebrada em $($file.FullName): $($match.Value)")
        }
    }
}

$playerScripts = Get-ChildItem -LiteralPath (Join-Path $projectRoot 'scripts/player') -File -Filter '*.gd'
foreach ($file in $playerScripts) {
    $content = Get-Content -Raw -LiteralPath $file.FullName
    if ($content -match 'Input\.is_key_pressed|InputEventKey') {
        $errors.Add("Leitura de tecla hardcoded em $($file.Name)")
    }
}

$referenceImages = @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'assets/source/reference') -File -Filter '*.png')
$sourcePdfs = @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'docs/source') -File -Filter '*.pdf')
if ($referenceImages.Count -ne 15) {
    $errors.Add("Esperadas 15 imagens preservadas; encontradas $($referenceImages.Count).")
}
if ($sourcePdfs.Count -ne 2) {
    $errors.Add("Esperados 2 PDFs preservados; encontrados $($sourcePdfs.Count).")
}

if ($errors.Count -gt 0) {
    Write-Host 'VALIDAÇÃO FALHOU' -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
    exit 1
}

Write-Host 'VALIDAÇÃO ESTÁTICA OK' -ForegroundColor Green
Write-Host "Arquivos Godot verificados: $($textFiles.Count)"
Write-Host "Ações de input verificadas: $($requiredActions.Count)"
Write-Host "Imagens de referência preservadas: $($referenceImages.Count)"
Write-Host "PDFs de design preservados: $($sourcePdfs.Count)"
