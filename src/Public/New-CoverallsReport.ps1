<#
.SYNOPSIS
Creates a Coveralls.io report from the Code Coverage report from Pester.

.DESCRIPTION
Creates a Coveralls.io report from the Code Coverage report from Pester.

.PARAMETER Coverage
The Pester test report that contains the CodeCoverage

.PARAMETER ServiceName
The Name of which CI Service the report is being generated
Examples are: appveyor, travis-ci, github-actions, jenkins, etc

.PARAMETER BranchName
The Name of the branch for which the report is being generated

.PARAMETER RootFolder
Optional root folder path

.EXAMPLE
$report = New-CoverallsReport -Coverage $PesterReport.CodeCoverage -ServiceName 'github-actions' -BranchName master
#>
function New-CoverallsReport
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)]
        $Coverage,

        [Parameter(Mandatory=$true)]
        [ValidateSet('appveyor', 'github-actions', 'jenkins', 'travis-ci', 'travis-pro')]
        [string]
        $ServiceName,

        [Parameter()]
        [string]
        $BranchName,

        [Parameter()]
        [string]
        $RootFolder = $pwd
    )

    $coverageData = @()

    foreach ($file in $Coverage.AnalyzedFiles) {
        $hitcommands = Get-CoverallsCommandsForFile -Commands $Coverage.HitCommands -File $file
        $missedCommands = Get-CoverallsCommandsForFile -Commands $Coverage.MissedCommands -File $file
        $coverageResult = Merge-CoverallsCoverageResult -HitCommands $hitcommands -MissedCommands $missedCommands -File $file
        $coverageArray = Get-CoverallsCoverage -CoverageResult $coverageResult -File $file
        $coverageData += (Format-CoverallsFileCoverage -Coverage $coverageArray -File $file -RootFolder $RootFolder)
    }

    return @{
        commit_sha = (Get-CoverallsGitCommit)
        git = (Get-CoverallsGitInfo -BranchName $BranchName)
        service_name = $ServiceName
        source_files = $coverageData
    }
}
