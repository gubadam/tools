function PoshSpeedTest{

    # Setup
    $WebClient = New-Object System.Net.WebClient

    # Measuring download
    Write-Progress -Activity "Measuring bandwith" -Status "Download test"
    [Scriptblock]$Command = {$WebClient.DownloadFile('http://speedtest.tele2.net/10MB.zip',"$(Get-Location)\PoshSpeedTest.tmp")}
    "Download: {0:N2} Mbit/sec" -f ((10/(Measure-Command -Expression $Command).TotalSeconds)*8)

    # Measuring upload
    Write-Progress -Activity "Measuring bandwith" -Status "Upload test"
    [Scriptblock]$Command = {$WebClient.UploadFile('http://speedtest.tele2.net/upload.php',"$(Get-Location)\PoshSpeedTest.tmp")}
    "Upload: {0:N2} Mbit/sec" -f ((10/(Measure-Command -Expression $Command).TotalSeconds)*8)

    # Cleaning
    Remove-Item "$(Get-Location)\PoshSpeedTest.tmp"
}