local worona = require "worona"
local json   = require "json"

local function newContentService()

	local content = {}

	--. PRIVATE VARIABLES .--
	local content_tables = {}

	--. PRIVATE FUNCTIONS .--
	local function checkConnection()

	    --: private variables :--
	    local website = "www.google.com"       -- Note that the test does not work if we put http:// in front
	    local timeout = 3
		local connection_available

		local socket = require("socket")
		            
		local test = socket.tcp()
		test:settimeout( timeout )
		            
		local testResult = test:connect( website, 80) 
		 
		if testResult ~= nil then
			worona.log:info("content-main/checkConnection: Internet access is available")
		    connection_available = true
		else
			worona.log:info("content-main/checkConnection: Internet access is not available")
		    connection_available = false
		end

		test:close()
		test = nil

		return connection_available
	end





	--. PUBLIC METHODS .--

	function content:readContentFile( content_file_path )

		local json_file, json_table

		json_file = worona.file:getFileContent( content_file_path )

		if json_file ~= -1 then
			--: no errors, file exist :--
			json_table = json.decode( json_file )
			worona.log:info( "content-main/readContentFile: Successful JSON reading (`" .. content_file_path .. "`)" )
			return json_table
		else
			--: error, file doesn't exist :--
			worona.log:fatal("content-main/readContentFile: Unable to open JSON file (`" .. content_file_path .. "`)" )
			return -1
		end
	end


	function content:update( content_type, url )

		--. Function arguments compatible with table (worona.content:update( {content_type = "customcontent", url = "testing.turismob.com"} ))
		if type(content_type) == "table" then
			url = content_type.url
			content_type = content_type.content_type
		end

		if content_type ~= "posts" then
			url = url .."/wp-json/posts?type=" .. content_type
		else
			url = url .. "/wp-json/posts"
		end

		local content_file_path = "content/json/".. content_type .. ".json"

		local connection_available = checkConnection()
		local checkConnection_delay = 10000

		if connection_available == false then
			if checkConnection_delay ~= 0 then
				worona.log:info( "content/content.lua - update: Checking if there is connection or not (delay: '" .. checkConnection_delay .. "')" )
				timer.performWithDelay( checkConnection_delay, checkConnection )
			else
				checkConnection()
			end
		end

		local function fileNetworkListener( event )
			if ( event.isError ) then
				worona.log:error ( "content/content.lua - fileNetworkListener: Download failed. '" .. content_file_path .. "' , '" .. url .. "'." )
			elseif ( event.phase == "began" ) then
				worona.log:debug( "content/content.lua - fileNetworkListener: download began from url = '" .. url .. "'" )
			elseif ( event.phase == "ended" ) then
				worona.log:debug ( "content/content.lua - fileNetworkListener: download ended. File name: " .. event.response.filename )
				content_tables = {}
				worona:do_action("content_file_updated", {content_file_path = content_file_path} )
				--. A read is done everytime a page is got, so the file is updated all the time (see content:getPage)
			end
		end
		
		local download_options = {
			url                      = url   , --. URL
			target_file_name_or_path = content_file_path   , --. name of the file that will be stored.
			method                   = "GET"   , --. "GET" or "HEAD"
			target_baseDirectory     = system.DocumentsDirectory  , --. system.DocumentsDirectory or system.TemporaryDirectoy
			listenerFunction         = fileNetworkListener    --. the listener function
		}
		worona.file:download( download_options )
	end

	function content:getPage( page_type, page_id )

		--. Function arguments compatible with table (worona.content:update( {content_type = "customcontent", url = "testing.turismob.com"} ))
		if type(page_type) == "table" then
			page_id = page_type.page_id
			page_type = page_type.page_type
		end

		local content_file_path = "content/json/".. page_type .. ".json"

		if content_tables[ page_type ] == nil then
			content_tables[ page_type ] = worona.content:readContentFile( content_file_path )
		end
		
		for k,v in pairs( content_tables[ page_type ] ) do
			if v.ID == page_id then
				return v.acf
			end
		end

		return nil
	end

	--. Returns an array with all the content from content_type json .--
		--. RETURN: description
		--. ARGUMENTS: 
		--. 	Argument1: description
	function content:getContentList( content_type )
		
		--. Function arguments compatible with table (worona.content:update( {content_type = "customcontent", url = "testing.turismob.com"} ))
		if type(content_type) == "table" then
			content_type = content_type.content_type
		end

		local content_file_path = "content/json/".. content_type .. ".json"

		if content_tables[ content_type ] == nil then
			content_tables[ content_type ] = worona.content:readContentFile( content_file_path )
		end
		
		return content_tables[ content_type ]
	end

	return content
end

return newContentService