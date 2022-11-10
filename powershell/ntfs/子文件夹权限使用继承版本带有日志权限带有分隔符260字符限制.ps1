function recursive($path, $max, $level = 1)
{
    #Write-Host "$path" -ForegroundColor Red
    $global:arr += $path
    foreach ($item in @(Get-ChildItem $path -ErrorAction silentlycontinue))
    {
        if ($level -eq $max) { return }
        if ($item.Length -eq "1") # if it is a folder
        {
            #$newpath = "$path\$($item.Name)"
            $newpath = $item.FullName
            if($newpath.Length -gt 260){
                $newpath='\\?\'+$newpath
            }
            
            Get-ChildItem $newpath -ErrorAction SilentlyContinue 1>$null
            if ($? -ne $true){
                Write-Host $newpath -ForegroundColor Green
                
                $aclbackup = New-Object Object 
                
                
                $acl = Get-Acl $newpath
                
                $aclbackup | Add-Member -Name Path -Value $newpath -MemberType NoteProperty
                $aclbackup | Add-Member -Name Owner -Value $acl.Owner -MemberType NoteProperty
                $aclbackup | Add-Member -Name Access -Value (($acl.AccessToString -split '\r?\n') -join ";") -MemberType NoteProperty

                $aclbackup|Export-Csv -Path C:\logs\abc.csv -Encoding UTF8 -Append

                $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators","FullControl","ContainerInherit,ObjectInherit","None","Allow")
                $acl.SetAccessRule($AccessRule)
                $acl | Set-Acl $newpath
                
            }
            recursive $newpath $max ($level + 1)
        }
        else { # else it is a file
            #Write-Host "$path\$($item.Name)" -ForegroundColor Blue
            $global:arr +="$path\$($item.Name)"
            
        }
    }
}
$arr = @() # have to define this outside the function and make it global
$diracl=@()
recursive C:\share
#write-host $arr.count