# tools
Some of the tools I've created that don't deserve their own place.. yet(?)

## Tools list

| Name | Category | Description |
| ---- | ----- | ----------- |
| [Watch-NetRoute](Watch-NetRoute) | Network | Traceroute with extra steps and statistics inspired by [MTR](https://en.wikipedia.org/wiki/MTR_(software)) |
| [Watch-NetConnection](Watch-NetConnection) | Network | Measure RTT for echo packet to target host(s) and show timestamp for each reply |
| [Measure-InternetBandwidth](Measure-InternetBandwidth) | Network | Internet bandwidth test |
| [Resolve-WhoIsData](Resolve-WhoIsData) | Network | Queries for [WHOIS](https://en.wikipedia.org/wiki/WHOIS) data for the target public IP
| [New-PasswordLink](New-PasswordLink) | Security | Create sharable links to passwords using https://pwpush.com

## How to use
Add `. <path to the file>\importTools.ps1` ([including the dot and space after it](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts?view=powershell-5.1#script-scope-and-dot-sourcing)) to your [powershell $profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-5.1) and all functions will load each time you start PoSH