#脚本通过计划任务部署，重复间隔每1小时执行一次
#程序：C:\Windows\SysWOW64\WindowsPowerShell\v1.0\PowerShell.exe
#参数：-NonInteractive "C:\ps\new.ps1"
#获得源域PDC
$dcname = (Get-ADDomain -Identity source.com).pdcemulator
#将同步的帐户放到源域的安全组$pwdgroup
$pwdgroup = "pwdgroup"
#脚本日志路径
$logPath="c:\pwdlog\"
<#
$ofs = "`r`n"
$body = "Fetching event log started on " + (Get-Date) + $ofs
$command = @'
cmd.exe /C 'admt password /SD:"source.com" /SDC:"\\srv1.source.com" /SO:"mylab" /TD:"target.com" /TDC:"\\srv4.target.com" /PS:"srv1.source.com" /N'
'@
#>
#时间偏移1小时
$timeDiff = (Get-Date).AddHours(-1)


#函数获得密码被更新的帐户
   
function getUser{
    # getUser -timeDiff $timeDiff
    param(
    [datetime]$timeDiff
    )
    Invoke-Command  -Session $PSSession -ArgumentList $timeDiff,$pwdgroup -ScriptBlock {
    param([datetime]$timeDiff,[string]$pwdgroup)
    $results=@()
    #$1_Hours = (Get-Date).Adddays(-1)
    $groupDN = Get-ADGroup -Identity $pwdgroup| Select-Object -ExpandProperty DistinguishedName
    #获得1小时前密码更新的用户，并且该用户属于安全组$pwdgroup
    Get-ADUser -Filter {(pwdlastset -gt $timeDiff) -and (pwdlastSet -ne 0) -and (Memberof -eq $groupDN)} -Properties PasswordLastSet|
    ForEach-Object{
    $result = New-Object -TypeName PSObject -Property @{
                    Name   = $_.Name
                    PasswordLastSet = $_.PasswordLastSet
                }
    $results+=$result
    }
    return $results
    } 
} 


#写日志函数
#$Logfile = $logPath+$UserName+".log"
function WriteLog{
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $LogFile -value $LogMessage -Encoding UTF8
}
#WriteLog -LogString "abc"

$PSSession = New-PSSession -ComputerName $dcname -Name "updatepwd"
$content = getUser -timeDiff $timeDiff
Get-PSSession -Name "updatepwd"|Remove-PSSession


If ($content -ne $null){
    foreach($item in $content){
       # $Name = $item.Name
       # $PasswordLastSet = $item.PasswordLastSet
        $timeStamp = $item.PasswordLastSet
        $Logfile = $logPath+$item.Name+".log"
        $LogString = $item.Name +",source update passwd at: "+$timeStamp
        
        WriteLog -LogString $LogString
        #admt同步密码从旧域到新域
        Invoke-Command -ScriptBlock  {
           cmd.exe /C admt password /SD:"source.com" /SDC:"\\srv1.source.com" /SO:"mylab" /TD:"target.com" /TDC:"\\srv4.target.com" /PS:"srv1.source.com" /N $item.Name
           Start-Sleep -Seconds 2
        }
        WriteLog -LogString "update password on target finished"
    }
}


If ($content -ne $null){
    foreach($item in $content){
       # $Name = $item.Name
       # $PasswordLastSet = $item.PasswordLastSet
        Invoke-Command -ScriptBlock  {
           Get-ADUser $item.Name | Set-ADUser -ChangePasswordAtLogon $false 
        }
    }
}

