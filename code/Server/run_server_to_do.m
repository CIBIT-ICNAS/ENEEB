
%% Initialize server

% Set vars.
host='localhost';
port=3000;

bytearray=[];

%% [TODO:] CREATE server.
% hint: help Eneeb_server

% Create OBJ server and initialize.
% server=
% server.
%%

for i=1:size(TEST,1)

    % float2byte datatype
    for f=1:length(TEST(i,:))
        bytearray=[bytearray typecast(TEST(i,f),'uint8')];
    end
    
    % bytearray size = 8 (bytes per sample) * 41 elements - need to send
    % 328 bytes per sample
    
    %% [TODO:] SEND MESSAGE (send message through server)
    % hint: help Eneeb_server
    
    % server.
    %%
    
    pause(.25)
    
    bytearray=[];
end

%% [TODO:] SEND MESSAGE informing that run ended.
% hint: help zeros, Eneeb_server

% server.;
%%

% Close server.
server.close();