param(
    [string]$LocalPath = "C:\Users\user\Documents\Projects\wonder_world",
    [string]$RemotePath = "gdrive:[Projects]/wonder_world",
    [string]$Mode = "copy", # copy | sync | bisync
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "1. Deduplicating remote files on $RemotePath (keeping newest)..." -ForegroundColor Cyan
$dedupeArgs = @("dedupe", "--dedupe-mode", "newest", "--exclude", ".git/**")
if ($DryRun) { $dedupeArgs += "--dry-run" }
$dedupeArgs += $RemotePath
& rclone @dedupeArgs

Write-Host "2. Running rclone $Mode between '$LocalPath' and '$RemotePath' (excluding .git/**)..." -ForegroundColor Cyan
$commonArgs = @("--exclude", ".git/**", "--exclude", ".tmp.driveupload/**", "--progress")
if ($DryRun) { $commonArgs += "--dry-run" }

switch ($Mode.ToLower()) {
    "copy" {
        & rclone copy $RemotePath $LocalPath @commonArgs
    }
    "sync" {
        & rclone sync $RemotePath $LocalPath @commonArgs
    }
    "bisync" {
        & rclone bisync $LocalPath $RemotePath @commonArgs
    }
    default {
        throw "Unsupported Mode: $Mode. Use copy, sync, or bisync."
    }
}

Write-Host "Done." -ForegroundColor Green
