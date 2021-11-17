import QtQuick 2.1
import qb.components 1.0
import QtWebSockets 1.1

Screen {
    id                          : socketClientScreen
    screenTitle                 : qsTr(me)

// ---------------------------------------------------------------------

    property string me          : "Websocket Client Screen"

    property int messageCounter
    
// --------------------------------------------------------------------- 
    
    onVisibleChanged: {
        if (visible) {
            messageCounter = 0
            socket.url= "ws://"+app.clientServerAddress+":"+app.clientServerPort
            messageBox.text = socket.url
        }
    }

// -------------------------------------------- Save IP Address and Port

	function saveipAddress(text) {
        if (text) {
// use next line if you want to validate for a numeric ip address
//            if ( ( text.trim() == "" ) || (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(text.trim()) ) ) {
            if ( text.trim() != "" ) {
                serverIP.buttonText = text.trim();
                app.clientServerAddress = text.trim();
                socket.url= "ws://"+app.clientServerAddress+":"+app.clientServerPort
                app.saveSettings()
            }
        }
	}

    function savePort(text) {
        if (text) {
            if ( parseInt(text) > 0 ) {
                serverPort.buttonText = text.trim();
                app.clientServerPort = text.trim();
                socket.url= "ws://"+app.clientServerAddress+":"+app.clientServerPort
                app.saveSettings()
            }
        }
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
            text: "websocket server IP address"
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
            buttonText          : app.clientServerAddress
            height              : 40
            width               : 300
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
                qkeyboard.open("The IP address of the websocket server", serverIP.buttonText, saveipAddress)
            }
        }

        Text {
            id: info
            text: "veraart.thehomeserver.net runs on port 8001.\non my Toon 2. Change settings to test your own server.\nYou may use socketechoserver.py as your server.\nJust click on the screen below to test."
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
            buttonText          : app.clientServerPort
            height              : 40
            width               : 300
            hoveringEnabled     : isNxt
            selected            : true
            enabled             : true
            textColor           : "black"
            anchors {
                top             : serverPorttitle.top
                left            : serverIP.left
            }
            onClicked: {
                qkeyboard.open("The Port  of the websocket server", serverPort.buttonText, savePort)
            }
        }

    }    
// ----------------------------------------------------------- rectangle

    Rectangle {
            id     : clientrect
            width  : parent.width
            height : parent.height * 3 / 4
            anchors {
                top                 : setup.bottom
            }
            
            border {
                width: 2
                color: "black"
            }

        WebSocket {
            id: socket
            onTextMessageReceived: {
                messageBox.text = messageBox.text + "\n\nReceived message: " + message
            }
            onStatusChanged: if (socket.status == WebSocket.Error) {
                                 app.log('socket.status 0 '+socket.status)
                                 app.log("Client Error: " + socket.errorString)
                                 messageBox.text = socket.url + "\n\n Error : "+socket.errorString
                             } else if (socket.status == WebSocket.Open) {
                                var now      = new Date();
                                var dateTime = now.getFullYear() + '-' +
                                        ('00'+(now.getMonth() + 1)   ).slice(-2) + '-' +
                                        ('00'+ now.getDate()         ).slice(-2) + ' ' +
                                        ('00'+ now.getHours()        ).slice(-2) + ":" +
                                        ('00'+ now.getMinutes()      ).slice(-2) + ":" +
                                        ('00'+ now.getSeconds()      ).slice(-2) + "." +
                                        ('000'+now.getMilliseconds() ).slice(-3);
                                if ((messageCounter + 1) == 5 ) {
                                    var tosend = "flip"
                                } else {
                                    var tosend = "Hello World @ "+dateTime
                                }
                                socket.sendTextMessage(tosend)
                                messageBox.text = socket.url + "\n\nEvery 5th message I will send flip ("+(messageCounter + 1)+")\n\nSend message   : "+tosend
                                messageCounter = ( messageCounter + 1 ) % 5
                             } else if (socket.status == WebSocket.Closed) {
                                 messageBox.text += "\n\nSocket closed click to send new message"
                             }
            active: false
        }

        WebSocket {
// I did not do anything on secure sockets yet.
// This must involve some certificate work 
// including selfsigned certificates and trusting these.
            id: secureWebSocket
            url: "wss://echo.websocket.org"
            onTextMessageReceived: {
                messageBox.text = messageBox.text + "\nReceived secure message: " + message
            }
            onStatusChanged: if (secureWebSocket.status == WebSocket.Error) {
                                 app.log("Error: " + secureWebSocket.errorString)
                             } else if (secureWebSocket.status == WebSocket.Open) {
                                 secureWebSocket.sendTextMessage("Hello Secure World")
                             } else if (secureWebSocket.status == WebSocket.Closed) {
                                 messageBox.text += "\nSecure socket closed"
                             }
            active: false
        }

        Text {
            id: messageBox
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
//                secureWebSocket.active =  !secureWebSocket.active;
//                Qt.quit();
            }
        }

    }

}
