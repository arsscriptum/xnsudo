#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   Invoke-NSudo.ps1                                                             ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Invoke-NSudo {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Executable file path to launch with NSudo.')]
        [string]$Path,

        [Parameter(Mandatory = $true, HelpMessage = 'User type (e.g. T for TrustedInstaller).')]
        [ValidateSet('T', 'S', 'C', 'E', 'P', 'D')]
        [string]$User,

        [Parameter(Mandatory = $false, HelpMessage = 'Privilege level.')]
        [ValidateSet('Default', 'Enable', 'Disable')]
        [string]$Privileges = 'Default',

        [Parameter(Mandatory = $false, HelpMessage = 'Integrity level.')]
        [ValidateSet('Default', 'S', 'H', 'M', 'L')]
        [string]$IntegrityLevel = 'Default',

        [Parameter(Mandatory = $false, HelpMessage = 'Process priority.')]
        [ValidateSet('Default', 'Idle', 'BelowNormal', 'Normal', 'AboveNormal', 'High', 'RealTime')]
        [string]$Priority = 'Default',

        [Parameter(Mandatory = $false, HelpMessage = 'Window display mode.')]
        [ValidateSet('Default', 'Show', 'Hide', 'Maximize', 'Minimize')]
        [string]$ShowWindowMode = 'Default',

        [Parameter(Mandatory = $false)]
        [switch]$Wait,

        [Parameter(Mandatory = $false, HelpMessage = 'Set the working directory for the process.')]
        [string]$CurrentDirectory,

        [Parameter(Mandatory = $false)]
        [switch]$UseCurrentConsole
    )

    $NSudoCmd = Get-Command -Name "Find-Program" -CommandType Function -ErrorAction Ignore
    if (!$NSudoCmd) { Write-Error "Find-Program not found!" ; return }

    $NSudoPath = Find-Program "NSudoLC_64" -FirstMatch -PathOnly
    $argsList = @()

    $argsList += "-U:$User"

    if ($Privileges -eq 'Enable') {
        $argsList += "-P:E"
    } elseif ($Privileges -eq 'Disable') {
        $argsList += "-P:D"
    }

    if ($IntegrityLevel -ne 'Default') {
        $argsList += "-M:$IntegrityLevel"
    }

    if ($Priority -ne 'Default') {
        $argsList += "-Priority:$Priority"
    }

    if ($ShowWindowMode -ne 'Default') {
        $argsList += "-ShowWindowMode:$ShowWindowMode"
    }

    if ($Wait) {
        $argsList += "-Wait"
    }

    if ($UseCurrentConsole) {
        $argsList += "-UseCurrentConsole"
    }

    if ($CurrentDirectory) {
        $argsList += "-CurrentDirectory:`"$CurrentDirectory`""
    }

    $argsList += "`"$Path`""

    if ($PSCmdlet.ShouldProcess($Path, "Run with NSudo")) {
        & "$NSudoPath" $argsList
    }
}


function Invoke-NSudoExtended {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, HelpMessage = 'Executable file path to launch with NSudo.')]
        [string]$Path,

        [Parameter(Mandatory = $true, HelpMessage = 'User type (e.g. T for TrustedInstaller).')]
        [ValidateSet('T', 'S', 'C', 'E', 'P', 'D')]
        [string]$User,

        [Parameter(Mandatory = $false, HelpMessage = 'Privilege level.')]
        [ValidateSet('Default', 'Enable', 'Disable')]
        [string]$Privileges = 'Default',

        [Parameter(Mandatory = $false, HelpMessage = 'Integrity level.')]
        [ValidateSet('Default', 'S', 'H', 'M', 'L')]
        [string]$IntegrityLevel = 'Default',

        [Parameter(Mandatory = $false, HelpMessage = 'Process priority.')]
        [ValidateSet('Default', 'Idle', 'BelowNormal', 'Normal', 'AboveNormal', 'High', 'RealTime')]
        [string]$Priority = 'Default',

        [Parameter(Mandatory = $false, HelpMessage = 'Window display mode.')]
        [ValidateSet('Default', 'Show', 'Hide', 'Maximize', 'Minimize')]
        [string]$ShowWindowMode = 'Default',

        [Parameter(Mandatory = $false)]
        [switch]$Wait,

        [Parameter(Mandatory = $false, HelpMessage = 'Set the working directory for the process.')]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $false)]
        [switch]$UseCurrentConsole
    )
    
    $NSudoWorkingDirectory = (Resolve-Path -Path "$PWD").Path
    if((-not([string]::IsNullOrEmpty($WorkingDirectory))) -and (Test-Path -Path "$WorkingDirectory" -PathType Container)){
        Write-Verbose "Setting WorkingDirectory to $WorkingDirectory"
        $NSudoWorkingDirectory = $WorkingDirectory

    }

    $NSudoCmd = Get-Command -Name "Find-Program" -CommandType Function -ErrorAction Ignore
    if (!$NSudoCmd) { Write-Error "Find-Program not found!"; return }

    $NSudoPath = Find-Program "NSudoLC_64" -FirstMatch -PathOnly
    $argsList = @()

    $argsList += "-U:$User"

    if ($Privileges -eq 'Enable') {
        $argsList += "-P:E"
    } elseif ($Privileges -eq 'Disable') {
        $argsList += "-P:D"
    }

    if ($IntegrityLevel -ne 'Default') {
        $argsList += "-M:$IntegrityLevel"
    }

    if ($Priority -ne 'Default') {
        $argsList += "-Priority:$Priority"
    }

    if ($ShowWindowMode -ne 'Default') {
        $argsList += "-ShowWindowMode:$ShowWindowMode"
    }

    if ($Wait) {
        $argsList += "-Wait"
    }

    if ($UseCurrentConsole) {
        $argsList += "-UseCurrentConsole"
    }

    if ($CurrentDirectory) {
        $argsList += "-CurrentDirectory:`"$CurrentDirectory`""
    }

    $argsList += "`"$Path`""


    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        

        $FNameOut = New-RandomFilename -Extension 'log' -CreateDirectory
        $FNameErr = New-RandomFilename -Extension 'log' -CreateDirectory

        $startProcessParams = @{
            FilePath = $NSudoPath
            ArgumentList = $ArgumentList
            Verb = "RunAs"
            RedirectStandardError = $FNameErr
            RedirectStandardOutput = $FNameOut
            Wait = $Wait
            PassThru = $true
            NoNewWindow = $UseCurrentConsole
            WorkingDirectory = $NSudoWorkingDirectory
        }
        if ($PSCmdlet.ShouldProcess($Path, "Run with NSudo")) {
            $cmd = Start-Process @startProcessParams
            $cmdExitCode = $cmd.ExitCode
            $cmdId = $cmd.Id
            $cmdHasExited = $cmd.HasExited
            $cmdTotalProcessorTime = $cmd.TotalProcessorTime


            $stdOut = Get-Content -Path $FNameOut -Raw
            $stdErr = Get-Content -Path $FNameErr -Raw
            if ([string]::IsNullOrEmpty($stdOut) -eq $false) {
                $stdOut = $stdOut.Trim()
            }
            if ([string]::IsNullOrEmpty($stdErr) -eq $false) {
                $stdErr = $stdErr.Trim()
            }
            $stopwatch.Stop()
            $res = [pscustomobject]@{
                HasExited = $cmdHasExited
                TotalProcessorTime = $cmdTotalProcessorTime
                Id = $cmdId
                ExitCode = $cmdExitCod
                Output = $stdOut
                Error = $stdErr
                ElapsedSeconds = $stopwatch.Elapsed.Seconds
                ElapsedMs = $stopwatch.Elapsed.Milliseconds
            }

            return $res
        } else {
            $startProcessParams | Format-Table
        }


    } catch {
        Show-ExceptionDetails $_
    }
    finally {
        $Null = Remove-Item -Path $FNameOut -Force -ErrorAction Ignore
        $Null = Remove-Item -Path $FNameErr -Force -ErrorAction Ignore
    }
}


function Invoke-NSudoGUI {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, HelpMessage = 'Privilege level.')]
        [ValidateSet('Default', 'Enable', 'Disable')]
        [string]$Privileges = 'Default',

        [Parameter(Mandatory = $false, HelpMessage = 'Integrity level.')]
        [ValidateSet('Default', 'S', 'H', 'M', 'L')]
        [string]$IntegrityLevel = 'Default',

        [Parameter(Mandatory = $false, HelpMessage = 'Process priority.')]
        [ValidateSet('Default', 'Idle', 'BelowNormal', 'Normal', 'AboveNormal', 'High', 'RealTime')]
        [string]$Priority = 'Default'
    )
    
    $NSudoCmd = Get-Command -Name "Find-Program" -CommandType Function -ErrorAction Ignore
    if (!$NSudoCmd) { Write-Error "Find-Program not found!"; return }

    $NSudoPath = Find-Program "NSudoLG_64" -FirstMatch -PathOnly
    

    try {
        
        if ($PSCmdlet.ShouldProcess($Path, "Run with NSudo")) {
            $cmd = Start-Process -FilePath "$NSudoPath"
            

            return $cmd
        }

    } catch {
        Show-ExceptionDetails $_
    }
}