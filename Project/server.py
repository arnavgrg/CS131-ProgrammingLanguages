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
logfile = None
#Global loop variable for asyncio
loop = None

#Want to be able to track of clients currently communicating with the server
currentClients = {}

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
valid_commands = ['IAMAT', 'WHATSAT', 'ECHO']

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
    #TODO: Check if the file name already exists, if yes, delete it
    #Check length of the arguments
    if (len(args) != 2):
        error("Invalid input!! Input format is python3 server.py <server_name>")
    #Check if the server name is one of the 5 we're supposed to recognise
    elif args[1] not in list(port_numbers.keys()):
        error("Invalid server name!! Accepted server names are 'Goloman', 'Hands', 'Holiday', 'Welsh', 'Wilkes'")

#Function that simulates the flooding algorithm
async def floodServers(text):
    currentServer = sys.argv[1]
    #Find the list of servers the current server can communicate with
    for server in allowed_communications[currentServer]:
        logfile.write("Trying to establish connection with server %s...\n" % server)
        try:
            #Try to open a connection with the server. Only works if the server is already running
            reader, writer = await asyncio.open_connection('127.0.0.1', port_numbers[server], loop=loop)
            logfile.write("Opened connection to %s!!\n" % currentServer)
            #Write to the server 
            writer.write(text.encode())
            await writer.drain()
            #Log that communication message has been transmitted
            logfile.write("ECHOED message to %s!\n" % server)
            writer.close()
        except:
            logfile.write("{0} failed to connect with {1}\n".format(currentServer, server))

#Function to parse through the coordinates received by the client
#Don't want to make this async because we want to wait till its completion (blocking)
def parseCoords(coords):
    latitude = None
    longitude = None
    signIndexes = []
    dotIndexes = []
    #Traverse through all the characters in the location string
    for index,token in enumerate(coords, 1):
        if token == '.':
            dotIndexes.append(index)
        if token == '+' or token == '-':
            #Push the index at which the + and - were found
            signIndexes.append(index)
    #Want to sure there are only 2 of either + or - 
    if len(signIndexes) != 2:
        return [None, None]
    #If there are more than two dots, then there is an issue
    elif len(dotIndexes) != 2:
        return [None, None]
    else:
        #Need to subtract 1 to get the signs, otherwise it gets the wrong indexes
        latitude = coords[signIndexes[0]-1:signIndexes[1]-1]
        longitude = coords[signIndexes[1]-1:]
    return [latitude, longitude]

#Function to process IAMAT output
#[IAMAT,kiwi.cs.ucla.edu,+34.068930-118.445127,1520023934.918963997]
async def outputIAMAT(tokens, recTime):
    outputMessage = ""
    coords = parseCoords(tokens[2])
    if coords[0] == None or coords[1] == None:
        return -1
    #Append Server Name
    serverName = sys.argv[1]
    tokens.append(recTime)
    tokens.append(serverName)
    #Add client name to list of known clients and save all info about it 
    #[+34.068930-118.445127, 1520023934.918963997, ServerRecTime, servername]
    currentClients[tokens[1]] = tokens[2:]
    #Calculate difference between sent and received timings
    currentTime = time.time()
    diffTime = currentTime - recTime
    #Add +/- signs where needed
    if (diffTime > 0):
        diffTime = '+' + str(diffTime)
    else:
        diffTime = '-' + str(diffTime)
    #Build output message
    outputMessage = "AT " + sys.argv[1] + " " + diffTime + " " + tokens[1] + " " + tokens[2] + " " + tokens[3]
    for i,v in enumerate(currentClients[tokens[1]]):
        currentClients[tokens[1]][i] = str(currentClients[tokens[1]][i])
    #ECHO kiwi.cs.ucla.edu +34.068930-118.445127 1520023934.918963997 1559546768.399098 Wilkes
    floodMessage = "ECHO " + tokens[1] + " " + " ".join(currentClients[tokens[1]])
    #Flood other servers with whom communication is allowed with the info about the client that 
    #just connected to the current server
    await floodServers(floodMessage)
    return outputMessage

#Asynchronour HTTP get request to get JSON object from the Google Places API
async def get_info(generated_url, limit):
    output_to_be_returned = dict()
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
                for key in list(raw.keys()):
                    if key != 'results':
                        output_to_be_returned[key] = raw[key]
                output_to_be_returned['results'] = raw['results'][0:limit]
            else:
                write_to_file("ERROR: Async get request failed while trying WHATSAT!!!")
    #https://stackoverflow.com/questions/12943819/how-to-prettyprint-a-json-object
    return json.dumps(output_to_be_returned, indent=2)

#Function to process WHATSAT output
async def outputWHATSAT(tokens, recTime):
    outputMessage = ""
    if tokens[1] in currentClients:
        #Get list of properties/info from the IAMAT call
        clientProperties = currentClients[tokens[1]]
        client = tokens[1]
        diffTime = float(clientProperties[2]) - float(clientProperties[1])
        #Add +/- signs where needed
        if diffTime > 0:
            diffTime = "+" + str(diffTime)
        else:
            diffTime = "-" + str(diffTime)
        #Get details from tokens and parse coordinates
        limit = tokens[3]
        coords = parseCoords(clientProperties[0])
        latitude = coords[0].replace("+","")
        longitude = coords[1].replace("+","")
        coords = latitude + "," + longitude
        #Need to convert radius to meters
        radius = str(int(tokens[2]) * 1000)
        #Generate output string
        outputMessage = "AT " + sys.argv[1] + " " + diffTime + " " + client + " " + clientProperties[0] + " " + clientProperties[1] + "\n"
        #Generate URL for querying
        generatedUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?" + "key=" + apiKey + "&radius=" + radius + "&location=" + coords
        finalOutput = outputMessage + await get_info(generatedUrl, int(limit))
        return finalOutput
    else:
        return "? " + " ".join(tokens)
    return outputMessage

#Helper method to generate all the messages for various commands
async def generate_output(text, recTime, detectedKeyword):
    #Using strip to remove beginning and trailing white spaces
    tokenized = text.strip().split()
    if detectedKeyword == -1:
        #Servers should respond to invalid commands with a line that contains a question mark (?), 
        #a space, and then a copy of the invalid command.
        return "? " + text
    elif tokenized[0] == 'IAMAT':
        return await outputIAMAT(tokenized, recTime)
    elif tokenized[0] == 'WHATSAT':
        return await outputWHATSAT(tokenized, recTime)
    else:
        return "? " + text

#Function to handle IAMAT messages
#Format: IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 1520023934.918963997
async def handleIAMAT(text):
    #Should have exactly 4 elements in the list
    if (len(text) != 4):
        return -1
    hostName = text[1] 
    coords = text[2]
    timeStamp = text[3]
    #Validation for hostname and timestamp
    if len(hostName) < 1:
        return -1
    elif len(timeStamp) < 1:
        return -1
    #Validate and parse coordinates
    coordinates = parseCoords(coords)
    if coordinates[0] == None or coordinates[1] == None:
        return -1
    #Otherwise everything is valid, so return success code 1
    return 1

#Function to handle WHATSAT messages
#Format: WHATSAT kiwi.cs.ucla.edu 10 5
async def handleWHATSAT(text):
    if len(text) != 4:
        return -1
    hostName = text[1]
    radius = text[2]
    limit = text[3]
    #Validate inputs in WHATSAT message
    if len(radius) < 1 or len(limit) < 1 or len(hostName) < 1:
        return -1
    radius = int(radius)
    limit = int(limit)
    #The radius must be at most 50 km
    if radius <= 0 or radius > 50:
        return -1
    #Information bound must be at most 20 items
    elif limit <= 0 or limit > 20:
        return -1
    return 1

#Helper function for checkKeyword that verifies messages with 'AT'
#FORMAT: AT Goloman +0.263873386 kiwi.cs.ucla.edu +34.068930-118.445127 1520023934.918963997
async def handleAT(text):
    if len(text) != 6:
        return -1
    return 1

#Parse through the message received to see how to handle it
async def checkKeyword(text):
    if text == None or len(text) == 0:
        return -1
    elif text[0] not in valid_commands:
        return -1
    elif text[0] == "IAMAT":
        return await handleIAMAT(text)
    elif text[0] == "WHATSAT":
        return await handleWHATSAT(text)
    #Communication between servers itself
    elif text[0] == "AT": 
        return await(handleWHATSAT)
    #If neither, then it is an invalid starting command
    else:
        return -1

#Callback function for start_server/create_server
#Receives a (reader, writer) pair as two arguments, instances of the StreamReader and StreamWriter classes.
#https://docs.python.org/3/library/asyncio-stream.html#asyncio.StreamReader
#https://docs.python.org/3/library/asyncio-stream.html#asyncio.StreamWriter
async def server_callback(reader, writer):
    #read until EOF and return all read bytes -> (n=-1)
    #Read as utf-8 bytestream, so need to convert it
    read_data = await reader.read(n=-1)
    #Record time the message was read at
    #https://avilpage.com/2014/11/python-unix-timestamp-utc-and-their.html
    receivedTime = time.time()
    #Tokenize the message so it can be processed
    message = " ".join(read_data.decode().split())
    detectedKeyword = await checkKeyword(message.split())
    #If invalid keyword is passed, write to logfile and output, and close connection with client
    if detectedKeyword == -1:
        #Will return ? + message
        output = await generate_output(message, receivedTime, detectedKeyword)
        logfile.write(output + "\n")
        writer.write(output.encode())
        await writer.drain()
        logfile.write("Closing connection with client...\n")
        writer.close()
        #await writer.wait_closed()
    return await generate_output(message, receivedTime, detectedKeyword)

#Main driver function
def main():
    #Check initial CLI input
    error_check(sys.argv)
    #Setup logfile
    global file_name
    file_name = str(sys.argv[1]) + '.log'
    #For some reason, if I don't do this, the file is never created
    open(file_name, 'a+').close()
    global logfile
    logfile = open(file_name, 'a+')
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
    print("Connecting to server {}...".format(sys.argv[1]))
    logfile.write("Opened connection to server %s..\n" % sys.argv[1])
    #Run infinitely until keyboard interrupt
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass #If keyboard interrupt, do nothing
    finally:
        #Close the server and wait until it is closed
        server.close()
        loop.run_until_complete(server.wait_closed())
        #Close the loop, write last line to logfile and exit with status 0
        loop.close()
        logfile.write("%s is shutting down...\n" % sys.argv[1])
        logfile.close()
        sys.exit(0)

if __name__ == "__main__":
    main()