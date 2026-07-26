$projectPath = "D:\Courses\Java\ai-quarkus-example"
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

Compress-Archive -Path (Join-Path $packageDir "*") -DestinationPath $zipPath -Force

Write-Host "Deploying to Azure Function App..." -ForegroundColor Cyan
az functionapp deployment source config-zip `
  --resource-group $resourceGroup `
  --name $functionApp `
  --src $zipPath

Write-Host "Deployment completed." -ForegroundColor Green
