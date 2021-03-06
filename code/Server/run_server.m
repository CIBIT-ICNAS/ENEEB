%% Clean everything before we start.
clear all, 
close all, 

%%
% Load data.
addpath('data')
load('DatasetENEEB.mat')

% Set vars.
host='localhost';
port=3000;
bytearray=[];

% Create server.
server=Eneeb_server(host, port);
connected=server.initialize();

% If connection was created, start sending data.
if connected
    
    % simulate data acquisition I/O.
    for i=1:size(Run1,1)
        
        % float2byte datatype.
        for f=1:length(TRAIN(:,i))
            bytearray=[bytearray typecast(TRAIN(f,i),'uint8')];
        end
        
        % send message through server
        server.sendmessage(bytearray);
        pause(.25)
        
        bytearray=[];
        
        fprintf('[SERVER: ] Sending sample number %i \n', i);
    end
    
    server.sendmessage(zeros(1,328));
    fprintf('[SERVER: ] Last sample sent.');

    
    % Close server.
    server.close();
end