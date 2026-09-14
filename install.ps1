# Install pstack skills and agents into your Claude Code config.
# Re-running converges to the same state. Set CLAUDE_HOME to install elsewhere.
# -Check reports what is missing or out of date and writes nothing.
param([switch]$Force, [switch]$Check)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$target = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME '.claude' }

function Get-TreeHash($path) {
	$files = Get-ChildItem -Path $path -Recurse -File | Sort-Object FullName
	($files | ForEach-Object {
		$rel = $_.FullName.Substring($path.Length).Replace('\', '/')
		"$rel|" + (Get-FileHash $_.FullName -Algorithm SHA256).Hash
	}) -join "`n"
}

if ($Check) {
	$current = 0
	$missing = @()
	$differing = @()
	foreach ($src in Get-ChildItem (Join-Path $repo 'skills') -Directory) {
		$dst = Join-Path $target "skills\$($src.Name)"
		if (-not (Test-Path $dst)) {
			$missing += $src.Name
		} elseif ((Get-TreeHash $src.FullName) -eq (Get-TreeHash $dst)) {
			$current++
		} else {
			$differing += $src.Name
		}
	}
	Write-Host "pstack in $target"
	Write-Host "  current   $current"
	Write-Host "  missing   $($missing.Count)"
	foreach ($m in $missing) { Write-Host "    $m" }
	Write-Host "  differing $($differing.Count)"
	foreach ($d in $differing) { Write-Host "    $d" }
	Write-Host ""
	if ($missing.Count -eq 0 -and $differing.Count -eq 0) {
		Write-Host "up to date"
		exit 0
	}
	Write-Host "Run .\install.ps1 to add what is missing, or .\install.ps1 -Force to replace what differs."
	exit 1
}

$installed = 0
$skipped = 0
$collisions = @()

foreach ($src in Get-ChildItem (Join-Path $repo 'skills') -Directory) {
	$dst = Join-Path $target "skills\$($src.Name)"
	if (Test-Path $dst) {
		if ((Get-TreeHash $src.FullName) -eq (Get-TreeHash $dst)) {
			$skipped++
			continue
		}
		if (-not $Force) {
			$collisions += $src.Name
			continue
		}
	}
	New-Item -ItemType Directory -Force (Join-Path $target 'skills') | Out-Null
	if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
	Copy-Item -Recurse $src.FullName $dst
	$installed++
}

if ($collisions.Count -gt 0) {
	Write-Error @"
Refusing to overwrite $($collisions.Count) existing skill(s) that differ from ours:
  $($collisions -join "`n  ")

These may be your own skills. Back them up, then re-run with -Force.
"@
	exit 1
}

New-Item -ItemType Directory -Force (Join-Path $target 'agents') | Out-Null
$agents = Get-ChildItem (Join-Path $repo 'agents') -Filter *.md
foreach ($a in $agents) { Copy-Item -Force $a.FullName (Join-Path $target "agents\$($a.Name)") }

Write-Host "pstack installed to $target"
Write-Host "  skills: $installed added or updated, $skipped already current"
Write-Host "  agents: $($agents.Count)"
Write-Host ""
Write-Host "Restart Claude Code, then run /setup-pstack"
