$SecureString = ConvertTo-SecureString -String "password" -AsPlainText -Force 
$Credential = New-Object System.Management.Automation.PSCredential "username@azurechina.partner.onmschina.cn",$SecureString 
$conn=Connect-AzAccount -Environment AzureChinaCloud -Credential $Credential
$ResourceGroupName = "mygroup"
$location = "chinanorth3"
$AzVMS = Get-AzVM -ResourceGroupName $ResourceGroupName -Status|where {$_.Name -notlike "win*"}
$AzVMS|Stop-AzVM -NoWait -Confirm:$false -Force
