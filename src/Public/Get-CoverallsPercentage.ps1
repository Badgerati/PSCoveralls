<#
.SYNOPSIS
Retrieves the Coverage Percentage of a Reportisory from Coveralls.io

.DESCRIPTION
Retrieves the Coverage Percentage of a Reportisory from Coveralls.io

.PARAMETER Username
The Username of whom owns the Repository

.PARAMETER RepoName
The Name of the Reportisory

.PARAMETER SourceControl
Which source control the Repository is stored in

.PARAMETER CoverallsEndpoint
A custom endpoint for Coveralls.io

.EXAMPLE
Get-CoverallsPercentage -Username 'username' -RepoName 'repo-name'

.EXAMPLE
Get-CoverallsPercentage -Username 'username' -RepoName 'repo-name' -SourceControl 'gitlab'
#>
function Get-CoverallsPercentage
{
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Username,

        [Parameter(Mandatory=$true)]
        [string]
        $RepoName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $SourceControl = 'github',

        [Parameter()]
        [string]
        $CoverallsEndpoint
    )

    $url = "$(Get-CoverallsUrl -Endpoint $CoverallsEndpoint)/$($SourceControl)/$($Username)/$($RepoName).json"

    if (Test-CoverallsIsPSCore) {
        $result = Invoke-WebRequest -Uri $url
    }
    else {
        $result = Invoke-WebRequest -Uri $url -UseBasicParsing
    }

    $info = ($result.Content | ConvertFrom-Json)
    return [double]$info.covered_percent
}
