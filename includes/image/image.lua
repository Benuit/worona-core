local worona = require "worona"

local function newService()

	local image = {}

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

	return image
end

worona:do_action( "register_service", { service = "image", creator = newService } )