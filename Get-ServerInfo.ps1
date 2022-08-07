$servers = get-adcomputer -filter * -Properties * | select Name,OperatingSystem | ? {$_.OperatingSystem -match "Server"}
$array = @()
$Row="" | Select Server, Role, RoleName
foreach ($server in $servers){
write-host 'Processing '+ $server.Name
$Row="" | Select ServerName, Role, RoleName
$roleinfo = "" | select Name, DisplayName
$row.ServerName = $server.Name
#$roleinfo = invoke-command -computername $server.Name -erroraction SilentlyContinue {Get-WindowsFeature | Select DisplayName, Name, InstallState| ? {$_.InstallState -match "Installed" -and $_.Name -notmatch "NET.*|RSAT.*|PowerShell.*|WoW64.*|System.*|.*Defender|XPS.*|CMAK"} | select Name, DisplayName}| select Name, DisplayName
$roleinfo = Get-WindowsFeature -computername $server.Name -erroraction SilentlyContinue | Select DisplayName, Name, InstallState| ? {$_.InstallState -match "Installed" -and $_.Name -notmatch "NET.*|RSAT.*|PowerShell.*|WoW64.*|System.*|.*Defender|XPS.*|CMAK"} | select Name, DisplayName
$sqls = (Get-Service -ComputerName $server.Name -erroraction SilentlyContinue -Include '*SQL*' | ?{$_.DisplayName -match '\('}).DisplayName
$sqlparsed = ''
foreach($sql in $sqls){$sqlstring = ([regex]::match($sql, $regex).Groups[1]).toString(); if(!($sqlparsed -match $sqlstring)){$sqlparsed = $sqlparsed + ($sqlstring).ToString() + ", "}else{continue}}
if ($sqlparsed){$row.RoleName += @($sqlParsed);$row.Role += @("SQL")}
$row.Role += $roleinfo.Name
$row.RoleName += $roleinfo.DisplayName
$array +=$Row
}
#$array | select ServerName, RoleName -ExpandProperty ServerName,RoleName |ft
foreach ($r in $array)
{
if ($r.RoleName -like $null){}
else{
Write-Host "------------------------------------------`n"$r.ServerName"`n------------------------------------------"
Foreach ($rol in $r.RoleName){
write-host $rol
}
}
}
