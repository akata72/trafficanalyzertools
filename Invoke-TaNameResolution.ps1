[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    $InputFile
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
        $LogMessage += "Warning: $Warning"
        Write-Host "[$($time)] $($LogMessage)" -ForegroundColor Yellow
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
function Invoke-Lookup {
    param (
        $serverList
    )
    Write-Log -Message "Serverlist count: $($serverlist.count)"
    foreach ($target in $serverlist) {
        $iplist = @()
        # handles the situation when there is no IPs in RemoteIpList
        if ('' -eq $target.RemoteIpList) { $iplist += $target.DestinationIp } else { $iplist = $target.RemoteIpList } 

        foreach ($ip in $iplist) {
            $dnsresults = $null
            try {
                $dnsresults = [Net.DNS]::GetHostEntry($ip)
                Write-Log -Message "Success: $($ip), $($dnsresults.hostname)"
            }
            catch {
                Write-Log -Warning "Failure: Unable to resolve $($ip)"
            }
        }
    }
}


Write-Log -Message "==================================================================================="
Write-Log -Message " TrafficAnalyzer-NameResolution"
Write-Log -Message "==================================================================================="

$serverlist = Get-Content -Raw -Path $InputFile | ConvertFrom-Json

Get-DnsClientGlobalSetting

Invoke-Lookup -Serverlist $serverlist
