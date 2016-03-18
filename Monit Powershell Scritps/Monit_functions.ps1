#Function to gather all IIS process running on given server
#Receives IP address or hostname ( must resolve DNS ) and Password pre-encrpyted
#Returns list of process with ID and load for each

function IISw3pw ($serv,$passwd){
	
	$Servers = "$serv"
    $Conneted= "none"
    
    $cred= New-Object System.Management.Automation.PSCredential ("administrator", $passwd )
	$Sessions = New-PSSession -ComputerName $Servers -Credential $cred
	$block = { 
        $aux = Get-Process w3wp | Select -ExpandProperty Id
        $count = $aux.Count 
        $t1 = @{}
        $t1.Add('id',$count)
        foreach ($id in $aux ){     
        $tt =Get-WmiObject -Query 'Select * from Win32_PerfFormattedData_PerfProc_Process '| Select Name,IDProcess, @{Name='CPU(p)';Expression={$_.PercentProcessorTime}} |where {$_.'IDProcess' -eq "$id" }
        $t1.Add($id, ($tt | Select -ExpandProperty 'CPU(p)' ))
       } 
       return $t1
       }

    $list =  Invoke-Command -Session $Sessions -ScriptBlock $block
    remove-PSSession -Session $Sessions
    return $list
	
}

#Function to gather all PHP process running on given server
#Receives IP address or hostname ( must resolve DNS ) and Password pre-encrpyted
#Returns list of process with ID and load for each

function IISphp ($serv,$passwd){
	
	$Servers = "$serv"
    $Conneted= "none"
    
    $cred= New-Object System.Management.Automation.PSCredential ("administrator", $passwd )
	$Sessions = New-PSSession -ComputerName $Servers -Credential $cred
    #$res = @{}
	$block = { 
        $aux = Get-Process php-cgi | Select -ExpandProperty Id
        $count = $aux.Count 
        $t1 = @{}
        $t1.Add('id',$count)
        foreach ($id in $aux ){     
        $tt =Get-WmiObject -Query 'Select * from Win32_PerfFormattedData_PerfProc_Process '| Select Name,IDProcess, @{Name='CPU(p)';Expression={$_.PercentProcessorTime}} |where {$_.'IDProcess' -eq "$id" }
        $t1.Add($id, ($tt | Select -ExpandProperty 'CPU(p)' ))
       } 
       return $t1
       
    }
    $res = Invoke-Command -Session $Sessions -ScriptBlock $block
    remove-PSSession -Session $Sessions
	return $res
}

#Function to process expections
#Receives IP address or hostname ( must resolve DNS ) and Password pre-encrpyted
#Returns list of process with ID for skip
function IISw3pwex ($serv,$passwd){
	
	$Servers = "$serv"
    $Conneted= "none"
    
    $cred= New-Object System.Management.Automation.PSCredential ("administrator", $passwd )
	$Sessions = New-PSSession -ComputerName $Servers -Credential $cred
	$block = { 

        import-module 'webAdministration' 
        Set-Location IIS:\
       
       
       $auxm = C:\Windows\System32\inetsrv\appcmd.exe list wp
       $torem=@()
       $mua = $aux -split (" ")
       foreach($iiswp in $auxm){
       #Excpetions if needed are processed here, it will update proccess array obtained in current data request from host
       #Excpetions are for IIS proccess only and by app pool name ( real or parcial )
        if ($iiswp -like "*MailEnableAppPool*") {
       $gus = $iiswp.Split('"')
       $torem+=($gus[1])     
       }

       }

       return $torem
       }

    $list =  Invoke-Command -Session $Sessions -ScriptBlock $block
    remove-PSSession -Session $Sessions
    return $list

}

#Function to kill PID which passws by the limit parameter, given by checkAbuse function
#Receives PID, IP address or hostname ( must resolve DNS ) and Password pre-encrpyted
#Returns nothing but kills PID at specific server

function killtask($task,$serv,$passwd){
	$task1 = $task 
    $Servers = "$serv"
    $Conneted= "none"
    
    $cred= New-Object System.Management.Automation.PSCredential ("administrator", $passwd )
	$Sessions = New-PSSession -ComputerName $Servers -Credential $cred
	$block = { 
        param ($taska)
        #Get-Process
        
        taskkill /f /pid $taska
        
            
    } 

    Invoke-Command -Session $Sessions -ScriptBlock $block -ArgumentList $task1
	remove-PSSession -Session $Sessions
}

#Function to check each PID given from array obtained from server and lunck taskkill if above pre-determined limit
#Receives array of PIDs from server, IP address or hostname ( must resolve DNS ) and Password pre-encrpyted
#Lunch taskkill if match
function checkAbuse($abuse,$serv){
   $abuse.Remove('id')
   $srv = $serv
   
   $myArray = @()
   foreach ($check in $abuse.GetEnumerator() ){
      if($check.Value -gt 50){
      $OFS = "`n"
      $send2file= "Headshot on pid "+ $check.Key +" at server "+$srv + $OFS
      $send2log= "killed pid "+ $check.Key +" on server "+$srv 
      #generate files to fire data presentation over website - PID terminaded and hostname
      $send2file | Add-Content C:\inetpub\wwwroot\admin\data\abuses\abuse.html
      $send2log | Add-Content C:\inetpub\wwwroot\admin\data\abuses\log.txt
      $myArray += $check.Key
      start-sleep 3
      Remove-Item C:\inetpub\wwwroot\admin\data\abuses\abuse.html
      }else{
      #Write-Output "Nothing to do!"
      }
   
   }
   return $myarray
}

#Function sum all data from given server ( array ) , number of processes and load ( %)
#Receives array of PID and load
#Returns sum of processes and total load (%)

function loadsum($loads){
  $loads.Remove('id')
  $sum=0
  foreach ($item in $loads.GetEnumerator() ){
    $sum+= $item.Value
  }
  
  return $sum
}

#Function to create json file for web monitoring app
#Receives pre-treated data from server
#Returns JSON data for server

function jsonOut($a,$b,$c,$d,$e,$f,$g,$h,$MO,$MI){

if($b -gt 200 -Or $e -gt 200){
    $aux = "red"
    $bla = @"
{
    "id": "$h",
    "IIS": "$a $b% $c",
    "PHP": "$d $e% $f",
    "MailI": "Inbound $MI",
    "MailO": "Outbound $MO",
    "serverIP": "$g",
    "class": "$aux"
 },
"@
return $bla
  }

if($b -gt 100 -Or $e -gt 100){
    $aux = "orange"
    $bla = @"
{
    "id": "$h",
    "IIS": "$a $b% $c",
    "PHP": "$d $e% $f",
    "MailI": "Inbound $MI",
    "MailO": "Outbound $MO",
    "serverIP": "$g",
    "class": "$aux"
 },
"@
return $bla
  }

$bla = @"
{
    "id": "$h",
    "IIS": "$a $b% $c",
    "PHP": "$d $e% $f",
    "MailI": "Inbound $MI",
    "MailO": "Outbound $MO",
    "serverIP": "$g",
    "class": "green"
 },
"@

return $bla
}

function skip($aux1,$aux2){
foreach ($check in $aux1) {
    foreach ($chec in $aux2.GetEnumerator() ){
     $aux2.Remove($chec)
  }
  }
  return $aux2
}

#Mailenable queue control
function MailQueues($serv,$passwd){
	
	$Servers = "$serv"
    $Conneted= "none"
    
    $cred= New-Object System.Management.Automation.PSCredential ("administrator", $passwd )
	$Sessions = New-PSSession -ComputerName $Servers -Credential $cred
    
	$block = { 

        
        $countM= @()

        if (Test-Path "C:\Program Files (x86)\Mail Enable\Queues\SMTP\Outgoing\Messages\" ){
        $filepathO = "C:\Program Files (x86)\Mail Enable\Queues\SMTP\Outgoing\Messages\"
        }else{
        $filepathO =  "C:\Program Files (x86)\Parallels\Plesk\Mail Servers\Mail Enable\Queues\SMTP\Outgoing\Messages\"
        }

        if (Test-Path "C:\Program Files (x86)\Mail Enable\Queues\SMTP\Inbound\Messages\" ){
        $filepathI = "C:\Program Files (x86)\Mail Enable\Queues\SMTP\Inbound\Messages\"
        }else{
        $filepathI =  "C:\Program Files (x86)\Parallels\Plesk\Mail Servers\Mail Enable\Queues\SMTP\Inbound\Messages\"
        }

        $filetypeO = "*.MAI"
        $file_countO = [System.IO.Directory]::GetFiles("$filepathO", "$filetypeO").Count

        
        $filetypeI = "*.MAI"
        $file_countI = [System.IO.Directory]::GetFiles("$filepathI", "$filetypeI").Count
        
        $countM+=$file_countO
        $countM+=$file_countI
        
       return $countM
       
    }
    $res = Invoke-Command -Session $Sessions -ScriptBlock $block
    remove-PSSession -Session $Sessions
	return $res
}