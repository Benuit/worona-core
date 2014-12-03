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
	
	--[[	
		checkConnection 
		
		Checks if there´s internet connection available.
		 	
		@type: type
		@date: 06/2014 or so
		@since: 0.6
	
		@param: -
		@return: true if connection available, false if not
	
		@example: local connection_available = checkConnection()
	]]--
	local function checkConnection(website, timeout)

	    --: private variables :--
	    local website = website or "www.google.com" -- if you want to test your site instead, use: string.gsub( worona.wp_url, "[htps]*://", "") -- Note that the test does not work if we put http:// in front
	    local timeout = timeout or 3
		local connection_available

		local socket = require("socket")
		            
		local test = socket.tcp()
		test:settimeout( timeout )
		            
		local testResult = test:connect( website, 80) 
		 
		if testResult ~= nil then
			worona.log:info("content/checkConnection: Internet access is available")
		    connection_available = true
		else
			worona.log:info("content/checkConnection: Internet access is not available")
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

		if content_table[ content_type ] ~= nil then
			for k,v in pairs( content_table[ content_type ] ) do
				content_urls_table[v.link] = content_type
			end
		else
			worona.log:error("content/checkContentUrls: content_table[ content_type ] = nil")
		end
	
	end
	

	--. PUBLIC METHODS .--
	--[[	
		urlCustomPostType 
		
		Returns the type of the custom post type of a certain url
		 	
		@type: service
		@date: 06/2014
		@since: 0.6
	
		@param: url from which type is requested
		@return: type of the custom post type, or false.
	
		@example: scene_type = worona.content:urlCustomPostType(url)
	]]--
	function content:urlCustomPostType( url ) 
		for k,v in pairs (content_urls_table) do
			if k == url then
				return v
			end
		end
		return false
	end


	--[[	
		readContentFile 
		
		Reads the content file from a certain content_type, and stores a table with the content of the file
		in content_table.
		 	
		@type: service
		@date: 06/2014
		@since: 0.6
	
		@param: content_type ("post", "customcontent")
		@return: true if reading went ok, -1 if error ocurred.
	
		@example: local read_ok = worona.readContentFile("post")
	]]--
	function content:readContentFile( content_type )

		local json_file, json_table

		local content_file_path = "content/json/".. content_type .. ".json"

		json_file = worona.file:getFileContent( content_file_path )

		if json_file ~= -1 then
			--: no errors, file exist :--
			json_table = json.decode( json_file )
			if json_table == nil then
				-- native.showAlert(	worona.lang:get("popup_empty_content_error_title", "content"), 
				-- 				 	worona.lang:get("popup_empty_content_error_description", "content"), 
				-- 				 	{	
				-- 				 		worona.lang:get("popup_empty_content_error_button_1", "content")
				-- 				 	}, 
				-- 				 	nativeAlertListener 
				-- 				)

				worona.log:warning("content/readContentFile: json_table = 'nil'" )

				local function nativeAlertListener( event )
				    if "clicked" == event.action then
				        if event.index ~= nil then
				        	worona.log:info("content/readContentFile: nativeAlertListener() - option 1 selected")
				        end
				    end
				end

				
			
			end
			worona.log:info( "content/readContentFile: Successful JSON reading (`" .. content_file_path .. "`)" )
			content_table[content_type] = json_table
			checkContentUrls( content_type )
			return true
		else
			--: error, file doesn't exist :--
			worona.log:info("content.lua/readContentFile: Unable to open JSON file (`" .. content_file_path .. "`)" )
			return -1
		end
	end

	--[[	
		update 
		
		Syncronizes the content of a certain content_type from a specific url.
		 	
		@type: service
		@date: 06/2014
		@since: 0.6
	
		@param: content_type (string) : content type to be updated
				url (string) : url from which the content will be downloaded.
		@return: -
	
		@example: worona.content:update("post", "http://www.worona.org")
	]]--
	function content:update( options )

		local content_type, url

		--. Function arguments compatible with table (worona.content:update( {content_type = "customcontent", url = "testing.turismob.com"} ))
		if type(options) ~= "table" then
			content_type = options
			--url = worona.wp_url .. "/wp-json/posts?type=" .. content_type
			url = "http://www.civitatis-api.dev/civitatis-api.php?type=" .. content_type
		else
			content_type = options.content_type
			local base_url = options.url or worona.wp_url
			url = base_url .. "/wp-json/posts?type=" .. content_type
		end

		--: this solves a problem with OSX cache.db
		local platformName = system.getInfo( "platformName" )
		if platformName == "Mac OS X" or platformName == "iPhone OS" then
			url = url .. "&rnd=" .. os.time()
		end
		

		local content_file_path = "content/json/".. content_type .. ".json"

		local internet_available = checkConnection("www.google.com") --. test connection to a working site to check if there is internet connection.
		if internet_available == false then
			worona.log:warning("content/update: Internet connection is not available.")
			-- native.showAlert(	worona.lang:get("popup_connection_error_1_title", "content"), 	
			-- 					worona.lang:get("popup_connection_error_1_description", "content") , 
			-- 					{ 
			-- 						worona.lang:get("popup_connection_error_1_button_1", "content"), 
			-- 						worona.lang:get("popup_connection_error_1_button_2", "content") 
			-- 					}, 
			-- 					nativeAlertListener 
			-- 				)
		else
			local wp_url_connection = checkConnection(string.gsub( worona.wp_url, "[htps]*://", ""))
			if wp_url_connection == false then
				worona.log:warning("content/update: Internet connection is available, but cannot connect to: '" .. worona.wp_url .. "'. Please check your WordPress site configuration.")
				
				-- native.showAlert(	worona.lang:get("popup_connection_error_2_title", "content"), 	
				-- 					worona.lang:get("popup_connection_error_2_description", "content") , 
				-- 					{ 
				-- 						worona.lang:get("popup_connection_error_2_button_1", "content"), 
				-- 						worona.lang:get("popup_connection_error_2_button_2", "content") 
				-- 					}, 
				-- 					nativeAlertListener 
				-- 				)

			else
				worona.log:info("content/update: Successful connection to: '" .. worona.wp_url .. "'.")
			end
		end



		--. download function callback
		local function fileNetworkListener( event )
			if ( event.isError ) then
				worona.log:warning ( "content/fileNetworkListener: Download failed. '" .. content_file_path .. "' , '" .. url .. "'." )
				worona:do_action( "connection_not_available" )
			elseif ( event.phase == "began" ) then
				worona.log:info( "content/fileNetworkListener: download began from url = '" .. url .. "'" )
			elseif ( event.phase == "ended" ) then
				if event.response.filename ~= nil then
					worona.log:info ( "content/fileNetworkListener: download ended. File name: " .. event.response.filename )
				else
					worona.log:info ( "content/fileNetworkListener: download ended. File name: NOT FOUND - SERVER ERROR" )
				end
				local read_success = worona.content:readContentFile( content_type ) --. read content file once downloaded.
				if read_success == -1 then
					worona.log:info("content/fileNetworkListener: reading content file '" .. content_type .. "' was not Successful.")
					worona:do_action( "connection_not_available" )
				else
					checkContentUrls(content_type)
					worona:do_action("content_file_updated", { content_file_path = content_file_path, content_type = content_type } )
				end
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
				return v 
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

	worona:add_action( "init", function() worona.lang:load("worona-core.includes.content.lang.content-lang", "content") end )

	return content
end

worona:do_action( "register_service", { service = "content", creator = newContentService } )
