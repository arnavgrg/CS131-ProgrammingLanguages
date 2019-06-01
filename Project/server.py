import sys
import os
import aiohttp 
import asyncio
import json
import time

#GCP Credentials for Places API
#key="AIzaSyC7mqFJt6wYkoL3KGzAoBNXFGbWqi6ptDw"

#Global file_name which will be changed within functions as needed
file_name = ''

#Server names with their assigned port numbers
#Starting and ending port numbers
#START_ = 11760, END_ = 11768
port_numbers = {
    'Goloman': 11760,
    'Hands': 11761,
    'Holiday': 11762,
    'Welsh': 11763,
    'Wilkes': 11764
}

#Allowed communications between servers
allowed_communications = {
    'Goloman': ['Hands', 'Holiday', 'Wilkes'],
    'Hands': ['Wilkes'],
    'Holiday': ['Welsh','Wilkes'],
    #Based on the first 3 allowed communications, we can infer the allowed 
    #communications for Welsh and Wilkes
    'Welsh': ['Holiday'],
    'Wilkes': ['Goloman', 'Hands', 'Holiday']
}

#Valid commands that can be sent by a client/server
valid_commands = ['IAMAT', 'WHATSAT']

#Function to write error messages to the file and exit with status 1
def error(message):
    print(message)
    sys.exit(1)

#Function to write output to the outlog.log file
def write_to_file(message):
    f = open(file_name, 'a+')
    f.write(message+"\n")
    f.close()

#Function to perform error checking
def error_check(args):
    #Check if the file name already exists, if yes, delete it
    #if os.path.exists(file_name):
    #    os.remove(file_name)
    #Check length of the arguments
    if (len(args) != 2):
        error("Invalid input!! Input format is python3 server.py <server_name>")
    #Check if the server name is one of the 5 we're supposed to recognise
    elif args[1] not in list(port_numbers.keys()):
        error("Invalid server name!! Accepted server names are 'Goloman', 'Hands', 'Holiday', 'Welsh', 'Wilkes'")

#Main driver function
def main():
    #Check initial CLI input
    error_check(sys.argv)
    print("Connecting to {}...".format(sys.argv[1]))
    #Setup logfile
    global file_name
    file_name = str(sys.argv[1]) + '.log'
    #https://docs.python.org/3/library/asyncio-eventloop.html#running-and-stopping-the-loop
    #https://docs.python.org/3/library/asyncio-eventloop.html#server-objects
    #If all successful, exit with 0
    sys.exit(0)

if __name__ == "__main__":
    main()