% init Client side.
host='localhost';
port=3000;

% create object.
client=Eneeb_client(host, port);
client.create();

t1=tic;

%%

figure(1)

x = 1;
plot(x);

linkdata on

%%
datapoint_size=328;

bytearrayread='';
m=1;
datapoint_byte=[];

pause(1)

while 1
    
    bytearrayread=client.readmessage(datapoint_size);
    t2(m)=toc(t1);
    
    if (sum(bytearrayread)==0)
       break;
    end
    
    if ~isempty(bytearrayread)
        datapoint_byte{m}=bytearrayread;
        datapoint{m}=typecast(datapoint_byte{m}, 'double');
        x(m)=datapoint{m}(1);
        refreshdata
        drawnow

        m=m+1;
    end


   

    
    
end



%%
client.close()

% %%
% figure, 
% 
% plot(diff(t2))
