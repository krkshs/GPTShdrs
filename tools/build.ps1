$ErrorActionPreference = 'Stop'
$taskScript = Join-Path $PSScriptRoot 'build_pack.py'
py -3 $taskScript
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
