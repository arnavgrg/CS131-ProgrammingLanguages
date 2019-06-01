import sys
import os
import asyncio
import aiohttp 
import json
import time

#GCP apiKey for 
apiKey = "AIzaSyC7mqFJt6wYkoL3KGzAoBNXFGbWqi6ptDw"

#Global file_name which will be changed within functions as needed
file_name = None
#Global loop variable for asyncio
loop = None

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
    global file_name
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

#Asynchronour HTTP get request to get JSON object from the Google Places API
async def get_info(generated_url, limit):
    #If limit < 0, then the original input passed in is invalid
    if limit < 0:
        write_to_file('ERROR: Invalid value passed in during WHATSAT call!!!')
    output_to_be_returned = ""
    #Asynchronous get request 
    #Create client session
    async with aiohttp.ClientSession() as session:
        #Setup response object called url_response
        #https://developers.google.com/places/web-service/search
        async with session.get(generated_url,ssl=False) as url_response:
            #Ensure request was successful
            if url_response.status == 200:
                #It is a common case to return JSON data in response, aiohttp.web provides a shortcut 
                #for returning JSON – aiohttp.web.json_response()
                raw = await url_response.json()
                if limit <= 20:
                    output_to_be_returned = raw['result'][0:limit]
                else:
                    output_to_be_returned = raw['result'][0:20]
            else:
                write_to_file("ERROR: Async get request failed while trying WHATSAT!!!")
    return output_to_be_returned

async def server_callback():
    await asyncio.sleep(1)
    print("Reached!")

#Main driver function
def main():
    #Check initial CLI input
    error_check(sys.argv)
    #Setup logfile
    global file_name
    file_name = str(sys.argv[1]) + '.log'
    #For some reason, if I don't do this, the file is never created
    open(file_name, 'a+').close()
    print("Connecting to {}...".format(sys.argv[1]))
    #https://docs.python.org/3/library/asyncio-eventloop.html#running-and-stopping-the-loop
    #https://docs.python.org/3/library/asyncio-eventloop.html#server-objects
    #Event loops run asynchronous tasks and callbacks, perform network IO operations, 
    #and run subprocesses. Event loops use cooperative scheduling.
    global loop
    #If no loop already exists, it initializes one 
    loop = asyncio.get_event_loop()
    #Establish a coroutine
    #Each server should accept TCP connections from clients. This starts a socket server.
    #1st argument -> callback function; 2nd argument -> Host Name; 3rd -> Port Num.
    coro = asyncio.start_server(server_callback, '127.0.0.1', port_numbers[sys.argv[1]], loop=loop)
    #If the argument is a coroutine object it is implicitly scheduled to run as a asyncio.Task. Tasks are used to run coroutines in event loops. 
    #A function that can be entered and exited multiple times, suspended and resumed each time, is called 
    #a coroutine.
    server = loop.run_until_complete(coro)
    #Run infinitely until keyboard interrupt
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.close()
        loop.run_until_complete(server.wait_closed())
        loop.close()
        print("\n%s is shutting down..." % sys.argv[1])
        sys.exit(0)

if __name__ == "__main__":
    main()