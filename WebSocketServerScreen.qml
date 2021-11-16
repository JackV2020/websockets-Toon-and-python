import QtQuick 2.1
import qb.components 1.0
import QtWebSockets 1.1
import BxtClient 1.0
import FileIO 1.0

// https://doc.qt.io/qt-5/qml-qtwebsockets-websocketserver.html

Screen {
    id                          : socketServerScreen
    screenTitle                 : qsTr(me)

// ---------------------------------------------------------------------

    property string me          : "Websocket Server Screen"

    property bool flip          : false
    
    property int clickCounter   : 0
    
    property string clientMessage : ""
    property string serverMessage : ""

// reboot
    
	property string configMsgUuid : ""

// iptables 

    property int oldserverport

    property string configFile : "file:///etc/default/iptables.conf"
    property variant ipTablesContent : []

    FileIO {
        id: myFile
        source: configFile
        onError: console.log(msg)
    }

// --------------------------------------------------------------------- 
    
    onVisibleChanged: {
        if (visible) {

/*
        
            getIPTables()

            listIPTables()

            checkIptablesPort(app.serverPort)
            checkIptablesPort(80)
            checkIptablesPort(22)
            closeIPTablesPort(8000)
            closeIPTablesPort(80)
            openIPTablesPort(1234)

            listIPTables()

            saveIPTables()
*/

            if  (server.message == undefined)  {
                buildScreenText("")
            } else {
                buildScreenText(server.message)
            }
            clickCounter = 0
            WebSocketServer.host=app.serverAddress
            WebSocketServer.port=app.serverPort
        }
    }

// ---------------------------------------------------- reboot functions

// When you change the server port that port needs to open in iptables
// so close old port, open new port and reboot
 
	function rebootToon() {
		var restartToonMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, configMsgUuid, "specific1", "RequestReboot");
		bxtClient.sendMsg(restartToonMessage);
	}

	BxtDiscoveryHandler {
		id: configDiscoHandler
		deviceType: "hcb_config"
		onDiscoReceived: {
			configMsgUuid = deviceUuid
		}
	}

// --------------------------------------------------- iptables functions

    function getIPTables() {
  		var currentIPTables = new XMLHttpRequest();
        
        currentIPTables.onreadystatechange = function() {

            if (currentIPTables.readyState == XMLHttpRequest.DONE) {

                ipTablesContent = currentIPTables.responseText.split('\n')
			}
		}
        currentIPTables.open("GET", configFile, false);
        currentIPTables.send();    
    }
    
    function checkIptablesPort(port) {

        var lineNumberIPTables = -1

        var lookfor = "-A HCB-INPUT -p tcp -m tcp --dport "+port+" -"

        for (var i = 0 ; i < ipTablesContent.length - 1; i++ ) {
            if ( ipTablesContent[i].indexOf(lookfor) === 0 ) { app.log('found  : '+lookfor+" @ "+i) ; lineNumberIPTables = i }
        }
        return lineNumberIPTables
	}

    function closeIPTablesPort(port) {

        var linenumber = checkIptablesPort(port)    

        app.log("remove line : "+linenumber+" for port : "+port)
        if ( linenumber > -1 ) {
// remove array entry linenumber
            ipTablesContent.splice(linenumber, 1)
        }
    }

    function listIPTables() {
        for (var i = 0 ; i < ipTablesContent.length - 1; i++ ) {
            app.log("line " + i +"/" + ipTablesContent.length + " : >" + ipTablesContent[i]+"<")
        }
    }
    
    function saveIPTables() {

        var ipTablesContentNew = ""
        for (var i = 0 ; i < ipTablesContent.length - 1 ; i++ ) {
            ipTablesContentNew = ipTablesContentNew + ipTablesContent[i] +"\n"
        }
        var newIPTables = new XMLHttpRequest();
        newIPTables.onreadystatechange = function() {
            var dummy = 1
        }
        newIPTables.open("PUT", configFile, false);
        newIPTables.send(ipTablesContentNew);
        newIPTables.close;
    }

    function openIPTablesPort(port) {

        var linenumber = checkIptablesPort(port)    

        if (linenumber == -1 ) {

            var insertEntry = checkIptablesPort(22)
// insert array entry linenumber
            ipTablesContent.splice(insertEntry, 0, "-A HCB-INPUT -p tcp -m tcp --dport "+port+" -j ACCEPT")

        }
    }
    
// --------------------------------------------------------------------- 

    function buildScreenText(message) {
        messageBox.text = "Click to send a message or send a message from any client to :"
                        +"\nws://<my-ip>:" + app.serverPort + " (where my-ip is my real ip, not 0.0.0.0 or 127.0.0.1)"
                        +"\n\nUse my socketechoclient.py or an Android APP or another Toon or..."
                        +"\nSend the message flip to toggle the way the server answers"
                        + "\n\nSent by click on screen : " + clientMessage
                        + "\nReceived by server       : " + message
                        + "\nSent back by server     : " + serverMessage
        clientMessage = ""
    }

// -------------------------------------------- Save IP Address and Port

	function saveipAddress(text) {
        if (text) {
// use next line if you want to validat for a numeric ip address
//            if ( ( text.trim() == "" ) || (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(text.trim()) ) ) {
            if ( text.trim() != "" ) {
                serverIP.buttonText = text.trim();
                app.serverAddress = text.trim();
                app.saveSettings()
                server.host = app.serverAddress
            }
        }
        server.listen = true
	}

    function savePort(text) {
        if (text) {
            if ( parseInt(text) >= 8000 ) {
                serverPort.buttonText = text.trim();
                app.serverPort = text.trim();
                if ( app.serverPort != oldserverport) {

                    getIPTables()

                    listIPTables()

                    closeIPTablesPort(oldserverport)
                    openIPTablesPort(app.serverPort)

                    listIPTables()

                    saveIPTables()

                    app.saveSettings()

                    rebootToon()

                }
            }
        }
        server.listen = true
    }

// ----------------------------------------------------------- rectangle

    Rectangle {
            id      : setup
            width  : parent.width
            height : parent.height * 1 / 4
            border {
                width: 2
                color: "black"
            }

        Text {
            id: serverIPtitle
            text: "websocket listen IP address"
            anchors {
                top             : parent.top
                left            : parent.left
                leftMargin      : 10
                topMargin       : isNxt ? 10 : 8
            }
            font {
                family: qfont.semiBold.name
                //pixelSize: qfont.titleText
                pixelSize: isNxt ? 15 : 12
            }
        }
            
        YaLabel {
            id                  : serverIP
            buttonText          : app.serverAddress
            height              : 40
            width               : 200
            hoveringEnabled     : isNxt
            selected            : true
            enabled             : true
            textColor           : "black"
            anchors {
                top             : serverIPtitle.top
                left            : serverIPtitle.right
                leftMargin      : isNxt ? 25 : 20
            }
            onClicked: {
                server.listen = false
                qkeyboard.open("The IP address of the websocket server 0.0.0.0 or 127.0.0.1", serverIP.buttonText, saveipAddress)
            }
        }

        Text {
            id: info
            text: "<<-- 127.0.0.1 for local or 0.0.0.0 for LAN access\nTo test click on the screen below\nor send data from another client\n<<-- !! PORT CHANGE WILL REBOOT TOON !! "
            anchors {
                top             : serverIPtitle.top
                left            : serverIP.right
                leftMargin      : isNxt ? 25 : 20
            }
            font {
                family: qfont.semiBold.name
                //pixelSize: qfont.titleText
                pixelSize: isNxt ? 15 : 12
            }
        }

        Text {
            id: serverPorttitle
            text: "websocket server IP port"
            anchors {
                top             : serverIPtitle.bottom
                left            : serverIPtitle.left
                leftMargin      : isNxt ? 25 : 20
                topMargin       : 40
            }
            font {
                family: qfont.semiBold.name
                //pixelSize: qfont.titleText
                pixelSize: isNxt ? 15 : 12
            }
        }
            
        YaLabel {
            id                  : serverPort
            buttonText          : app.serverPort
            height              : 40
            width               : 200
            hoveringEnabled     : isNxt
            selected            : true
            enabled             : true
            textColor           : "black"
            anchors {
                top             : serverPorttitle.top
                left            : serverIP.left
            }
            onClicked: {
                server.listen = false
                oldserverport = app.serverPort
                qkeyboard.open("Port >= 8000 ; A CHANGE WILL REBOOT TOON", serverPort.buttonText, savePort)
            }
        }

    }    
    
// ----------------------------------------------------------- rectangle

    Rectangle {
            id : serverrectInitial
            width  : parent.width
            height : parent.height * 3 / 4
            anchors {
                top                 : setup.bottom
            }
            
            border {
                width: 2
                color: "black"
            }

        Text {
            id: messageBoxInital
            text: "Please configure websocket server IP port.\n\nThis will set the port for the server\nand open a firewall port which\nis activated after a reboot."
//            anchors.centerIn: parent
            anchors {
                top         : parent.top
                left        : parent.left
                topMargin   : 40
                leftMargin  : 40
            }
            font {
                family: qfont.semiBold.name
                //pixelSize: qfont.titleText
                pixelSize: isNxt ? 20 : 16
            }
        }
        
        visible : (app.serverPort < 8000)
            
    }

// ----------------------------------------------------------- rectangle

    Rectangle {
    
        id : serverrect
        width  : parent.width
        height : parent.height * 3 / 4
        anchors {
            top                 : setup.bottom
        }
        
        border {
            width: 2
            color: "black"
        }

        color : (flip) ? "pink" : "lime"
        
        WebSocketServer {
            id: server
            listen: true
            host : app.serverAddress
            port : app.serverPort
            onClientConnected: {
                webSocket.onTextMessageReceived.connect(function(message) {
                    if (message == 'flip' ) { flip = !flip  }
                    if (flip) {
                        serverMessage = "Send flip to not reverse: "+app.reverseString(qsTr(message))
                    } else {
                        serverMessage = "Send flip to reverse: "+message
                    }
                    webSocket.sendTextMessage(serverMessage);
// The next contains the url used by the client 
// So if you have a public DNS name and forwarding on your router
// you will see your public DNS name on the screen
                    buildScreenText(message+"  (via url : "+webSocket.url+")");
                });
            }
            onErrorStringChanged: {
                app.log('onErrorStringChanged')
                buildScreenText(qsTr("Server error: %1").arg(errorString));
            }
        }

        WebSocket {
            id: socket
            url: server.url
            onTextMessageReceived: {
                messageBox.text = messageBox.text + "\n" 
                                + "Received by local client: " + message + "\n" 
            }
            onStatusChanged: if (socket.status == WebSocket.Error) {
                                 app.log('socket.status 0 '+socket.status)
                                 app.log("Error: " + socket.errorString)
                                 messageBox.text = socket.url + "\n"+socket.errorString+"\n\n\n"
                             } else if (socket.status == WebSocket.Open) {
                                 clickCounter = clickCounter + 1
                                 clientMessage = "Hello World " + clickCounter
                                 socket.sendTextMessage(clientMessage)
                             } else if (socket.status == WebSocket.Closed) {
                                 messageBox.text += " ... Socket closed click for new message"
                             }
            active: false
        }

        Text {
            id: messageBox
//            anchors.centerIn: parent
            anchors {
                top         : parent.top
                left        : parent.left
                topMargin   : 40
                leftMargin  : 40
            }
            font {
                family: qfont.semiBold.name
                //pixelSize: qfont.titleText
                pixelSize: isNxt ? 20 : 16
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                socket.active = !socket.active
            }
        
        }
        
        visible : (app.serverPort >= 8000)
    }
    
    

}
