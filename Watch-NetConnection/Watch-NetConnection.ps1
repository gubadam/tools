function Watch-NetRoute{
    [Alias("ping2")]
    param(
        [Parameter(mandatory=$true)]
        $Targets = @(),
        $Timeout = 1000,
        $RetryCount = 10,
        [Switch] $Repeat,
        [Switch] $NoNewWindow
    )

    if ($Targets.Count -gt 1){
        foreach($target in $Targets){
            $arguments = if ($NoNewWindow){""}else{"-NoExit  "}
            Start-Process -FilePath "powershell" -ArgumentList "$arguments-Command `"& {Watch-NetRoute -Targets '$target' -Timeout $Timeout -RetryCount $RetryCount}`"" -NoNewWindow:$NoNewWindow
        }
    }else{
        $target = $Targets

        # Setup ping
        $ping = New-Object -TypeName System.Net.NetworkInformation.Ping
        $pingOptions = New-Object -TypeName System.Net.NetworkInformation.PingOptions
        $pingReply = ""
        $pingBuffer = [System.Byte[]]::CreateInstance([System.Byte],64) # important to set to 64 bytes, as some hosts ignore 32 byte echo requests (default) and you get no info from that
        $pingOptions.Ttl = 64

        # Ping set ammount or repetitively
        while($RetryCount -ne 0 -or $Repeat){
            $output = "$(get-date -Format 'yyyy/MM/dd-HH:mm:ss.fff') | Echo $target |"
            $pingReply = $ping.Send($target, $Timeout , $pingBuffer, $pingOptions)
            if ($pingReply.Status -eq "Success"){
                Write-Host "$output RTT $($pingReply.RoundtripTime)ms"
            }else{
                Write-Host "$output $($pingReply.Status)"
            }
            Start-Sleep -Milliseconds ($Timeout-$pingReply.RoundtripTime)
            $RetryCount--
        }

        # TODO statistics
        Write-Host "Finished pinging $target"
    }
}