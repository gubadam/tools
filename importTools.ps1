# Find all PoSH scripts in current and child directories
$scriptFiles = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.ps1"
foreach ($file in $scriptFiles.FullName){
    # If not the the running script, dot source the script 
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts?view=powershell-5.1#script-scope-and-dot-sourcing
    if ($PSCommandPath -notlike $file){
        . $file
    }
}