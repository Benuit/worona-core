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
		dummy: ( optional - true/false, false by default ) creates a copy of the image (dummy) so that the memory texture is not erased when the image has been erased.
		]]--
	function image:newImage( options )

		--: set defaults
		local img
		local parent = options.parent or display.getCurrentStage()
		local dummy = options.dummy or false

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
						worona.log:warning( "image:newImage: Network error - download failed." )
					else
						
						if dummy == true then
							local dummy_image = display.newImage( "content/images/" .. folders_string .. filename, image_baseDirectory, display.contentWidth * 128, - 4096 )
							if dummy_image ~= nil then
								dummy_image.width  = 0
								dummy_image.height = 0
								dummy_image.alpha  = 0
							end
						end

						img = event.target

						img.alpha = 0
						transition.to( img, { alpha = 1.0 } )

						applyParameters( img )

						display.remove( loading_rectangle )
						loading_rectangle = nil

						worona.log:info( "image:newImage: Download Success." )
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
			
			if dummy == true then
				local dummy_image = display.newImageRect( "content/images/" .. folders_string .. filename, image_baseDirectory, 0, 0 )
				if dummy_image ~= nil then
					dummy_image.x       = display.contentWidth * 2
				end
			end

			img = display.newImageRect( "content/images/" .. folders_string .. filename, image_baseDirectory, final.width, final.height )

			img.alpha = 1
			if img ~= nil then
				applyParameters( img )
			else
				worona.log:error("newImage: the image is not in the phone, but Corona tries to load it as if it were")
			end
		end

		return container

	end

	return image
end


worona:do_action( "register_service", { service = "image", creator = newService } )
