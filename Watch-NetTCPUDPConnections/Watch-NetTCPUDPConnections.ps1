function Watch-NetTCPUDPConnections {
    [Alias("netstat2")]
    [CmdletBinding()]
    param (
        # Delay in seconds between each test
        [int16]$Delay = 1,
        $logPath = "$env:TEMP\$($PSCmdlet.MyInvocation.MyCommand.Name)_$(Get-date -Format 'yyyyMMdd-HHmm').csv"
    )

    process {
        try{
            $reference = ""
            $comp = ""
            while($?){
                $difference = Get-LocalPorts
                $comp = Compare-Object -ReferenceObject $reference -DifferenceObject $difference -PassThru -Property Protocol,State,LocalAddress,LocalPort,RemoteAddress,RemotePort,ProcessID,ProcessName 
                if ($comp){
                    $comp
                    $comp | export-csv -Append -Path $logPath -NoTypeInformation
                    $reference = $difference
                }
                Start-Sleep -Seconds $Delay
            }
        }finally{
            Write-Host "Log file at:`n$logPath"
        }
    }
}
#-----------HELPER-FUNCTIONS---------------
function Get-LocalPorts{
    #Based on: https://github.com/adbertram/Random-PowerShell-Work/blob/master/Networking/Get-LocalPort.ps1
    $rawOutput = (netstat -ano | select -skip 4 | Select-String -NotMatch "\[") -replace "\s{2,}","|"
    $processes = Get-Process | Select-Object ID, ProcessName
    foreach ($line in $rawOutput) { 
        $out = @{
            'Protocol' = ''
            'State' = ''
            'LocalAddress' = ''
            'LocalPort' = ''
            'RemoteAddress' = ''
            'RemotePort' = ''
            'ProcessID' = ''
            'ProcessName' = ''
            'RegisteredDate' = "$(Get-date -Format 'yyyyMMdd-HHmmss')"
        }
        $columns = $line.split('|')
        $Out.Protocol = $columns[1]
        $Out.LocalAddress = $columns[2].Split(':')[0]
        $Out.LocalPort = $columns[2].Split(':')[1]
        $Out.RemoteAddress = $columns[3].Split(':')[0]
        $Out.RemotePort = $columns[3].Split(':')[1]
        if ($Out.Protocol -eq "UDP") {
            $Out.State = "Stateless"
            $out.ProcessID = $columns[4]
        }else{
            $out.State = $columns[4]
            $out.ProcessID = $columns[5]
        }
        $out.ProcessName = ($processes | ? {$_.id -eq $out.processID}).processName
        [pscustomobject]$Out | select registereddate, protocol, localAddress, localPort, remoteAddress, remotePort, processID, processName, state
    }
}