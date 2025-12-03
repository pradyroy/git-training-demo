#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Simple cross-platform "Guess the Number" game.
  Version 1 (initial version):
  - The game works, but there is one intentional bug:
    Invalid input and out-of-range guesses incorrectly consume attempts.
#>

param(
    [int]$MaxNumber = 100,
    [int]$MaxAttempts = 7
)

Write-Host "====================================="
Write-Host "     Welcome to Guess the Number      "
Write-Host "====================================="
Write-Host ""
Write-Host "I'm thinking of a number between 1 and $MaxNumber."
Write-Host "You have $MaxAttempts attempts. Good luck!"
Write-Host ""

# Generate a random secret number
$secret = Get-Random -Minimum 1 -Maximum ($MaxNumber + 1)
$attempt = 0
$won = $false

# IMPORTANT: Initialize $guess before using [ref]$guess
[int]$guess = 0

while ($attempt -lt $MaxAttempts -and -not $won) {
    $attempt++

    $guessRaw = Read-Host "Attempt #$attempt - Enter your guess"

    # BUG: Non-numeric input still consumes an attempt
    if (-not [int]::TryParse($guessRaw, [ref]$guess)) {
        Write-Host "That doesn't look like a valid number. Try again."
        $attempt-- #BUGFIX
        continue
    }

    # BUG: Out-of-range guess also consumes an attempt
    if ($guess -lt 1 -or $guess -gt $MaxNumber) {
        Write-Host "Please enter a number between 1 and $MaxNumber."
        $attempt-- #BUGFIX
        continue
    }

    if ($guess -eq $secret) {
        Write-Host ""
        Write-Host "🎉 Correct! You guessed the number in $attempt attempt(s)."
        $won = $true
    }
    elseif ($guess -lt $secret) {
        Write-Host "Too low. Try a higher number."
    }
    else {
        Write-Host "Too high. Try a lower number."
    }
}

if (-not $won) {
    Write-Host ""
    Write-Host "😢 Out of attempts. The number was: $secret"
}

Write-Host ""
Write-Host "Thanks for playing the game!" #ENHANCEMENT
Write-Host "Have a good time ahead!"
