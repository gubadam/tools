function Measure-InternetBandwidth{
    [Alias("speedtest")]
    Param() # Alias only works if there's param block

    # Setup
    $webClient = New-Object System.Net.WebClient
    $file = "C:\Windows\temp\PoshSpeedTest.tmp"

    # Measuring download
    Write-Progress -Activity "Measuring bandwith" -Status "Download test"
    [Scriptblock]$command = {$webClient.DownloadFile('http://speedtest.tele2.net/10MB.zip',$file)}
    "Download: {0:N2} Mbit/sec" -f ((10/(Measure-Command -Expression $command).TotalSeconds)*8)

    # Measuring upload
    Write-Progress -Activity "Measuring bandwith" -Status "Upload test"
    [Scriptblock]$command = {$webClient.UploadFile('http://speedtest.tele2.net/upload.php',$file)}
    "Upload: {0:N2} Mbit/sec" -f ((10/(Measure-Command -Expression $command).TotalSeconds)*8)

    # Cleaning
    Remove-Item $file
}