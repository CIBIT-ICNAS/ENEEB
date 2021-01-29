% Load data.
load('DatasetENEEB.mat')


% Set vars.
host='localhost';
port=3000;

% Create server.
server=Eneeb_server(host, port);
server.create();

%%
% send message through server
%server.sendmessage(ones(1,328));

bytearray=[];

for i=1:100 % size(Run1,1)

    % float2byte datatype
    for f=1:length(Run1(i,:))
        bytearray=[bytearray typecast(Run1(i,f),'uint8')];
    end
    
    % send message through server
    server.sendmessage(bytearray);
    pause(.5)
    
    bytearray=[];
end

server.sendmessage(zeros(1,328));

% Close server.
server.close();