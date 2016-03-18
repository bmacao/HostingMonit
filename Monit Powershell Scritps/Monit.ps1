Import-Module .\Monit_functions.ps1



#Main function og monitoring, endless loop
#It works based on workflow and Parallel data gathering so it finishes faster instead sequencial, server by server

while($true){

workflow monit {
   #Load list of servers to functions from folder to variable
   $dir1= "C:\inetpub\wwwroot\admin\data\scr\" 
   $list1 =Get-ChildItem -Path "C:\inetpub\wwwroot\admin\data\scr\" | Where-Object -filterscript {$_.PSIsContainer} | Foreach-Object {$_.Name} 
   $lp = 0

   #start parallel threatment of server list gathering all information of services
ForEach -Parallel ($tc in $list1 ){
   $workflow:lp++
   $tcname = $dir1+$tc
   $capt = Get-ChildItem $tcname -filter "*.txt"
   $gethost = (Get-Item $tcname"\"$capt).BaseName
   $capt1 = Get-ChildItem $tcname -filter "*.pw"
   $sho = Get-Content "$tcname\$capt"
   
   $secure2 = get-content "$tcname\$capt1" | convertto-securestring -key (1..16)
   
   $outiis = IISw3pw $sho $secure2
   $outphp = IISphp $sho $secure2

   $aux1 = IISw3pwex $sho $secure2
   
   $outiistr = skip $aux1 $outiis
   
   $biis = checkAbuse $outiistr $gethost
   $bphp = checkAbuse $outphp $gethost   
   
   $cn = $outiis.Get_Item('id')
   $lo = loadsum($outiis) 
   $cnt = $outphp.Get_Item('id') 
   $lod =loadsum($outphp) 
   
   foreach ($eleiss in $biis){
      killtask $eleiss $sho $secure2
   }

   foreach ($elephp in $bphp){
      killtask $elephp $sho $secure2
   }

   $MailCount = @()
   $MailCount = MailQueues $sho $secure2

   $newJson = jsonOut 'iis' $lo $cn 'php' $lod $cnt $gethost $workflow:lp $MailCount[0] $MailCount[1]
   $newJson | Out-File C:\inetpub\wwwroot\admin\data\temp\temp$tc.json
   
   $workflow:lp++

} 

}

   monit -AsJob | Wait-Job | Out-Null
   
  
   #Final treatment of data to create a sing JSON file for app
   $dir = "C:\inetpub\wwwroot\admin\data\temp\"
  
   $topfile = "["
   $topfile | Out-File C:\inetpub\wwwroot\admin\data\data.json
   Get-Content C:\inetpub\wwwroot\admin\data\temp\temp* | Add-Content C:\inetpub\wwwroot\admin\data\data.json
   Add-Content C:\inetpub\wwwroot\admin\data\data.json "]"

   $gfh = Get-Content "C:\inetpub\wwwroot\admin\data\data.json"
   $outfile = "C:\inetpub\wwwroot\admin\data\data.json"
   $counting = $gfh.Length
   $cog = $counting-1 
   $gfh |   ForEach-Object { if ($_.ReadCount -eq $cog) { $_ -replace ',','' } else { $_  }   } |   Set-Content $outfile
   Remove-Item C:\inetpub\wwwroot\admin\data\temp\*.json

   #Give servers some break and wait 30 seconds for another data gathering round
   Start-Sleep -S 30
}
