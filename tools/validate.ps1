param([switch]$AllOptions)
$ErrorActionPreference = 'Stop'
$taskScript = Join-Path $PSScriptRoot 'validate_shaders.py'
$taskArguments = @($taskScript, '--all-profiles', '--require-compiler')
if ($AllOptions) { $taskArguments += '--all-options' }
py -3 $taskArguments
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
