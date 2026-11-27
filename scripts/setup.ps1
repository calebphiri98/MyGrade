$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
if (!(Get-Command node -ErrorAction SilentlyContinue)) { throw 'Install Node.js 22 LTS (22.13 or newer) first.' }
$nodeVersion = [version]((node -p 'process.versions.node').Trim())
if ($nodeVersion -lt [version]'22.13.0') { throw 'Node.js 22.13 or newer is required.' }
if (!(Test-Path .env)) { Copy-Item .env.example .env }
npm.cmd ci
if ($LASTEXITCODE -ne 0) { throw 'npm ci failed. Check npm output before proceeding.' }
npm.cmd run test:reader
if ($LASTEXITCODE -ne 0) { throw 'Reader tests failed.' }
Write-Host 'Setup complete. Edit .env and follow DEPLOYMENT.md.'
