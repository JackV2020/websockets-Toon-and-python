import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;
import FileIO 1.0
import BxtClient 1.0

App {

    property url                    tileUrl                     : "WebSocketTile.qml"
    property WebSocketTile          webSocketTile

    property url                    webSocketClientScreenUrl    : "WebSocketClientScreen.qml"
    property WebSocketClientScreen  webSocketClientScreen

    property url                    webSocketServerScreenUrl    : "WebSocketServerScreen.qml"
    property WebSocketServerScreen  webSocketServerScreen

    property string settingsFile    : "file:///mnt/data/tsc/webSocketSettings.json"

    property string                 clientServerAddress
    property int                    clientServerPort

    property string                 serverAddress
    property int                    serverPort
    
// -------------------------------------- Location of user settings file

    FileIO {
        id                          : userSettingsFile
        source                      : settingsFile
     }

// -------------------------- Structure user settings from settings file

    property variant userSettingsJSON : {}

// ---------------------------------------------------------------------

    function init() {

        const args = {
            thumbCategory       : "general",
            thumbLabel          : "WebSocket",
            thumbIcon           : "qrc:/tsc/BalloonIcon.png",
            thumbIconVAlignment : "center",
            thumbWeight         : 30
        }

        registry.registerWidget("tile",   tileUrl,                  this, "webSocketTile", args);

        registry.registerWidget("screen", webSocketClientScreenUrl, this, "webSocketClientScreen");

        registry.registerWidget("screen", webSocketServerScreenUrl, this, "webSocketServerScreen");

		notifications.registerType("webSocket", notifications.prio_HIGHEST, Qt.resolvedUrl("qrc:/tsc/notification-update.svg"), webSocketClientScreenUrl , {"categoryUrl": webSocketClientScreenUrl }, "webSocket mededelingen");
		notifications.registerSubtype("webSocket", "mededeling", webSocketClientScreenUrl , {"categoryUrl": webSocketClientScreenUrl});

    }

// ---------------------------------------------------------------------

	function sendNotification(text) {
		notifications.send("webSocket", "mededeling", false, text, "category=mededeling");
	}


// ---------------------------------------------------------------------

    Component.onCompleted: {

// read user settings

        try {
            userSettingsJSON = JSON.parse(userSettingsFile.read());
            log(JSON.stringify(userSettingsJSON))

            clientServerAddress = userSettingsJSON['clientServerAddress'];
            clientServerPort          = userSettingsJSON['clientServerPort'];
            serverAddress       = userSettingsJSON['serverAddress']
            serverPort          = userSettingsJSON['serverPort'];

            log(reverseString('hallo'))
            
//            sendNotification("webSocket startup oke.")
            
        } catch(e) {
            log('Startup : '+e)

            clientServerAddress = "veraart.thehomeserver.net";
            clientServerPort    = 8001;
            serverAddress       = "0.0.0.0"
            serverPort          = 0
            
//            sendNotification("webSocket initial startup. Please set Server IP Port.")

            saveSettings()
        }
    }

// ---------------------------------------------------------------------

    function saveSettings(){

        var tmpUserSettingsJSON = {
            "clientServerAddress"   :   clientServerAddress,
            "clientServerPort"      :   clientServerPort,
            "serverAddress"         :   serverAddress,
            "serverPort"            :   serverPort
        }

        var settings = new XMLHttpRequest();
        settings.open("PUT", settingsFile);
        settings.send(JSON.stringify(tmpUserSettingsJSON));
    }

// ---------------------------------------------------------------------

    function log(tolog) {

        var now      = new Date();
        var dateTime = now.getFullYear() + '-' +
                ('00'+(now.getMonth() + 1)   ).slice(-2) + '-' +
                ('00'+ now.getDate()         ).slice(-2) + ' ' +
                ('00'+ now.getHours()        ).slice(-2) + ":" +
                ('00'+ now.getMinutes()      ).slice(-2) + ":" +
                ('00'+ now.getSeconds()      ).slice(-2) + "." +
                ('000'+now.getMilliseconds() ).slice(-3);
        console.log(dateTime+' webSocket: ' + tolog.toString())

    }

// ------------------------------------------- some handy functions

    function reverseString(str) {
        return str.split("").reverse().join("");
    }

}
