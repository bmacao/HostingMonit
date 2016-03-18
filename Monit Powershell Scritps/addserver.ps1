#Gathering data from servers to monit
#One host per folder, in the current coding servers are coded at SRVx folder ( must be created before this step )

#mhost must be IP ( prefered ) or name to be resolved
$mhost = "94.46.178.8"

#mhost output file containing the IP address and server name as file name
#path can be updated, if changed monit scripts must be changed as well
$mhost | Out-File "C:\inetpub\wwwroot\admin\data\scr\SRV8\hostname.txt"

#deal and process host password with encryption for WinRM requests
#will present box to input password
$secure = read-host -AsSecureString 
$encrypted = convertfrom-securestring -secureString $secure -key (1..16)

#output encrypted password for the same folder as the hostname
$encrypted | set-content 'C:\inetpub\wwwroot\admin\data\scr\SRV8\pw.pw'



