% init Client side.
host='localhost';
port=3000;

% create object.
client=Eneeb_client(host, port);
client.create();

client.readmessage()
pause(10)
client.readmessage()
client.close()