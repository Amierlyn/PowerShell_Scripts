##### Import AD module ####
Import-Module ActiveDirectory

#### Silently Continue without Prompts ####
$ErrorActionPreference = "SilentlyContinue"

#### Update for your name of your domain/active directory ####
$searchbase = "DC=contoso,DC=com"
$EntGroups = "OU=Groups,DC=contoso,DC=com"
#### Do Not Edit ####
$groups = Get-ADGroup -Properties Name -Filter * -searchbase $EntGroups

#### Update if for your OU container that you want to put the disabled object and if you want to change the thresh hold for the days ####
$inactiveOU = "OU=Disabled,DC=contoso,DC=com"
$Days = (Get-Date).AddDays(-90)

#### Do Not Edit ####
$computers = Get-ADComputer -Properties * -Filter {LastLogonDate -lt $Days} -SearchBase $searchbase
$DisabledComps = Get-ADComputer -Properties Name,Enabled,LastLogonDate -Filter {(Enabled -eq "False" -and LastLogonDate -lt $Days)} -SearchBase $inactiveOU

##### Move inactive computer accounts to your inactive OU ####
foreach ($computer in $computers) {
	Set-ADComputer $computer -Location $computer.LastLogonDate | Set-ADComputer $computer -Enabled $false
	Move-ADObject -Identity $computer.ObjectGUID -TargetPath $inactiveOU
	#Remove group memberships
	foreach ($group in $groups) {
		Remove-ADGroupMember -Identity $group -Members $computer.ObjectGUID -Confirm:$false
	}
}
