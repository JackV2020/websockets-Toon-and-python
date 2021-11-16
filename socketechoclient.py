#!/usr/bin/python3
#
# I got some info from :
# https://www.compassmentis.com/2015/09/simple-websocket-client-in-python/
# like :
# pip install websocket-client

import sys, getopt
import websocket
import time

def main(argv):
    socketserver = ""
    socketport = ""
    interval=2.5
    onlysend="no"
    try:
#      opts, args = getopt.getopt(argv,"hs:p:",["socketserver=","socketport="])
      opts, args = getopt.getopt(argv,"hs:p:i:o:",["socketserver=","socketport=","interval=","onlysend="])
    except getopt.GetoptError:
      print('socketechoclient.py -s <socket server IP> -p <socket server port> [-i <interval> like 0.5] [-o yes : for only send ]')
      sys.exit(2)
    for opt, arg in opts:
      if opt == '-h':
         print('socketechoclient.py -s <socket server IP> -p <socket server port> [-i <interval> like 0.5] [-o yes : for only send ]')
         sys.exit()
      elif opt in ("-s", "--socketserver"):
         socketserver = arg
      elif opt in ("-p", "--socketport"):
         socketport = arg
      elif opt in ("-i", "--interval"):
         interval = float(arg)
      elif opt in ("-o", "--onlysend"):
         onlysend = arg
    if ( (socketserver == "") or (socketport == "") ):
      print('socketechoclient.py -s <socket server IP> -p <socket server port> [-i <interval> like 0.5] [-o yes : for only send ] ')
      sys.exit(2)
    print('socketserver is '+ socketserver)
    print('socketport is '+ socketport)

    ws = websocket.WebSocket()
    counter = 0
    connected = False
    while True:
        try:
            if ( not connected ) :
                print("Connect to ws://"+socketserver+":"+socketport)
                ws.connect("ws://"+socketserver+":"+socketport)
                connected = True

            if (counter % 10 == 0 ) :
                print("\n---------------------------------")
                print("\nSend : flip ")
                ws.send("flip")
                if not (onlysend == "yes"):
                    result =  ws.recv()
                time.sleep(interval)

            print("\nSend     : Hello, World "+str(counter))
            ws.send("Hello, World "+str(counter))
            if not (onlysend == "yes"):
                result =  ws.recv()
                print("Received : %s" % result)

            time.sleep(interval)
            counter = counter + 1
        except:
            connected = False
            ws.close()
            print("Server down, wait 10 seconds")
            time.sleep(10)
                

if __name__ == "__main__":
   main(sys.argv[1:])
   
