% Init client side.

% class CLIENT

classdef Eneeb_client < handle
    
    properties (SetAccess = private)
        host
        port
        
        max_retries = 20; % set to -1 for infinite
        message
        
        input_socket
        input_stream
        data_input_stream
        
    end
    
    methods
        % constructor
        function obj=Eneeb_client(host, port)
            obj.host=host;
            obj.port=port;
        end
        
        % create Eneeb_client.
        function create(obj)
            
            import java.net.Socket
            import java.io.*
            
            retry        = 0;
            obj.input_socket = [];
            
            while true
                retry = retry + 1;
                if ((obj.max_retries > 0) && (retry > obj.max_retries))
                    fprintf(1, '[CLIENT: ] Too many retries\n');
                    break;
                end
                
                try
                    fprintf(1, '[CLIENT: ] Retry %d connecting to %s:%d\n', ...
                        retry, obj.host, obj.port);
                    % throws if unable to connect
                    obj.input_socket = Socket(obj.host, obj.port);
                    
                    % get a buffered data input stream from the socket
                    obj.input_stream   = obj.input_socket.getInputStream;
                    obj.data_input_stream = DataInputStream(obj.input_stream);
                    
                    fprintf(1, '[CLIENT: ] Connected to server\n');
                    
                    break;
                    
                catch
                    if ~isempty(obj.input_socket)
                        
                        obj.input_socket.close;
                    end
                    % pause before retrying
                    pause(1);
                end
            end
        end
        
        function close(obj)
            % close and cleanup.
            obj.input_socket.close;
            
            fprintf(1, '[CLIENT: ] Client closed connection.\n')
       
        end
        
        function bytearrayread=readmessage(obj, datapoint_size)
            % read data from the socket - wait a short time first

            
            while (obj.input_stream.available<datapoint_size)
                pause(.1); % to confirm
            end
            
            bytes_available = obj.input_stream.available;
            fprintf(1, '[CLIENT: ]  %d bytes available \n', bytes_available);
            obj.message = zeros(1, datapoint_size, 'int8');
            
            for i = 1:datapoint_size%bytes_available
                obj.message(i) = obj.data_input_stream.readByte;
            end
            
            bytearrayread=obj.message;
            
            % obj.message=char(obj.message);
            
            fprintf(1, '[CLIENT: ] done. \n')
            
        end
    end
end