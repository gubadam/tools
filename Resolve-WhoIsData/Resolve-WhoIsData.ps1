function Resolve-WhoIsData{
    [Alias("whois")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] $IPAddress
    )
    # TODO validate if IP address, if not - lookup dns name, if error - throw error
    # Pattern to validate ("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")

    # Setup
    $baseURI = 'http://whois.arin.net/rest/ip'
    $headers = @{"Accept" = "application/xml"}
    $result = ''

    # Execute query
    $result = Invoke-RestMethod -Uri $baseURI/$IPAddress -Headers $headers -Method Get
    
    # Build resulting object
    [pscustomobject]@{
        PSTypeName             = "WhoIsResult"
        IP                     = $IPAddress
        Name                   = $result.net.name
        RegisteredOrganization = $result.net.orgRef.name
        City                   = (Invoke-RestMethod $result.net.orgRef.'#text').org.city
        StartAddress           = $result.net.startAddress
        EndAddress             = $result.net.endAddress
        NetBlocks              = $result.net.netBlocks.netBlock | foreach-object {"$($_.startaddress)/$($_.cidrLength)"}
        Updated                = $result.net.updateDate -as [datetime]
    }

    # Return last object by default
}