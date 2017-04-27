**Initial Setup:**

- Unzip source content to master server ( host that will monitor all servers );

**Website:** (if used the code provided for it)
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

