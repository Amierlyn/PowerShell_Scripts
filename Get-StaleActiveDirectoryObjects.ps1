#### Edit for your Domain Controller ####
$inactiveCompsOU = "DC=contoso,DC=com"
$inactiveUsersOU = "DC=contoso,DC=com"

#### Edit where you want to save your CSV file to #####
$savetocsvcomputers = "C:\Users\USERS\Desktop\stale_computers.csv"
$savetocsvusers = "C:\Users\USERS\Desktop\stale_users.csv"

#### Do Not Modify ####
$todayDate = Get-Date
$compLogon = Search-ADAccount -AccountInactive -DateTime ((get-date).adddays(-90)) -ComputersOnly | Where {$_.LastLogonDate -ne "12/31/1600 4:00:00 PM" -and $_.LastLogonDate -ne $null} | Select Name,DistinguishedName,ObjectGUID,LastLogonDate
$userLogon = Search-ADAccount -AccountInactive -DateTime ((get-date).adddays(-90)) -UsersOnly | Where {$_.DistinguishedName -like "*OU=Users,*" -and $_.DistinguishedName -notlike "*OU=Users,OU=Generic*" -and $_.LastLogonDate -ne "12/31/1600 4:00:00 PM" -and $_.LastLogonDate -ne $null} | Select Name,DistinguishedName,ObjectGUID,LastLogonDate,samaccountname

Write-Host -Foreground Yellow -Background Black "Beginning computer search..."
ForEach ($computer in $compLogon) {
	$pingComp = Test-Connection $computer.Name -count 1 -quiet
	If ($pingComp -eq $false) {
		$computer | Select Name, LastLogonDate | Export-Csv -NoTypeInformation -Append -Path $savetocsvcomputers
	}
}

Write-Host -Foreground Yellow -Background Black "Beginning user search..."
$userLogon | Select Name, samaccountname, LastLogonDate | Export-Csv -NoTypeInformation -Append -Path $savetocsvusers
