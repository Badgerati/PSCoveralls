# PSCoveralls

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/Badgerati/PSCoveralls/master/LICENSE.txt)

This is a cross-platform PowerShell module that allows you to publish Pester code coverage results to Coveralls.io.

## Example

In order to use this module, you will need Pester.

1. The first step is to run your Pester tests, but using the `-CodeCoverage` switch:

```powershell
# you'll need the source files
$srcFiles = (Get-ChildItem "$($pwd)/src/*.ps1" -Recurse -Force).FullName

# then, run your pester tests
$PesterReport = Invoke-Pester './tests' -CodeCoverage $srcFiles -PassThru
```

2. Once you have your report, you can then make a report for Coveralls.io

```powershell
$CoverallsReport = New-CoverallsReport -Coverage $PesterReport.CodeCoverage -ServiceName 'appveyor' -BranchName master
```

3. Finally, you can publish that report to Coveralls.io

```powershell
Publish-CoverallsReport -Report $CoverallsReport -ApiToken 'token'
```
