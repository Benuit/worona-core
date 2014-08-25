local worona = require "worona"
local json   = require "json"

local content_type = "post" --. insert content type ( "customcontent" / "post" )

local function newContentService()

	local content = {}

	--. PRIVATE VARIABLES .--
	local content_table = {}  --. content table stores all the content from any kind of the app: content_table = { customcontent = {} , posts = [] }
	local content_urls_table = {} --. array with the urls that are pages or posts included in content. Its intended to be a url cache, so is can be checked whether a url belongs to content or not.
								  --. structure: { "url1" = content_type1 , "url2" = content_type2 , ... }
	--. PRIVATE FUNCTIONS .--
	local function checkConnection()

	    --: private variables :--
	    local website = string.gsub( worona.wp_url, "[htps]*://", "") -- Note that the test does not work if we put http:// in front
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


	--. Checks a content file of content_type type, and stores the URLs of the pages in content_urls_table = {"URL" = "content_type"} .--
		--. RETURN: -
		--. ARGUMENTS: 
		--. 	content_type: "post" or "customcontent"
	local function checkContentUrls( content_type )

		for k,v in pairs( content_table[ content_type ] ) do
			content_urls_table[v.link] = content_type
		end
	
	end
	

	--. PUBLIC METHODS .--

	function content:urlCustomPostType( url ) 
		for k,v in pairs (content_urls_table) do
			if k == url then
				return v
			end
		end
		return false
	end


	function content:readContentFile( content_type )

		local json_file, json_table

		local content_file_path = "content/json/".. content_type .. ".json"

		json_file = worona.file:getFileContent( content_file_path )

		if json_file ~= -1 then
			--: no errors, file exist :--
			json_table = json.decode( json_file )
			worona.log:info( "content-main/readContentFile: Successful JSON reading (`" .. content_file_path .. "`)" )
			content_table[content_type] = json_table
			checkContentUrls( content_type )
			return true
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

		url = url .."/wp-json/posts?type=" .. content_type

		--: this solves a problem with OSX cache.db
		if system.getInfo( "platformName" ) == "Mac OS X" then
			url = url .. "&rnd=" .. os.time()
		end
		

		local content_file_path = "content/json/".. content_type .. ".json"

		-- local connection_available = checkConnection()
		-- local checkConnection_delay = 10000

		-- if connection_available == false then
		-- 	if checkConnection_delay ~= 0 then
		-- 		worona.log:info( "content/content.lua - update: Checking if there is connection or not (delay: '" .. checkConnection_delay .. "')" )
		-- 		timer.performWithDelay( checkConnection_delay, checkConnection )
		-- 	else
		-- 		checkConnection()
		-- 	end
		-- end

		local function fileNetworkListener( event )
			if ( event.isError ) then
				worona.log:error ( "content/content.lua - fileNetworkListener: Download failed. '" .. content_file_path .. "' , '" .. url .. "'." )
				worona:do_action( "connection_not_available" )
			elseif ( event.phase == "began" ) then
				worona.log:debug( "content/content.lua - fileNetworkListener: download began from url = '" .. url .. "'" )
			elseif ( event.phase == "ended" ) then
				if event.response.filename ~= nil then
					worona.log:info ( "content/content.lua - fileNetworkListener: download ended. File name: " .. event.response.filename )
				else
					worona.log:info ( "content/content.lua - fileNetworkListener: download ended. File name: NOT FOUND - SERVER ERROR" )
				end
				worona.content:readContentFile( content_type ) --. read content file once downloaded.
				checkContentUrls(content_type)
				worona:do_action("content_file_updated", {content_file_path = content_file_path} )
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



	--. Returns array with acf values of a page_url of type content_type .--
		--. RETURN: description
		--. ARGUMENTS: 
		--. 	content_type: ex: "customcontent"
		--. 	page_url: page url.
	function content:getPost( content_type, page_url )

		--. Function arguments compatible with table (worona.content:getPage( {content_type = "customcontent", page_url = "http://example.com"} ))
		if type(content_type) == "table" then
			page_url = content_type.page_url
			content_type = content_type.content_type
		end

		if content_table[ content_type ] == nil then
			worona.content:readContentFile( content_type ) --. not sure if this is needed...
		end
		
		for k,v in pairs( content_table[ content_type ] ) do
			if v.link == page_url then
				return v --. Â¡! TO MAKE IT COMPATIBLE WITH POSTS: return v, INSTEAD OF: return v.acf  -->  now we can have: v.acf, v.posts 
			end
		end

		return nil
	end



	--. Returns an array with all the content from content_type json .--
		--. RETURN: description
		--. ARGUMENTS: 
		--. 	Argument1: description
	function content:getPostList( content_type )

		local read_success
		
		--. Function arguments compatible with table (worona.content:getPostList( {content_type = "post", url = "testing.turismob.com"} ))
		if type(content_type) == "table" then
			content_type = content_type.content_type
		end

		local content_file_path = "content/json/".. content_type .. ".json"

		if content_table[ content_type ] == nil then
			read_success = worona.content:readContentFile( content_type )
		end

		if read_success == -1 then return -1 else return content_table[ content_type ] end
	end

	return content
end

worona:do_action( "register_service", { service = "content", creator = newContentService } )


local function readContent()
	local content_types_array = { "post", "customcontent" }
	
	for i=1, #content_types_array do
		worona.log:info("content/main.lua - Reading content type: '" .. content_types_array[i] .. "'")
		worona.content:readContentFile( content_file_path )
	end
end
-- worona:add_action( "init", readContent )





