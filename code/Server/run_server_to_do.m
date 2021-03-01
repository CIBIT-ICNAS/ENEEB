
%% Initialize server

% Set vars.
host='localhost';
port=3000;

bytearray=[];

%% [TODO:] CREATE server.
% hint: help Eneeb_server
% Create OBJ server and initialize.
%server=
% server.
%%


for i=1:50 % size(Run1,1)

    % float2byte datatype
    for f=1:length(Run1(i,:))
        bytearray=[bytearray typecast(Run1(i,f),'uint8')];
    end
    
    % [TODO:] SEND MESSAGE.
    % send message through server
    server.sendmessage(bytearray);
    pause(.5)
    
    bytearray=[];
end

% [TODO:] SEND MESSAGE informing that run ended.
server.sendmessage(zeros(1,328));

% Close server.
server.close();