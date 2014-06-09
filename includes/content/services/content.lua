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

	local function readContentFile( content_file_path )

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

	--. PUBLIC METHODS .--
	function content:update( content_type, url )

		--. Function arguments compatible with table (worona.content:update( {content_type = "customcontent", url = "testing.turismob.com"} ))
		if type(content_type) == "table" then
			url = content_type.url
			content_type = content_type.content_type
		end

		local url = url .."/wp-json/posts?type=" .. content_type
		local content_file_path = "content/json/".. content_type .. ".json"

		local connection_available = checkConnection()
		local checkConnection_delay = 30000

		if connection_available == false then
			if checkConnection_delay ~= 0 then
				worona.log:info( "content-main/update: Checking if there is connection or not (delay: '" .. checkConnection_delay .. "')" )
				timer.performWithDelay( checkConnection_delay, checkConnection )
			else
				checkConnection()
			end
		end

		local function syncImages()

			local content_data = readContentFile (content_file_path)
			local image_array = {}
			local sizes_array = {100, 200, 400, 800, 1600}
			local shapes_array = {"normal", "square"}
			local image_folder_path = "content/images/"

			worona.log:info("content/syncImages: syncronizing images ")

			--. Images bigger than the actual screen are not needed, therefore, we set a maximum image size .--
			local max_image_size = worona.image:getImageSize( {width = SCREENWIDTH} )
			

			
			local function searchTableForImages( table )
				for k,v in pairs(table) do
					if type(v) == "table" then
						searchTableForImages( v )
					else
						if k == "mime_type" then
							if v == "image/png" or v == "image/jpg" or v == "image/PNG" or v == "image/JPG" or v == "image/jpeg" or v == "image/JPEG" then
								image_array[#image_array + 1] = table
							end
						end
					end
				end
			end


			searchTableForImages(content_data)


			local function downloadImageListener( event )
			    if ( event.isError ) then
			        worona.log:error ( "content-main/syncImages/downloadImageListener: Network error - download failed" )
			    elseif ( event.phase == "began" ) then
			        worona.log:debug( "content-main/syncImages/downloadImageListener: download began" )
			    elseif ( event.phase == "ended" ) then
			        worona.log:debug ( "content-main/syncImages/downloadImageListener: download ended. File name: " .. event.response.filename )
			    end
			end

			--. We download ALL the images smaller or equal to the max_image_size in ALL shapes if
			--. they have not already been downloaded.
			for i=1,#image_array do
				for j=1, #sizes_array do
					if sizes_array[j] <= max_image_size then
						for k=1, #shapes_array do
							local image_shape_size = shapes_array[k] .. "-" .. sizes_array[j]
							local img_url = image_array[i].sizes[image_shape_size]
							local image_file_name = string.match( img_url, '([^/]+)$')
							local image_file_path = image_folder_path .. image_file_name
							local image_baseDirectory = worona.file:locateFileBaseDirectory(image_file_path)
							if image_baseDirectory == nil then
								local download_options = {
									url                      = img_url   , --. URL
									target_file_name_or_path = image_file_path   , --. name of the file that will be stored.
									method                   = "GET"   , --. "GET" or "HEAD"
									target_baseDirectory     = system.DocumentsDirectory  , --. system.DocumentsDirectory or system.TemporaryDirectoy
									listenerFunction         = downloadImageListener    --. the listener function
								}
								worona.file:download( download_options )
							else
								worona.log:info("content-main/syncImages: image '" .. image_file_name .. "' is already in the device")
							end
						end
					end
				end	
			end
		end
		
		local function fileNetworkListener( event )
			if ( event.isError ) then
				worona.log:error ( "content-main/fileNetworkListener: Download failed. '" .. content_file_path .. "' , '" .. url .. "'." )
			elseif ( event.phase == "began" ) then
				worona.log:debug( "content-main/fileNetworkListener: download began from url = '" .. url .. "'" )
			elseif ( event.phase == "ended" ) then
				worona.log:debug ( "content-main/fileNetworkListener: download ended. File name: " .. event.response.filename )
				content_tables = {}
				syncImages(content_file_path)
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
			content_tables[ page_type ] = readContentFile( content_file_path )
		end

		for k,v in pairs( content_tables[ page_type ] ) do
			if v.ID == page_id then
				return v.acf
			end
		end

		return nil
	end

	return content
end

return newContentService