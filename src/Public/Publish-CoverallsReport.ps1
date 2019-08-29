<#
.SYNOPSIS
Publishes a Coverage Report to Coveralls.io

.DESCRIPTION
Publishes a Coverage Report to Coveralls.io

.PARAMETER Report
The Coverage Report created from Format-CoverallsReport

.PARAMETER ApiToken
Your Coveralls.io API token

.PARAMETER CoverallsEndpoint
A custom endpoint for Coveralls.io

.EXAMPLE
Publish-CoverallsReport -Report $report -ApiToken 'token'
#>
function Publish-CoverallsReport
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]
        $Report,

        [Parameter(Mandatory=$true)]
        [string]
        $ApiToken,

        [Parameter()]
        [string]
        $CoverallsEndpoint
    )

    # add the api token to the report
    $Report['repo_token'] = $ApiToken

    try
    {
        # parse the json data
        $json = [string]::Empty
        if ($PSVersionTable.PSVersion.Major -lt 5) {
            $json = ($Report | ConvertTo-Json -Depth 3)
        }
        else {
            $json = ($Report | ConvertTo-Json -Depth 3 -Compress)
        }

        # get the coveralls url
        $url = "$(Get-CoverallsUrl -Endpoint $CoverallsEndpoint)/api/v1/jobs"

        # send the report
        Add-Type -AssemblyName System.Net.Http

        $stringContent = New-Object System.Net.Http.StringContent -ArgumentList $json
        $httpClient = New-Object System.Net.Http.Httpclient
        $formdata = New-Object System.Net.Http.MultipartFormDataContent
        $formData.Add($stringContent, "json_file", "coverage.json")

        # get the result
        $result = $httpClient.PostAsync($url, $formData).Result
        if (!$result.IsSuccessStatusCode) {
            throw "Failed to send Coverage Report: $($result.StatusCode) [$($result.ReasonPhrase)]"
        }

        # get the content and url
        $content = $result.Content.ReadAsStringAsync()
        return ($content.Result | ConvertFrom-Json).url
    }
    finally {
        $Report.Remove('repo_token')
    }
}
