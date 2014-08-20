local worona = require "worona"

local function newService()

	local image = {}

	--: private functions

	local function getFoldersArrayFromUrl( url )
		
		local folder_array = {}

		local replace = ".+://" 
		local pattr   = "(.-)/" 

		url = string.gsub( url, replace, "" ) --: remove http:// or https://

		--: gets any string before a "/" character
		for folder in string.gmatch( url, pattr ) do 
			folder = string.gsub( folder, "[.]", "" )
			folder_array[ #folder_array + 1 ] = folder
		end

		return folder_array
	end

	local function getFoldersStringFromUrl( url )

		local folder_array  = getFoldersArrayFromUrl( url )
		local folder_string = ""

		for i = 1, #folder_array do
			folder_string = folder_string .. folder_array[ i ] .. "/"
		end

		return folder_string
	end

	local function getFilenameFromUrl( url )

		local replace = ".+/"
		local filename = string.gsub( url, replace, "" ) --: remove everything until the final "/" character
		return filename
	end

	local function calculateFinalDimensions( options )

		local final_width, final_height
		local width, height           = options.width, options.height
		local real_width, real_height = options.real_width, options.real_height

		if width ~= nil and height == nil then
			final_width  = width
			final_height = real_height * width / real_width
		elseif height ~= nil and width == nil then
			final_height = height
			final_width  = real_width * height / real_height
		elseif width ~= nil and height ~= nil then
			real_ratio  = real_width / real_height
			final_ratio = width / height
			if real_ratio >= final_ratio then
				final_height = height
				final_width  = real_width * height / real_height
			elseif real_ratio < final_ratio then
				final_width  = width
				final_height = real_height * width / real_width
			end
		end

		return { width = final_width, height = final_height }
	end


	--: public methods

	function image:getImageSize( options )
			--. calculate the scale ratio of the device to know which images should we render .--
			local scale_ratio = display.pixelWidth / SCREENWIDTH	
			local real_width  = options.width * scale_ratio
			local sizes_array = {100, 200, 400, 800, 1600}
			local image_size
			
			for i=1, #sizes_array do
				if i == 1 then
					if real_width <= sizes_array[1] then
						image_size = sizes_array[1]
					end
				elseif real_width <= sizes_array[i]  and real_width > sizes_array[i-1] then
					image_size = sizes_array[i]
				end
			end
			
			if image_size == nil then
				image_size = sizes_array[#sizes_array]
			end
			
			return image_size
	end

	--. OPTIONS
	--. - image_object: the image object as returned by the wordpress json API
	--. - parent: the display group to be inserted
	--. - image_path: path of the image. Ex: "rsrc/images/"
	--. - shape: 
	--.		- "normal" (with and height can be equal or not)
	--.		- "square" (forces width = height by cropping the image using a container)
	--.     NOTE: if shape == "square" and width ~= height, it always takes WIDTH as reference.
	--. - directory: system directory where the image should be downloaded to (if it´s downloaded). Ex: system.TemporaryDirectory
	--. - keep_ratio: false(default)/true. Keeps the ratio of the image width/height. If its true, it takes the WIDTH to make the calculations.
	--. - width: width
	--. - height: height
	--. - x: x
	--. - y: y

	function image:newImage(options)
		local img --. the actual image object

		options.image_path = options.image_path or ""
		options.shape      = options.shape or "normal"
		options.directory  = options.directory or system.TemporaryDirectory
		options.parent     = options.parent or display.getCurrentStage()
		
		local image_size = options.shape .. "-" .. image:getImageSize(options)

		local image_file_name = string.match( options.image_object.sizes[image_size], '([^/]+)$')
		local image_file_path = options.image_path .. image_file_name
		
		local image_baseDirectory = worona.file:locateFileBaseDirectory(image_file_path)

		local real_width  = image_size .. "-width"
		local real_height = image_size .. "-height"
		real_width        = options.image_object.sizes[real_width]
		real_height       = options.image_object.sizes[real_height]

		options.height = options.height or options.width * options.image_object.height / options.image_object.width

		local loading_rectangle --. rectangle that appears while image is being downloaded
		local container = display.newContainer( options.parent, options.width, options.height) --. container group
		container:translate( options.x, options.y )

		local function makeImageSquare ()

			container.height = options.width
		
			if real_width == real_height then
				--. do nothing
			elseif real_width > real_height then			
				img.height = options.width
				img.width = options.height/real_height * real_width
				
			else
				img.width = options.width
				img.height = options.width/real_width * real_height
				
			end
		end

		local function applyParameters ()
			img.x = options.x
			img.y = options.y
			img.width = options.width
			img.height = options.width/real_width * real_height
			container:insert(img, true)
			if options.shape == "square" then
				makeImageSquare()
			end
		end
		
		local function downloadImageListener( event )
			if ( event.isError ) then
				print ( "Network error - download failed" )
			else
				event.target.alpha = 0
				transition.to( event.target, { alpha = 1.0 } )
				
				img = event.target
				
				applyParameters()

				if loading_rectangle ~= nil then
					loading_rectangle:removeSelf()
					loading_rectangle = nil
				end
			end
		end
		
		if image_baseDirectory == nil then --. Image has not been downloaded yet
			loading_rectangle = display.newRect( 0, 0, options.width, options.height )
			container:insert(loading_rectangle)
			if options.shape == "square" then
				loading_rectangle.height = options.width
			end 
			loading_rectangle:setFillColor(0.5)
			display.loadRemoteImage( options.image_object.sizes[image_size], "GET", downloadImageListener, image_file_path, options.directory)
		else
			img = display.newImageRect( image_file_path, image_baseDirectory, options.width, options.height )
		end

		if img ~= nil then
			applyParameters()
		end

		local image_object = {}

		image_object._proxy = container._proxy

		setmetatable( image_object, {
		  	__index = function(table, key)
		  		return container[key]
			end,
			__newindex = function(table, key, value)
		    	if key == "width" or key == "height" then
		    		
		    		img[key] = value
		    		container[key] = value
			    else
		        	container[key] = value
		        end
			end
		})

		return image_object
	end

	--[[ options table:
		url: 
		real_width: 
		real_height:
		width: (optional, but either width or height present)
		height: (optional, but either width or height present)
		x:
		y:
		directory: (optional, defaults to system.DocumentsDirectory)
		]]--
	function image:newImage( options )

		--: set defaults
		local img
		local parent = options.parent or display.getCurrentStage()

		--: calculate the final height and width
		local final = calculateFinalDimensions( { real_width = options.real_width, real_height = options.real_height, width = options.width, height = options.height } )

		--: create the container (it can hide parts of the image)
		local container = display.newContainer( parent, options.width or final.width, options.height or final.height )
		container:translate( options.x, options.y )

		--: get the folders and the filename, from the url
		local folders_string = getFoldersStringFromUrl( options.url )
		local filename       = getFilenameFromUrl( options.url )

		--: check if this image has already been downloaded, if it's not, locateFileBaseDirectory returns -1
		local image_baseDirectory = worona.file:locateFileBaseDirectory( "content/images/" .. folders_string .. filename )

		--: set function to apply the parameters to the image, not matter if it's in the phone or has been downloaded
		local function applyParameters ( img )
			-- img.x   = options.x
			-- img.y   = options.y
			img.width  = final.width
			img.height = final.height
			container:insert(img, true)
		end

		--: if image is not here, we have to download it
		if image_baseDirectory == -1 then
			
			--: callback for downloader
			local function downloadImageClosure( loading_rectangle )
				local function callback( event )
				
					if ( event.isError ) then
						worona.log:warning( "image:newImage: Network error - download of '" .. event.response .. "' failed." )
					else
						img = event.target

						img.alpha = 0
						transition.to( img, { alpha = 1.0 } )
				
						applyParameters( img )

						display.remove( loading_rectangle )
						loading_rectangle = nil

						worona.log:info( "image:newImage: Success - download of '" .. event.response .. "' succeed." )
					end
				end
				return callback
			end

			--: display a rectangle where the image should be
			local loading_rectangle = display.newRect( 0, 0, final.width, final.height )
			loading_rectangle:setFillColor( 0.7 )
			container:insert( loading_rectangle )

			--: create the folders
			worona.file:createFolder( "content/images/" .. folders_string, options.directory )

			worona.log:info("newImage: Starting the download of '" .. options.url .. "' in 'content/images/" .. folders_string .. filename )
			--: download image
			display.loadRemoteImage( options.url, "GET", downloadImageClosure( loading_rectangle ), "content/images/" .. folders_string .. filename, options.directory )

		--: if image is in the phone, let's display it
		else
			worona.log:info("newImage: Image '" .. filename .. "' is in the phone, lets display it.")
			img = display.newImageRect( "content/images/" .. folders_string .. filename, image_baseDirectory, final.width, final.height )
			applyParameters( img )
		end
		
		return container

	end

	return image
end


worona:do_action( "register_service", { service = "image", creator = newService } )