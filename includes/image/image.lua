local worona = require "worona"

local function newService()

	local image = {}

	--: private functions

	function image:getFoldersArrayFromUrl( url )

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

	function image:getFoldersStringFromUrl( url )

		local folder_array  = image:getFoldersArrayFromUrl( url )
		local folder_string = ""

		for i = 1, #folder_array do
			folder_string = folder_string .. folder_array[ i ] .. "/"
		end

		return folder_string
	end

	function image:getFilenameFromUrl( url )

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
		local folders_string = image:getFoldersStringFromUrl( options.url )
		local filename       = image:getFilenameFromUrl( options.url )

		--: check if this image has already been downloaded, if it's not, locateFileBaseDirectory returns -1
		local image_baseDirectory = worona.file:locateFileBaseDirectory( "content/images/" .. folders_string .. filename )

		--: set function to apply the parameters to the image, not matter if it's in the phone or has been downloaded
		local function applyParameters ( img, img_container )
			-- img.x   = 0
			-- img.y   = 0
			img.width  = final.width
			img.height = final.height
			img_container:insert(img, true)
		end

		--: if image is not here, we have to download it
		if image_baseDirectory == -1 then

			--. Creating a table listener for display.loadRemoteImage
			function newTableListener( loading_rectangle, img_container )	-- constructor
					
				local that = {}

				that.loading_rectangle = loading_rectangle
				that.img_container     = img_container
				
				function that:networkRequest( event )

					if ( event.isError ) then
						worona.log:warning( "image.lua/newImage: Network error - download failed." )
					else

						img = event.target

						if img ~= nil then
							
							img.alpha  = 0
							img.width  = 1
							img.height = 1

							applyParameters( img, that.img_container )

							transition.to( img, { alpha = 1.0 } )

							display.remove( that.loading_rectangle )
							that.loading_rectangle = nil

							worona.log:info( "image.lua/downloadImageClosure: Download Success." )
						else
							worona.log:error("image.lua/downloadImageClosure: the image is not in the phone, but Corona tries to load it as if it were")
						end
					end
				end
				
				return that
			end

			

			
			--: display a rectangle where the image should be
			local loading_rectangle = display.newRect( 0, 0, final.width, final.height )
			loading_rectangle:setFillColor( 0.7 )
			container:insert( loading_rectangle )

			local table_listener_obj = newTableListener( loading_rectangle, container )


			--: create the folders
			worona.file:createFolder( "content/images/" .. folders_string, options.directory )

			worona.log:info("image.lua/newImage: Starting the download of '" .. options.url .. "' in 'content/images/" .. folders_string .. filename )
			--: download image
			display.loadRemoteImage( options.url, "GET", table_listener_obj, "content/images/" .. folders_string .. filename, options.directory )

		--: if image is in the phone, let's display it
		else
			worona.log:info("image.lua/newImage: Image '" .. filename .. "' is in the phone, lets display it.")

			if img == nil then
				img = display.newImageRect( "content/images/" .. folders_string .. filename, image_baseDirectory, 1, 1 )
				
				if img ~= nil then
					img.alpha = 0

					applyParameters( img, container )	
					img.alpha = 1
				else
					worona.log:error("image.lua/newImage: the image is not in the phone, but Corona tries to load it as if it were")
				end

			end

		end

		return container

	end

	return image
end


worona:do_action( "register_service", { service = "image", creator = newService } )
