function PoshMTR{

    param(
        $Target,
        $Timeout = 1000,
        $RetryCount = 10
    )

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

    # Here are all the discovered hosts
    # $hosts | ft

    # Continuous ping on all hosts along the route
    $retries = (1 .. $RetryCount)
    foreach ($try in $retries){

        $pingOptions.Ttl = 1
        $results = @()

        foreach ($address in $hosts){
            $pingReply = $ping.Send($address, $Timeout , $pingBuffer, $pingOptions)
            $pingOptions.Ttl +=1
            $results += $pingReply | select Status, Address, RoundtripTime, Buffer
        }
        Clear-Host
        Write-Host "### Packet $try ###"
        $results | ft Status, Address, RoundtripTime
    }
    Write-Host "Route was:"
    $hosts | ft
}