### This git has websocket servers and clients for both Toon and python.

The Toon App has 1 Tile with 2 buttons. 

 - 1 Button for a client screen which talks to a websocket echo server. 
     The default server is a websocket server running on my Toon 2.
     This is reachable from the Internet so this should work out of the box.
     You can also use another server if you like. Maybe the python script below?
     The client sends a message when you click the screen.
     Every 5th message is flip.
     This makes the webserver send the message in reverse or
     just the way is was, after it receives flip again.

 - 1 Button for a websocket client and server in 1 screen.
     The server needs a setup action because it needs to open a firewall port
     of your choice. After entering a port your Toon will reboot to activate
     the port and your echo server will run like my echo server.
     Click the text area to send a message to the app itself and receive something back.
     You can, at the same time, also run a client on another computer. 
     A python echo client is available in socketechoclient.py.
     In the Apple App Store and Android Play Store you can also find clients.

You can install this Toon app manually without ToonStore :

 - Open an sftp tool like WinScp/Mozilla on Windows to browse to your Toon.
 - On your Toon go to /qmf/qml/apps and create a folder webSocket.
 - In that folder you put at least the qml files.
 - Restart the GUI. ( On your Toon go to > Settings > TSC > Restart GUI )
 - After that you can add a tile named webSocket.

Note on Toon firewall rules : 

In a Toon the firewall rules are in /set/default/iptables.conf.
In a rooted Toon there is a rule where port 22 is accepted for ssh access.
Activating the server by entering a valid portnumber >= 8000 will put a rule just before that rule to open your port.
When you change your port the rule with the old port number is removed and the new one is put in place.
Every time you change the port number your Toon has to reboot to get it activated.

There are 2 python scripts which I wrote on Lubuntu.

 - socketechoserver.py is a server as the name says. 
    It listens on all interfaces of your computer on port 8000.
    example : ./socketechoserver.py
    (make sure your firewall allows tcp traffic through port 8000)
        
  - socketechoclient.py is a client and takes some arguments :
    -s <socket server IP> -p <socket server port> [-i <interval> like 0.5] [-o yes : for only send ]
    Suppose your Toon has address 192.168.2.123 and listens on port 8000 you may try :
    example : ./socketechoclient.py -s 192.168.2.123 -p 8000
        
The python scripts are written for python 3 and use some modules you may need to install.
In case you receive errors on the imports of the modules just install them for python3 and rerun the script.


Thanks for reading and enjoy.
