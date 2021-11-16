import QtQuick 2.1
import qb.components 1.0

Tile {
    id                          : socketTile
    
    property string colortxt    : "black"
    property string color0      : "green"
    property string color1      : "red"
    property string color2      : "yellow"
    property string color3      : "lightgrey"
    property string color4      : "cyan"

    property int buttonHeight     : socketTile.height / 4
    property int buttonWidth      : socketTile.width / 2.5


// --------------------------------------------------- Screen button

    YaLabel {
        id                      : client
        buttonText              : "Client"
        height                  : buttonHeight
        width                   : buttonWidth
        buttonActiveColor       : buttonSelectedColor
        buttonHoverColor        : buttonSelectedColor
        buttonSelectedColor     : color2
        selected                : true
        enabled                 : true
        textColor               : colortxt
        anchors {
            top                 : parent.top
            topMargin           : buttonHeight / 2
            horizontalCenter    : parent.horizontalCenter
        }
        onClicked: {
            stage.openFullscreen(app.webSocketClientScreenUrl);
        }
    }

    YaLabel {
        id                      : server
        buttonText              : "Server"
        height                  : buttonHeight
        width                   : buttonWidth
        buttonActiveColor       : buttonSelectedColor
        buttonHoverColor        : buttonSelectedColor
        buttonSelectedColor     : color4
        selected                : true
        enabled                 : true
        textColor               : colortxt
        anchors {
            bottom              : parent.bottom
            bottomMargin        : buttonHeight / 2
            horizontalCenter    : parent.horizontalCenter
        }
        onClicked: {
            stage.openFullscreen(app.webSocketServerScreenUrl);
        }
    }


}
