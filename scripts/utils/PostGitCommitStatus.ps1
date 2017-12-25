﻿<#
.SYNOPSIS
Script to post status of tests for the commit to GitHub

.DESCRIPTION
Uses the Personal Access Token of NuGetLurker to automate the tagging process.
#>
Function Update-GitCommitStatus {
    param(
        [Parameter(Mandatory = $True)]
        [string]$PersonalAccessToken,
        [Parameter(Mandatory = $True)]
        [string]$TestName,
        [Parameter(Mandatory = $True)]
        [ValidateSet( "Pending", "Success", "Error", "Failure")]
        [string]$Status,
        [Parameter(Mandatory = $True)]
        [string]$CommitSha,
        [Parameter(Mandatory = $True)]
        [string]$TargetUrl
    )

    $Token = $PersonalAccessToken
    $Base64Token = [System.Convert]::ToBase64String([char[]]$Token)

    $Headers = @{
        Authorization = 'Basic {0}' -f $Base64Token;
    }

    $Body = @{
        state      = $Status;
        context    = $TestName;
        target_url = $TargetUrl;
    } | ConvertTo-Json;

    Write-Host $Body

    $r1 = Invoke-RestMethod -Headers $Headers -Method Post -Uri "https://api.github.com/repos/nuget/nuget.client/statuses/$CommitSha" -Body $Body

    Write-Host $r1
}

Function InitializeAllTestsToPending {
    param(
        [Parameter(Mandatory = $True)]
        [string]$PersonalAccessToken,
        [Parameter(Mandatory = $True)]
        [string]$CommitSha
    )

    $TargetUrl = $BuildUrl -f $(Build.BuildId)
    Update-GitCommitStatus -PersonalAccessToken $PersonalAccessToken -TestName "Unit Tests On Windows" - Status "Pending" -CommitSha $CommitSha -TargetUrl $TargetUrl
    Update-GitCommitStatus -PersonalAccessToken $PersonalAccessToken -TestName "Functional Tests On Windows" - Status "Pending" -CommitSha $CommitSha -TargetUrl $TargetUrl
    Update-GitCommitStatus -PersonalAccessToken $PersonalAccessToken -TestName "Tests On Mac" - Status "Pending" -CommitSha $CommitSha -TargetUrl $TargetUrl
    Update-GitCommitStatus -PersonalAccessToken $PersonalAccessToken -TestName "Tests on Linux" - Status "Pending" -CommitSha $CommitSha -TargetUrl $TargetUrl
    Update-GitCommitStatus -PersonalAccessToken $PersonalAccessToken -TestName "EndToEnd Tests On Windows" - Status "Pending" -CommitSha $CommitSha -TargetUrl $TargetUrl
    Update-GitCommitStatus -PersonalAccessToken $PersonalAccessToken -TestName "Apex Tests On Windows" - Status "Pending" -CommitSha $CommitSha -TargetUrl $TargetUrl
}

function SetCommitStatusForTestResult {
    param(
        [Parameter(Mandatory = $True)]
        [string]$PersonalAccessToken,
        [Parameter(Mandatory = $True)]
        [string]$TestName,
        [Parameter(Mandatory = $True)]
        [string]$CommitSha
    )

    $TargetUrl = $BuildUrl -f $(Build.BuildId)
    if ($(Agent.JobStatus) -eq "Succeeded") {
        Update-GitCommitStatus -PersonalAccessToken $PersonalAccessToken -TestName $TestName - Status "Success" -CommitSha $CommitSha -TargetUrl $TargetUrl
    }
    else {
        Update-GitCommitStatus -PersonalAccessToken $PersonalAccessToken -TestName $TestName - Status "Failed" -CommitSha $CommitSha -TargetUrl $TargetUrl
    }
}