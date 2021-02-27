function Start-ProcessAsAdmin{
    [Alias("runasAdmin")]
    <#
    .SYNOPSIS
        Run a program with administrator permission
    .DESCRIPTION
        Why? Because aliases can't have parameters (or I don't know how to acomplish that in Posh 5.1) and I want to default it to posh and be able to override it as needed
    #>
    param(
        $FilePath = "powershell"
    )
    Start-Process $FilePath -Verb runas
}