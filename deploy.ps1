$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectPath = (Resolve-Path $scriptDir).Path
$resourceGroup = "quarkus-bot-rg-brazil"
$functionApp = "ai-quarkus-bot-br-flex"

Set-Location $projectPath

Write-Host "Building the Quarkus app..." -ForegroundColor Cyan
.\mvnw.cmd clean package -DskipTests

Write-Host "Creating deployment package..." -ForegroundColor Cyan
$packageDir = Join-Path $projectPath "target\azure-functions\ai-quarkus-bot-br-flex"
$zipPath = Join-Path $projectPath "target\azure-functions\ai-quarkus-bot-br-flex.zip"

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $files = Get-ChildItem -LiteralPath $packageDir -Recurse -File
    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring($packageDir.Length).TrimStart('\', '/')
        $relativePath = $relativePath.Replace('\\', '/').Replace('\', '/')
        $entry = $zip.CreateEntry($relativePath)
        $entryStream = $entry.Open()
        try {
            $sourceStream = [System.IO.File]::OpenRead($file.FullName)
            try {
                $sourceStream.CopyTo($entryStream)
            }
            finally {
                $sourceStream.Dispose()
            }
        }
        finally {
            $entryStream.Dispose()
        }
    }
}
finally {
    $zip.Dispose()
}

Write-Host "Deploying to Azure Function App..." -ForegroundColor Cyan
az functionapp deployment source config-zip `
  --resource-group $resourceGroup `
  --name $functionApp `
  --src $zipPath

Write-Host "Deployment completed." -ForegroundColor Green
