$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
npm.cmd run check:config
if ($LASTEXITCODE -ne 0) { throw 'Configure .env first.' }
# Use the exact same URL read by the app; no hard-coded original project reference.
$ref = node --env-file=.env -p 'new URL(process.env.EXPO_PUBLIC_SUPABASE_URL.trim()).hostname.split(String.fromCharCode(46))[0]'
if ($LASTEXITCODE -ne 0 -or $ref -notmatch '^[a-z0-9-]+$') { throw 'Could not determine project reference.' }
Write-Host "Target Supabase project: $ref"
if ((Read-Host 'Type DEPLOY to confirm this is the intended project') -cne 'DEPLOY') { throw 'Deployment cancelled.' }
npx.cmd --yes supabase functions deploy read-mark --project-ref $ref --no-verify-jwt --use-api
if ($LASTEXITCODE -ne 0) { throw 'Edge Function deployment failed.' }
Write-Host 'Function deployed. Run npm.cmd run test:reader:live to test with synthetic images (uses Gemini quota).'
