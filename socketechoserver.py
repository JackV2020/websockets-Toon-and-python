#!/usr/bin/python3
#
# I got some info from :
# https://pypi.org/project/simple-websocket-server/
# pip install simple-websocket-server

# check also : https://github.com/tripzero/python-wss

from simple_websocket_server import WebSocketServer, WebSocket

counter = 0

class SimpleEcho(WebSocket):

    def handle(self):
        global counter

        counter = counter + 1
        print(self.address, 'received : ', self.data)

        code = ' # ' + str(counter ) + " # " + self.data
        print(self.address, 'answer   : '+ code)
        self.send_message(code) 

    def connected(self):
        print(self.address, 'connected')

    def handle_close(self):
        print(self.address, 'closed')

#server = WebSocketServer('192.168.2.27', 8000, SimpleEcho)
server = WebSocketServer('0.0.0.0', 8000, SimpleEcho)
server.serve_forever()
