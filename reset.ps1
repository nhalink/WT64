"LOADING PLEASE WAIT ..."
$e = "$([char]27)"
$mem = [regex]::Match((wmic OS get TotalVisibleMemorySize /Value), '[0-9]+').Value + ''
$free = [regex]::Match((wmic OS get FreePhysicalMemory /Value), '[0-9]+').Value + ''

# This will display READY.\n as prompt
# function prompt {"READY.`n"}
function prompt {"`r"}

$scriptRoot = Split-Path -parent $PSCommandPath
. "$scriptRoot\commands.ps1"

SYS64738
