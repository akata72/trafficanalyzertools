[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    $InputFile,
    [Parameter(Mandatory = $false)]
    [switch]$showFailuresOnly = $false
)


function Write-Log {
    [CmdletBinding()]
    param
    (
        [String]$Message,
        [String]$Warning,
        [String]$Severity = "Information",
        [System.Management.Automation.ErrorRecord]$ErrorObj,
        #[String]$LogFolderPath = "$env:Temp/trafficanalyzer",
        [String]$LogFolderPath = "./",
        [String]$LogFilePrefix = 'Log'
    )
 
    $Date = Get-Date -Format "dd_MMMM_yyyy"
    $Time = Get-Date -Format "HH:mm:ss.f"
    $LogFile = "$($LogFolderPath)/$($LogFilePrefix)_$($Date).log"
 
    if ($PSBoundParameters.ContainsKey("ErrorObj")) {
        $LogMessage += "Error: $ErrorObj $($ErrorObj.ScriptStackTrace.Split("`n") -join ' <-- ')"
        Write-Error "[$($time)] $($LogMessage)"
    }
    elseif ($PSBoundParameters.ContainsKey("Warning")) {
        $LogMessage += "$Warning"
        Write-Warning "[$($time)] $($LogMessage)"
    }
    else {
        $LogMessage += "Info: $Message"
        Write-Host "[$($time)] $($LogMessage)"
    } 

    $logentry = [pscustomobject]@{         
        Time     = $Time
        Message  = $LogMessage         
        Severity = $Severity     
    } 
    $logentry | Export-Csv -Path $LogFile -Append -NoTypeInformation
}


# Using .NET objects to avoid dependencies on powershell (i.e can execute on Windows 2008)

function Invoke-W2k8CompatibleTests {
    param (
        $serverList
    )
    $ranges = ("49152-65535", "32000-49151")

    foreach ($target in $serverlist) {
        $iplist = @()
        if ('' -eq $target.RemoteIpList) { $iplist += $target.destinationip } else { $iplist = $target.RemoteIpList } 

        foreach ($ip in $iplist) {
            foreach ($port in $target.destinationportlist) {
                $dnsresults = $null
                if ($port -notin $ranges) {
                    # filter the ranges to avoid int conversion problems.
                    try { 
                        if (( ([int]$port) -lt 1025) -and (([int]$port) -gt 0 )) {
                            $timestamp = Get-Date
                            $result = New-Object System.Net.Sockets.TcpClient($ip, $port)
                            if (!$showFailuresOnly) {
                                $output = "Success: RESPONSE from destination $($ip) ($($target.remotednscanonicalnames)) on TCP port $port used by $($target.processname), $($target.groupname), usage: $($target.count_), was allowed on-prem from $($target.computer)"
                                Write-Log -Message $output
                            }
                        }
                    }
                    catch {
                        $output = "BLOCKED or NO response from destination $($ip) ($($dnsresults.hostname)) ($($target.remotednscanonicalnames)) on TCP port $port used by $($target.processname), $($target.groupname), $($target.count_) tcp connections was seen on-prem from $($target.computer)"
                        Write-Log -Warning $output 
                    }
                }
            }
        }
    }

}


Write-Log -Message "==================================================================================="
Write-Log -Message " TrafficAnalyzer-TCPTest"
Write-Log -Message "==================================================================================="

$serverlist = Get-Content -Raw -Path $InputFile | ConvertFrom-Json

Write-Log -Message "TCP Connection tests are executed from $($env:computername). High-ports ranges ($($ranges)) are not tested."

Invoke-W2k8CompatibleTests -Serverlist $serverlist
