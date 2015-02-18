local worona = require "worona"

local function newService()

    local socket = require "socket"
	local html_server = {}

    -- Parse values from query
    local function getArgs( query )

            query_pos = string.find( query, "/?" ) --: get position of the ?
            query = string.sub( query, query_pos+2 ) --: remove everything before that

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

    --: creates a retrieves a new server
    function html_server:newServer( options )

      --: local variables
      local success, err, server

      --: defaults
      local options = options         or {}
      local host    = options.host    or "localhost"
      local port    = options.port    or "1024"
      local backlog = options.backlog or 32
      local timeout = options.timeout or 0

      --: start the tcp server
      server, err = socket.tcp()

      --: reuse the address if it exist
      server:setoption( "reuseaddr" , true )

      if server ~= nil then

        worona.log:info("html_server: starting initialization")

        --: define a host and port for the server
        success, err = server:bind( host, port )

        if success == 1 then

          worona.log:info("html_server: bind to " .. host .. ":" .. port)

          --: start listening to a number of incoming connections
          success, err = server:listen( backlog )

          if success == 1 then

            worona.log:info("html_server: listening to a max of " .. backlog .. " connections" )

            --: set the timeout of the accept() process. this is a blocking process, so until it receives something it will block the execution
            --: we are going to use the corona Runtime:addEventListener( "enterFrame" , function ) so we can set the timeout to nothing (0)
            success, err = server:settimeout( timeout )

            if success == 1 then

              worona.log:info("html_server: success setting a timeout of " .. timeout )

              --: everything went fine, return the server
              worona.log:info("html_server: initialised succesfully, returning")

              --: add the server to the html_server table
              html_server.server = server

                --: return the server and end function
              return server

            end

          end

        end

      end

      --: something went wrong, return nil and the error

      return nil, "html_server: failed with error " .. err
    end

    --: function to retrieve clients
    function html_server:processPetition( server )

        local server = server or html_server.server

      return function()

        --: local variables
        local client, message
        local err = "server is nil"
        local headers = [[HTTP/1.1 200 OK
        Date: ]] .. worona.date:convertTimestampToDate( os.time() ) .. [[
        Server: WoronaServer
        Content-Type: text/html
        Connection: Closed

        ]]

        if server ~= nil then

          --: accept an incoming connection creating a client we can use to receive and send data
          client, err = server:accept()

          if client ~= nil then

            worona.log:info("html_server: found a connection to accept" )

            --: receive the data which has been sent to the server
            message, err = client:receive('*l')

            if message ~= nil then

                local method, uri, protocol = string.match( message, "([A-Z]+) (.+) (.+)" )

                local args = getArgs( uri )

                worona.log:info("html_server: received. " .. message )

                if args.render ~= nil then
                    worona.log:info( "html_server: Rendering the internal url '" .. args.render .. "'" )
                    local html_Path = system.pathForFile( "content/html/" .. args.render .. ".html", system.CachesDirectory )
                    local html_File = io.open( html_Path, "r" )
                    local html_Data = html_File:read( "*a" )
                    html_File:close()
                    client:send( headers .. html_Data )
                    client:close()
                elseif args.url ~= nil then
                    worona.log:info( "html_server: We are on iPhone and user clicked on a link with url '" .. args.url .. "'" )
                    worona:do_action( "load_url", args )
                end

                return

            end

          else

            return nil

          end

        end

        worona.log:warning("Something went wrong. Error: " .. err )

      end
    end

	return html_server
end

worona:do_action( "register_service", { service = "html_server", creator = newService } )

local function initialiseServer()
    worona.log:info( "html_server: about to start the html server" )
    local server, err = worona.html_server:newServer()
    if server ~= nil then
        Runtime:addEventListener( "enterFrame", worona.html_server:processPetition() )
    else
        worona.log:warning("html_server: failed to start due to error " .. err )
    end
end

--: start the server
local function startHtmlServer()

	initialiseServer()

    local function onSystemEvent( event )
        if event.type == "applicationResume" then
            initialiseServer()
        end
    end
    Runtime:addEventListener( "system", onSystemEvent )
end

worona:add_action( "init", startHtmlServer )
