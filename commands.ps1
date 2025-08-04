#
# Public functions = C64 commands
#

function LIST([string]$dirName)
{
    $midWidth = [int] (Get-Host).UI.RawUI.MaxWindowSize.Width - 4

    if ($dirName.Length -gt 0)
    {
        $folderName = [System.IO.Path]::GetDirectoryName($dirName).toUpper().split("\")[-1]
    }
    else
    {
        $folderName = (Get-Location).toString().toUpper().split("\")[-1]
    }

    -join("0 $e[44m$e[94m$e[7m", (CenterText $folderName ($midWidth - 6)), "$e[27m$e[0m")
    Get-ChildItem $dirName -directory | ForEach-Object { -join((LeftText ([math]::Round($_.Length/100)).ToString() 6), ' ', (RightText $_.name.toUpper() ($midWidth - 14) '"')) }
    Get-ChildItem $dirName -file .* | ForEach-Object { -join((LeftText ([math]::Round($_.Length/100)).ToString() 6), ' ', (RightText $_.name.toUpper() ($midWidth - 14) '"')) }
    Get-ChildItem $dirName -file *.* | ForEach-Object { if ($_.name.toUpper().Split('.')[0].Length -gt 0) { -join( (LeftText ([math]::Round($_.Length/100)).ToString() 6), ' ', (RightText ($_.BaseName.toUpper() -replace $_.Extension, '') ($midWidth - 14) '"'), ' ', $_.Extension.toUpper().TrimStart('.') ) } }
    -join((Get-PSDrive c).Free, " BLOCKS FREE.")
    "READY."
}

function SYS64738()
{
    "$e[0m"
    Clear-Host
    ""
    $line1 = "**** WINDOWS TERMINAL POWERSHELL V" + $PSVersionTable.PSVersion.Major + "." + $PSVersionTable.PSVersion.Minor + " ****"
    $line2 = " " + $mem + "K SYSTEM RAM " + $free + "000 BASIC BYTES FREE"

    CenterText $line1 ((Get-Host).UI.RawUI.MaxWindowSize.Width)
    " "
    CenterText $line2 ((Get-Host).UI.RawUI.MaxWindowSize.Width)
    " "
    "READY."
}

function LOAD([string]$inputLn)
{
    if ($inputLn -eq '$ 8')
    {
        "SEARCHING FOR $"
        Start-Sleep -Seconds 2
        "LOADING"
        Start-Sleep -Seconds 1
        "READY."
    }
    else
    {
        "SYNTAX ERROR"
    }
}

function EDIT($File)
{
    $File = $File -replace "\\", "/" -replace " ", "\ "

    bash -c "nano $File"
}

function RUN($File)
{
    Invoke-Item $File
}

function LET([string]$inputLn)
{
    $regex = "^\s*$varNameRegEx\s*=\s*$expressionRegEx\s*"

    if ($inputLn -notmatch $regex)
    {
        "SYNTAX ERROR"
    }
    else
    {
        $varName = $Matches[1]
        $varType = $Matches[2]
        $varCalculus = $Matches[3]
        $varValue = (_CalculateExpressionValue $varCalculus)
        Set-Variable -Name $varName -Value $varValue -Scope Global
        # TODO: Include Type also
    }
}

function PRINT([string]$inputLn)
{
    Write-Host (_CalculateExpressionValue $inputLn)
}

#
# Internal commands (should be hidden inside of a module)
#

$e = "$([char]27)"
$varNameRegEx = '([a-zA-Z]+)([\$|\%]?)' # returns name and type
$expressionRegEx = '\s*(\S+)\s*'        # returns expression

function _CalculateExpressionValue([string]$Expression)
{
    # TODO: Hide this in module
    while ($Expression -match $varNameRegEx)
    {
        $Expression = $Expression -replace $Matches[0], [string](Get-Variable -Name $Matches[1] -ValueOnly -Scope Global)
    }

    try
    {
        return (Invoke-Expression $Expression)
    }
    catch
    {
        "SYNTAX ERROR"
    }
}

function CenterText([string]$inputLine, [int]$textWidth, [string]$wrapChar)
{
    if (($inputLine.length + ($wrapChar.Length * 2)) -ge $textWidth)
    {
        return -join($wrapChar, $inputLine.Substring(0, $textWidth - 2 * $wrapChar.Length), $wrapChar)
    }
    else
    {
        $diff = ($textWidth + (2 * $wrapChar.Length)) - $inputLine.Length
        $spaceCount = [math]::Floor($diff / 2)
        $leadingSpaces = $(" " * $spaceCount)

        if (-join( $wrapChar, $leadingSpaces, $inputLine, $leadingSpaces, $wrapChar).Length -lt $textWidth)
        {
            return -join( $wrapChar, $leadingSpaces, $inputLine, $leadingSpaces, $wrapChar, " ")
        }
        else
        {
            return -join( $wrapChar, $leadingSpaces, $inputLine, $leadingSpaces, $wrapChar)
        }
    }
}

function LeftText([string]$inputLine, [int]$textWidth, [string]$wrapChar)
{
    if ($inputLine.length -ge $textWidth)
    {
        return -join($inputLine.Substring(0, $textWidth))
    }
    else
    {
        $diff = $textWidth - $inputLine.Length
        $leadingSpaces = $(" " * $diff)

        return -join($inputLine, $leadingSpaces)
    }
}

function RightText([string]$inputLine, [int]$textWidth, [string]$wrapChar)
{
    if (($inputLine.length + (2 * $wrapChar.Length)) -ge $textWidth - 1)
    {
        $trimmed = $textWidth - (2 * $wrapChar.Length)

        return -join($wrapChar, $inputLine.Substring(0, $trimmed - 2), $wrapChar, "  ")
    }
    else
    {
        $diff = $textWidth - ($inputLine.Length + (2 * $wrapChar.Length))
        $leadingSpaces = $(" " * $diff)

        return -join($wrapChar, $inputLine, $wrapChar, $leadingSpaces)
    }
}
