local worona = require "worona"

local function newService()

  local socket = require "socket"
	local html_server = {}

	--: creates a retrieves a new server
	function html_server:newServer( options )

        --: local variables
        local success, err, server

        --: defaults
        local options = options		 or {}
        local host	= options.host	or "localhost"
        local port	= options.port	or "1024"
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
			--: receive the data which has been sent to the server
			message, err = client:receive('*l')

			if message ~= nil then

				local method, uri, protocol = string.match( message, "([A-Z]+) (.+) (.+)" )

				local args = worona.network:getArgs( uri )

				worona.log:info("html_server: Received. " .. message )

				if args and args.render ~= nil then
					worona.log:info( "html_server: Rendering the internal url '" .. args.render .. "'" )
					local html_Path = system.pathForFile( "content/html/" .. args.render .. ".html", system.CachesDirectory )
					local html_File = io.open( html_Path, "r" )
					local html_Data = html_File:read( "*a" )
					html_File:close()
					client:send( headers .. html_Data )
					client:close()
				elseif args and args.url ~= nil then
					worona.log:info( "html_server: We are on iPhone and user clicked on a link with url '" .. args.url .. "'" )
					worona:do_action( "load_url", args )
				elseif args and args.img ~= nil then
				  --: get the folders and the filename, from the url
				  local url            = args.img
				  local folders_string = worona.image:getFoldersStringFromUrl( url )
				  local filename       = worona.image:getFilenameFromUrl( url )
				  local file_path      = system.pathForFile("/content/html/images/" .. folders_string .. filename, system.CachesDirectory)

                  worona.log:info( "html_server: Image petition of " .. url )
                  worona.log:info( "html_server: Looking for " .. file_path )

				  local image = io.open( file_path, "rb" )
                  if image ~= nil then
                      worona.log:info( "html_server: Image " .. filename .. " opened.")
                      client:send( image:read( "*a" ) )
    				  client:close()
    				  io.close( image )
                  else
                      worona.log:info( "html_server: Image " .. filename .. " couldn't be opened.")
                      headers = [[HTTP/1.1 404 Not Found
                      Date: ]] .. worona.date:convertTimestampToDate( os.time() ) .. [[
                      Server: WoronaServer
                      Connection: Closed
                  ]]
                      client:send( headers )
                      client:close()
                  end
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
