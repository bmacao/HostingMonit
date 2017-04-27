## Maintain control over the IIS and PHP processes over Hosting Servers

**The project is a active/passive monitor written in Powershell, it makes uses of WinRM for communication between monit server and all hosts available.**

**Features:**
- No load impact over requests do gathering data;
- Threading servers to speed up data requests;
- Data updated every 30 seconds ( may be change throught config file );
- Terminate w3pw and php-cgi.exe higher than the config value over monitor;
- All hosts credentials encrypted for extra security;
- Can be setup at private network avoiding public data exposing;
- Data presentation over multiple technologies;
- Current project presentation:
     - IIS website;
     - AngularJS;
     - Output data for presentation in JSON;
     - Alert on terminated PID by server;
- Monitor MailEnable queues over Plesk installation or single ;


**Initial Setup:**

- Unzip source content to master server ( host that will monitor all servers );

**Website: (if used the code provided for it)**
-create it at IIS ( default setup is at C:\inetpub\wwwroot\admin\ ) and copy content from folder "website" to it;

- Setup servers to watch through powershell script addserver.ps1 ( use ISE for speedup process and execution )

**Hosts:**
- Check if WinRM is running: get-service winrm
- Enable WinRM on all servers to watch ( if not running) : Enable-PSRemoting –force

The follow url can help in the setup if doubts remain:
https://technet.microsoft.com/en-us/magazine/ff700227.aspx

- Add rule to firewall permitting inbound traffic from master to hosts ( winRM rules or global );

**Monit ( master server ):**
- Run the Powershell script Monit.ps1 to start monitoring all servers configured earlier
