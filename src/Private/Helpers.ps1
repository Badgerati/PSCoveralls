function Get-CoverallsUrl
{
    param(
        [Parameter()]
        [string]
        $Endpoint
    )

    if (![string]::IsNullOrWhiteSpace($Endpoint)) {
        return $Endpoint
    }

    return 'https://coveralls.io'
}

function Test-CoverallsIsPSCore
{
    return $PSVersionTable.PSEdition -ieq 'core'
}

function Get-CoverallsGitInfo
{
    param(
        [Parameter()]
        [string]
        $BranchName
    )

    if ([string]::IsNullOrWhiteSpace($BranchName)) {
        $BranchName = (git rev-parse --abbrev-ref HEAD)
    }

    return @{
        head = @{
            id = (git log --format="%H" HEAD -1)
            author_name = (git log --format="%an" HEAD -1)
            author_email = (git log --format="%ae" HEAD -1)
            committer_name = (git log --format="%cn" HEAD -1)
            committer_email = (git log --format="%ce" HEAD -1)
            message = (git log --format="%s" HEAD -1)
        }
        branch = $BranchName
    }
}

function Get-CoverallsGitCommit
{
    return (git log --format="%H" HEAD -1)
}

function Get-CoverallsCommandsForFile
{
    param(
        [Parameter(Mandatory=$true)]
        $Commands,

        [Parameter(Mandatory=$true)]
        [string]
        $File
    )

    $fullName = (Get-Item $File).FullName

    return @(foreach ($cmd in $Commands) {
        if ($cmd.File -ieq $fullName) {
            $cmd
        }
    })
}

function Format-CoverallsFileCoverage
{
    param(
        [Parameter(Mandatory=$true)]
        $Coverage,

        [Parameter(Mandatory=$true)]
        [string]
        $File,

        [Parameter(Mandatory=$true)]
        [string]
        $RootFolder
    )

    $fileHash = Get-FileHash -Path $File -Algorithm MD5

    $root = (Get-Item $RootFolder).FullName
    $fileName = (Get-Item $File).FullName.Replace($root, '').Replace('\','/').TrimStart('/')

    return @{
        name = $fileName
        source_digest = $fileHash.Hash
        coverage = $Coverage
    }
}

function Get-CoverallsCoverage
{
    param(
        [Parameter(Mandatory=$true)]
        $CoverageResult,

        [Parameter(Mandatory=$true)]
        [string]
        $File
    )

    # count the lines
    $lineCount = (Get-Content $File).Length
    $coverageArray = @()

    # loop the lines and macth with the provided results
    for ($line = 1; $line -le $lineCount; $line++) {
        $processedLine = @(foreach ($result in $CoverageResult) {
            if ($result.Line -eq $line) {
                $result
            }
        })

        if ($processedLine) {
            if (($processedLine.count -gt 1) -and ($processedLine[0].CoverageResult -eq 1)) {
                $coverageArray += $processedLine.count
            }
            else {
                $coverageArray += $processedLine[0].CoverageResult
            }
        }
        else {
            $coverageArray += $null
        }
    }

    return $coverageArray
}

function Add-CoverallsCoverageInfo
{
    param(
        [Parameter(Mandatory=$true)]
        $Value,

        [Parameter()]
        $CoverageResultSet
    )

    foreach ($result in $CoverageResultSet) {
        @{
            File = $result.File
            Line = $result.Line
            StartLine = $result.StartLine
            EndLine = $result.EndLine
            StartColumn = $result.StartColumn
            EndColumn = $result.EndColumn
            Class = $result.Class
            Function = $result.Function
            Command = $result.Command
            HitCount = $result.HitCount
            CoverageResult = $Value
        }
    }
}

function Merge-CoverallsCoverageResult
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $File,

        [Parameter()]
        $HitCommands,

        [Parameter()]
        $MissedCommands
    )

    # check what has been analyzed and provide context
    Add-CoverallsCoverageInfo -CoverageResultSet $HitCommands -Value 1
    Add-CoverallsCoverageInfo -CoverageResultSet $MissedCommands -Value 0

    # add both arrays for easier enumeration
    return @(@($HitCommands) + @($MissedCommands))
}
