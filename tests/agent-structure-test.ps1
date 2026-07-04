# Agent Structure Tests
# Validates that all .opencode/agents/*.md files have correct frontmatter and structure

$ErrorActionPreference = "Stop"
$agentDir = Join-Path (Join-Path (Join-Path $PSScriptRoot "..") ".opencode") "agents"
$failed = 0

Write-Host "=== Agent Structure Tests ===" -ForegroundColor Cyan
Write-Host ""

# Required frontmatter fields per mode type
$requiredFields = @{
    "all" = @("description", "mode", "temperature", "permission")
}

$allowedModes = @("subagent")
$allowedPermissionKeys = @("read", "write", "edit", "glob", "grep", "bash", "task", "webfetch", "websearch", "question", "skill")
$allowedPermissionValues = @("allow", "ask", "deny")

Get-ChildItem -Path $agentDir -Filter "*.md" | ForEach-Object {
    $file = $_.FullName
    $name = $_.Name
    Write-Host "  [$name]" -ForegroundColor Yellow
    
    $content = Get-Content -Path $file -Raw
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
    
    # Test 1: Has YAML frontmatter
    if ($content -notmatch '(?s)^---\s*\n(.*?)---') {
        Write-Host "    FAIL: Missing YAML frontmatter" -ForegroundColor Red
        $failed++
        return
    }
    $frontmatter = $Matches[1]
    Write-Host "    PASS: Has YAML frontmatter" -ForegroundColor Green
    
    # Test 2: Parse frontmatter values
    $yaml = @{}
    foreach ($line in $frontmatter -split "`r`n|`n") {
        if ($line -match '^(\w+):\s*(.+)$') {
            $yaml[$Matches[1]] = $Matches[2]
        }
    }
    
    # Test 3: Has description
    if (-not $yaml["description"]) {
        Write-Host "    FAIL: Missing description" -ForegroundColor Red
        $failed++
    } else {
        Write-Host "    PASS: Has description" -ForegroundColor Green
    }
    
    # Test 4: Mode is valid
    if ($yaml["mode"] -notin $allowedModes) {
        Write-Host "    FAIL: Invalid mode '$($yaml["mode"])'. Must be one of: $($allowedModes -join ', ')" -ForegroundColor Red
        $failed++
    } else {
        Write-Host "    PASS: Mode = $($yaml["mode"])" -ForegroundColor Green
    }
    
    # Test 5: Temperature is numeric
    if ($yaml["temperature"] -and $yaml["temperature"] -notmatch '^\d+\.?\d*$') {
        Write-Host "    FAIL: Temperature '$($yaml["temperature"])' is not numeric" -ForegroundColor Red
        $failed++
    } elseif (-not $yaml["temperature"]) {
        Write-Host "    WARN: No temperature set" -ForegroundColor Yellow
    } else {
        Write-Host "    PASS: Temperature = $($yaml["temperature"])" -ForegroundColor Green
    }
    
    # Test 6: Permission block exists
    if ($content -notmatch 'permission:\s*\n') {
        Write-Host "    FAIL: Missing permission block" -ForegroundColor Red
        $failed++
    }
    
    # Test 7: Permission consistency — read-only agents should not have edit: allow
    $readOnly = @('wiki-linter', 'validator')
    $writeAgents = @('code-writer', 'feature-writer', 'wiki-ingestor', 'pipeline')
    if ($baseName -in $readOnly) {
        if ($content -match 'edit:\s+allow') {
            Write-Host "    WARN: Read-only agent '$baseName' has edit: allow" -ForegroundColor Yellow
        } else {
            Write-Host "    PASS: Edit permission appropriate for read-only agent" -ForegroundColor Green
        }
    }
    if ($baseName -in $writeAgents) {
        if ($content -match 'edit:\s+allow') {
            Write-Host "    PASS: Write agent '$baseName' has edit: allow" -ForegroundColor Green
        } else {
            Write-Host "    WARN: Write agent '$baseName' missing edit: allow" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
}

# Test 8: Agent cross-references are valid
Write-Host "  [cross-reference: agent file references]" -ForegroundColor Yellow
$agentNames = Get-ChildItem -Path $agentDir -Filter "*.md" | ForEach-Object { $_.BaseName }
foreach ($file in Get-ChildItem -Path $agentDir -Filter "*.md") {
    $name = $file.BaseName
    $content = Get-Content -Path $file.FullName -Raw
    foreach ($other in $agentNames) {
        if ($other -ne $name -and $content -match [regex]::Escape($other)) {
            Write-Host "    PASS: '$name' references '$other'" -ForegroundColor Green
        }
    }
}

Write-Host "=== Summary ===" -ForegroundColor Cyan
if ($failed -gt 0) {
    Write-Host "$failed test(s) failed" -ForegroundColor Red
    exit 1
} else {
    Write-Host "All tests passed" -ForegroundColor Green
}
