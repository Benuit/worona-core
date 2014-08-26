local worona = require "worona"

local function newService()

	local html_server = {}

	
	--: private variables
	local tcpServer

	--: private functions
	local function getArgs( query )
        local parsed = {}
        local pos = 0

        query = string.gsub(query, "&amp;", "&")
        query = string.gsub(query, "&lt;", "<")
        query = string.gsub(query, "&gt;", ">")

        local function ginsert(qstr)
                local first, last = string.find(qstr, "=")
                if first then
                        parsed[string.sub(qstr, 0, first-1)] = string.sub(qstr, first+1)
                end
        end

        while true do
                local first, last = string.find(query, "&", pos)
                if first then
                        ginsert(string.sub(query, pos, first-1));
                        pos = last+1
                else
                        ginsert(string.sub(query, pos));
                        break;
                end
        end
        return parsed
	end

	local function createTCPServer( port )
        local socket = require("socket")
        
        -- Create Socket
        local tcpServerSocket , err = socket.tcp()
        local backlog = 5
        
        -- Check Socket
        if tcpServerSocket == nil then 
                return nil , err
        end
        
        -- Allow Address Reuse
        tcpServerSocket:setoption( "reuseaddr" , true )
        
        -- Bind Socket
        local res, err = tcpServerSocket:bind( "*" , port )
        if res == nil then
                return nil , err
        end
        
        -- Check Connection
        res , err = tcpServerSocket:listen( backlog )
        if res == nil then 
                return nil , err
        end
    
        -- Return Server
        return tcpServerSocket        
	end

	--: public methods
	function html_server:startServer()

        if runTCPServer ~= nil then
            Runtime:removeEventListener( "enterFrame" , runTCPServer )
        end
      
        runTCPServer = function()
            tcpServer:settimeout( 0 )
            local tcpClient , _ = tcpServer:accept()
            if tcpClient ~= nil then
                    local tcpClientMessage , _ = tcpClient:receive('*l')
                    if tcpClient ~= nil then                              
                        tcpClient:close()
                    end
                    if ( tcpClientMessage ~= nil ) then
                        local myMessage =  tcpClientMessage
                        local event = {}

                        local xArgPos = string.find( myMessage, "?" )
                        if xArgPos then
                            local newargs = getArgs(string.sub( myMessage, xArgPos+1 ))    
                            worona.log:info( "html_server: User clicked on a link with url '" .. newargs.url .. "'" )
                        end                                                                                                                                              
                    end
            end
        end
        
        if tcpServer == nil then 
            tcpServer, _ = createTCPServer( "8087" )
        end

        Runtime:addEventListener( "enterFrame" , runTCPServer )	        
	end

	return html_server
end

worona:do_action( "register_service", { service = "html_server", creator = newService } )

--: start the server
local function startHtmlServer()
	worona.log:info( "html_server: about to start the html server" )
	worona.html_server:startServer()
end

worona:add_action( "init", startHtmlServer )