function New-PasswordLink{
    [Alias("pwpush")]
    [CmdletBinding(DefaultParameterSetName='ProvidedPassword')]
    param (
        [Parameter(Mandatory=$true,
        ParameterSetName = 'ProvidedPassword')]
        $Password = '',

        [Int]
        [ValidateRange(5,64)]
        [Parameter(ParameterSetName = 'GeneratedPassword')]
        $PasswordLength = 12,

        [Int]
        [ValidateScript({if ($_ -ge 0 -and $_ -le $PasswordLength){$true}else{$false}})]
        [Parameter(ParameterSetName = 'GeneratedPassword')]
        $MinimumNumberOfNonAlphaCharacters = 0,

        [Int]
        [ValidateRange(1,90)]
        $ExpireInDays = 7,
        
        [Int]
        [ValidateRange(1,100)]
        $ExpireInViews = 5,
        
        [Switch]
        $Deletable = $true
    )
    
    # Generate password if not specified
    if ($Password -eq ''){
        Add-Type -AssemblyName System.Web
        $Password = [System.Web.Security.Membership]::GeneratePassword($PasswordLength, $MinimumNumberOfNonAlphaCharacters)
    }

    # Prepare and fill body
    $body = @{
        'payload'             = $Password
        'expire_after_days'   = $ExpireInDays
        'expire_after_views'  = $ExpireInViews
    }

    # Dunno why, but any value passed to this parameter is considered on, so to turn it "off", you don't add the parameter
    if ($Deletable) {
        $body | Add-Member 'deletable_by_viewer' 'on'
    }

    # Prepare result object
    $result = @{
        URI = 'https://pwpush.com/p/'
        Password = $Password
    }

    # Post and retrieve link
    $result.URI += (Invoke-RestMethod -Uri "https://pwpush.com/p.json" -Body ($body | ConvertTo-Json) -Method Post -ContentType "application/json").url_token
    
    # Return result
    $result
}