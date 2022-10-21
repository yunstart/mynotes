Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
#Connect-AzAccount -Environment AzureChinaCloud
$ResourceGroupName = "MyRG"
$keyword = "lab"
$SecureString = ConvertTo-SecureString -String "xxxxxxxxx" -AsPlainText -Force 
$Credential = New-Object System.Management.Automation.PSCredential "xx@xx.com",$SecureString 
$conn=Connect-AzAccount -Environment AzureChinaCloud -Credential $Credential 
$Subscription=Get-AzSubscription
$SubscriptionId=$Subscription.Id
$location = "chinaeast2";
#$Credential.GetNetworkCredential().Password 
$AzVMS = Get-AzVM -ResourceGroupName $ResourceGroupName -Status
foreach($vm in $AzVMS){
$vm|Stop-AzVM -StayProvisioned -NoWait -Confirm:$false -Force
}
$AzVMS=Get-AzVM -ResourceGroupName $ResourceGroupName -Status|where {$_.Name -notlike "**"}
#Start-Sleep 240
foreach($vm in $AzVMS){
    if($vm.PowerState -like "*stopped*"){
        $snapshotdisk = $vm.StorageProfile
        $OSDiskSnapshotConfig = New-AzSnapshotConfig -SourceUri $snapshotdisk.OsDisk.ManagedDisk.id -CreateOption Copy -Location $location -OsType Windows
        $snapshotNameOS = "$($snapshotdisk.OsDisk.Name)_snapshot_$(Get-Date -Format yyMMdd)"
 
        # OS Disk Snapshot
 
            try {
                New-AzSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName $snapshotNameOS -Snapshot $OSDiskSnapshotConfig -ErrorAction Stop
            } catch {
                $_
            }
        # Data Disk Snapshots 
 
        Write-Output "VM $($vm.name) Data Disk Snapshots Begin"
        $dataDisks = ($snapshotdisk.DataDisks).name
        foreach ($datadisk in $datadisks) {
            $dataDisk = Get-AzDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $datadisk
            Write-Output "VM $($vm.name) data Disk $($datadisk.Name) Snapshot Begin"
            $DataDiskSnapshotConfig = New-AzSnapshotConfig -SourceUri $dataDisk.Id -CreateOption Copy -Location $Location
            $snapshotNameData = "$($datadisk.name)_snapshot_$(Get-Date -Format ddMMyy)"
            New-AzSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName $snapshotNameData -Snapshot $DataDiskSnapshotConfig -ErrorAction Stop
            Write-Output "VM $($vm.name) data Disk $($datadisk.Name) Snapshot End"   
        }
 
        Write-Output "VM $($vm.name) Data Disk Snapshots End" 
    }
}
Get-AzSnapshot -ResourceGroupName $ResourceGroupName|Sort -Property TimeCreated -Descending|Select Name -First 10

#Grant-AzSnapshotAccess 
