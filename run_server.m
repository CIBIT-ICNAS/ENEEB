% Set vars.
host='localhost';
port=3000;

% Create server.
server=Eneeb_server(host, port);
server.create();

% send meassge through server
server.sendmessage('Hello World!!!');

pause(5)

% send meassge through server
server.sendmessage('bye!');

% Close server.
server.close();