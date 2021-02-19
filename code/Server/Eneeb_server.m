% Init server side.

% class SERVER

classdef Eneeb_server < handle
    
    properties (SetAccess = private)
        host
        port
        
        % set to -1 for infinite.
        max_retries=10 
        
        % default message.
        message='hello world'
        
        server_socket
        output_socket
        output_stream
        data_output_stream
        
    end
    
    methods
        % constructor
        function obj=Eneeb_server(host, port)
            obj.host=host;
            obj.port=port;
        end
        
        % create Eneeb_server.
        function create(obj)
            import java.net.ServerSocket
            import java.io.*
            
            retry= 0;
            obj.server_socket  = [];
            obj.output_socket  = [];
            
            while true
                retry = retry + 1;
                try
                    if ((obj.max_retries > 0) && (retry > obj.max_retries))
                        fprintf(1, '[SERVER: ] Too many retries\n');
                        break;
                    end
                    
                    fprintf(1, ['[SERVER: ] Try %d waiting for client to connect to this ' ...
                        'host on port : %d\n'], retry, obj.port);
                    
                    % wait for 1 second for client to connect server socket
                    obj.server_socket=ServerSocket(obj.port);
                    obj.server_socket.setSoTimeout(1000);
                    
                    obj.output_socket=obj.server_socket.accept;
                    
                    
                    
                    obj.output_stream=obj.output_socket.getOutputStream;
                    obj.data_output_stream=DataOutputStream(obj.output_stream);
                    fprintf(1, '[SERVER: ] Client connected\n');
                    
                    break;
                    
                catch
                    if ~isempty(obj.server_socket)
                        obj.server_socket.close
                    end
                    if ~isempty(obj.output_socket)
                        obj.output_socket.close
                    end
                    
                    % pause before retrying
                    pause(1);
                end
                
            end
        end
        
        function sendmessage(obj, message)
            % output the data over the DataOutputStream
            % Convert to stream of bytes
            fprintf(1, '[SERVER: ] Writing %d bytes\n', length(message))
            obj.data_output_stream.write(message);
            obj.data_output_stream.flush;
        end
        
        function close(obj)
            
            % close socket, clean up.
            obj.server_socket.close;
            obj.output_socket.close;
            
            fprintf(1, '[SERVER: ] Server closed.\n')
        end
    end
end