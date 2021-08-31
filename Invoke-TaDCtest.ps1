# NOTE: This script is designed to run on Windows 2008 R2. This is reflected in the choice of Powershell commands.

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    $Server = ("localhost"),
    [Parameter(Mandatory = $false)]
    $Ports = (53, 88, 135, 389, 445, 636, 3268, 3269)
)

Write-Host "NOTE: This script assumes that all the defined DNS servers are also Domain Controllers. Avoiding any requirement to provide input to the script."

$NICs = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ErrorAction Stop | Where-Object { 
    $_.DNSServerSearchOrder -ne $null
}

$NICs | ForEach-Object { 
    foreach ($ip in $_.DNSServerSearchOrder) {
        foreach ($port in $Ports) {
            try { 
                $timestamp = Get-Date
                $result = New-Object System.Net.Sockets.TcpClient($ip, $port)
                Write-Host "Success: Response from $ip on port $port ($($timestamp))" -ForegroundColor Green

            }
            catch {
                Write-Host "Failure: NO response from $ip on port $port ($($timestamp))" -ForegroundColor Red
            }
        }
    }
}
