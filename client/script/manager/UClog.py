
#!/usr/bin/python3
from datetime import datetime
import requests
import argparse
import hashlib
import os
import colorama
import json
from colorama import Style, Fore, Back

VERSION = 0.1

parser = argparse.ArgumentParser(prog='uclog')
subparser = parser.add_subparsers(dest='command')

status = subparser.add_parser('status')
setcommand = subparser.add_parser('set')
traffic_command = subparser.add_parser('traffic')
name_command = subparser.add_parser('name')


subparser_set = setcommand.add_subparsers()
setoptions = subparser_set.add_parser('endpoint')


parser.add_argument('-v','--verbose',dest="verbose",help='Turn verbosity on',default=False,action="store_true")
parser.add_argument('-s','--server-ip',dest="server",help="What API to connect to",default="192.168.128.23")
parser.add_argument('-p','--port',dest="port",help="What port to connect to",default="2003")

setoptions.add_argument('-i','--ip',dest="ip",help="The IP of the service to be checked")

colorama.init(autoreset=True)

# arg = parser.parse_args()
arg, end = parser.parse_known_args()

def checkVersion(version):
    if float(version) > float(VERSION):
        print(Fore.WHITE + Back.BLUE + "Warning: Outdated version of uc client. Run the following command to update:\ncurl -s https://raw.githubusercontent.com/kybeg/uc-client/main/install.sh | sudo /bin/bash")
        print()

def verbose(text):
    if arg.verbose :
        print(text)


def printResult(result):
    if ( result["result"] == "OK" ):
        print("Response: " + Fore.GREEN + "OK" )
    else:
        print("Response: " + Fore.RED + result["result"] )

    print(result["message"])
        
def getToken():
    username = os.environ.get('OS_USERNAME')
    password = os.environ.get('OS_PASSWORD')
    
    if not username or not password:
        print("Could not find authentication information. Did you source the OpenStack RC file?")
        quit(1)
    
    tokenstring = username + password
    return hashlib.md5(tokenstring.encode('UTF-8')).hexdigest()

if arg.command == 'status':
    
    token = getToken()
    endpoint = "http://" + arg.server + ":" + arg.port + "/get/me"
    verbose("executing the following url: " + endpoint)
    headers = {"Authorization": "Bearer " + token}
    result = requests.get(endpoint, headers=headers).json()
    if "preferred_client" in result:
        checkVersion(result["preferred_client"])
    if result["result"] == "OK":
#        print(result)
        print(Fore.CYAN + "UPTIME CHALLENGE")
        print(Fore.CYAN + "----------------")
        print("Service provider: " + Fore.YELLOW + result["name"])
        print("Service endpoint: " + Fore.YELLOW + result["service_endpoint"])
        print("Balance: " + Fore.YELLOW + result["balance"] + " KC")
        enabled = Fore.RED + "no"
        if result["enabled"] == "yes":
            enabled = Fore.GREEN + "yes"
        print("Enabled: " + enabled)
        if "last_check" in  result:
            check_result = Fore.RED + "DOWN"

            if result["last_check"]["text_found"] == 1:
                check_result = Fore.GREEN + "UP"
                
            timestamp = datetime.fromtimestamp(result["last_check"]["check_time"]).strftime('%Y-%m-%d %H:%M:%S')
            print ("Last check @" + timestamp +": " + check_result )
#            print ("Download time: " + str(result["last_check"]["time_to_download"]) + " seconds")
            reward_color = Fore.RED
            if "calculated_reward" in result["last_check"]:
                if  result["last_check"]["calculated_reward"] > 0:
                    reward_color = Fore.GREEN
                print ("Kyrrecoins earned: " + reward_color + str(result["last_check"]["calculated_reward"]))
            print (Fore.MAGENTA + "Report: ")
            print(result["last_check"]["result"])

if arg.command == 'set':    
    verbose("Requesting new endpoint to be set to " + end[0] )
    token = getToken()
    headers = {"Authorization": "Bearer " + token}
    endpoint = "http://" + arg.server + ":" + arg.port + "/set/endpoint?ip=" + end[0]
    printResult(requests.get(endpoint, headers=headers).json())

if arg.command == 'traffic':    
    verbose("Traffic is set to " + end[0] )
    token = getToken()
    headers = {"Authorization": "Bearer " + token}
    endpoint = "http://" + arg.server + ":" + arg.port + "/set/traffic?state=" + end[0]
    printResult(requests.get(endpoint, headers=headers).json())

if arg.command == 'name':    
    if input("The name can only be set one time. Are you sure you want to set the name to " + end[0] + "?\n (y/n)") != "y":
        exit()
    verbose("Name is set to " + end[0] )
    token = getToken()
    headers = {"Authorization": "Bearer " + token}
    endpoint = "http://" + arg.server + ":" + arg.port + "/set/name?name=" + end[0]
    printResult(requests.get(endpoint, headers=headers).json())

    