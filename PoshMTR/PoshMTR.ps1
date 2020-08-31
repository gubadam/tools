function PoshMTR{

    param(
        [Parameter(mandatory=$true)]
        $Target,
        $Timeout = 1000,
        $RetryCount = 10
    )

    # Used for updating the display instead of re-drawing
    $originalCursorPosition = $host.UI.RawUI.CursorPosition

    # Setup ping
    $ping = New-Object -TypeName System.Net.NetworkInformation.Ping
    $pingOptions = New-Object -TypeName System.Net.NetworkInformation.PingOptions
    $pingReply = ""
    $pingBuffer = [System.Byte[]]::CreateInstance([System.Byte],64) # important to set to 64 bytes, as some hosts ignore 32 byte echo requests (default) and you get no info from that
    $pingOptions.Ttl = 1

    # Discover hosts along the route
    $hosts = @()
    do {  
        $pingReply = $ping.Send($Target, $Timeout , $pingBuffer, $pingOptions)
        $pingOptions.Ttl +=1
        $address = $pingReply.Address.IPAddressToString
        $hosts += if ($address -ne $null) {$address} else {"Non-reachable"}
    } while ($pingReply.Status -ne "Success")

    # Setup a result object
    $results = @()
    foreach ($_ in 0..($hosts.Length-1)){
        $results += [PSCustomObject]@{
            ID = $_
            Host = $hosts[$_]
            Loss = "0%"
            Sent = 0
            Rcvd = 0
            Lost = 0 
            Last = 0
            Sum = 0
            Avrg = 0
            Best = 0
            Wrst = 0
        }
    }

    # Continuous ping on all hosts along the route
    $retries = (1 .. $RetryCount)
    foreach ($try in $retries){
        $pingOptions.Ttl = 1
        foreach ($_ in 0..($hosts.Length-1)){
            if ($hosts[$_] -ne "Non-reachable"){
                $pingReply = $ping.Send($hosts[$_], $Timeout , $pingBuffer, $pingOptions)
                $results[$_].Sent++
                if ($pingReply.Status -eq "Success"){
                    $results[$_].Rcvd++
                    $results[$_].Last = $pingReply.RoundtripTime
                    $results[$_].Sum += $pingReply.RoundtripTime
                    if ($results[$_].Best -gt $pingReply.RoundtripTime -or $try -eq 1) {$results[$_].Best = $pingReply.RoundtripTime}
                    if ($results[$_].Wrst -lt $pingReply.RoundtripTime) {$results[$_].Wrst = $pingReply.RoundtripTime}
                    $results[$_].Avrg = [math]::Round($results[$_].Sum/$results[$_].Rcvd,1)        
                }else{
                    $results[$_].Lost++
                }
                $results[$_].Loss = "$([math]::Round($results[$_].Lost*100/$results[$_].Sent,1))%"
                $results[$_].Loss = $results[$_].Lost/$results[$_].Sent
            }else{
                $results[$_].Loss = 1
            }
            $pingOptions.Ttl +=1
        }

        # Clear display
        $host.UI.RawUI.CursorPosition = $originalCursorPosition
        foreach ($_ in (0..$hosts.Length)){
            Write-Host "`n"
        }

        # Display output
        $host.UI.RawUI.CursorPosition = $originalCursorPosition
        $results | ft   ID, 
                        Host,  
                        @{Label="Loss"; Expression={"{0:p1}" -f $_.Loss}}, 
                        Sent, 
                        Last, 
                        @{Label="Avrg"; Expression={"{0:f1}" -f $_.Avrg}}, 
                        Best, 
                        Wrst
    }
}