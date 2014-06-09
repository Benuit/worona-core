-- UI: uiImage   
uiImage = {}

function uiImage:new( )


	--: default values :--
	local val = {
		img_filename  = "unicornBLOOD.jpg",
		width         = 170,
		height        = 200,
		alpha         = 1,
		x             = 0,
		y             = 0,
		anchorX       = 0.5,
		anchorY       = 0.5,
		frame_name    = false,
		handlers_list = {}
	}

	-- creates the display object
	
	local this = uUI:new( "uiImage", bloodGroup )

	local fileUtils = require "worona.lib.utils.fileUtils"
		
	local img 	--: the actual image :--


	--: private functions :--
	local function parseEventHandlers( obj )

		for event, func in pairs(val.handlers_list) do
			
			obj:addEventListener( event, func )
		end
	end

	-- methods
	
	function this:refresh()

		this:removeTexture()

		if val.frame_name then --. when an image is in an imagesheet, the directory will always be system.ResourceDirectory
			log:info("uiImage/setObject: image is inside an imagesheet")	
			local imageSheetLuaPath = "resources.img." .. val.img_filename
			local imageSheetPngPath = "rsrc/img/" .. val.img_filename .. ".png"
			local imageSheetInfo    = require(imageSheetLuaPath)
			local imageSheet        = graphics.newImageSheet( imageSheetPngPath, imageSheetInfo:getSheet() )
			img                     = display.newImageRect( imageSheet, imageSheetInfo:getFrameIndex( val.frame_name ), this:getWidth(), this:getHeight())
		else
			--log:info("uiImage/setObject: image is not inside an imagesheet")

			local base_directory       = fileUtils:locateFile(val.img_filename)
			local object_relative_path = "rsrc/img/" .. val.img_filename

			if base_directory ~= nil then
				img = display.newImageRect( object_relative_path, base_directory, this:getWidth(), this:getHeight() )
			end
		end

		if img ~= nil then
			img.anchorX = val.anchorX
			img.anchorY = val.anchorY
			img.x       = val.x
			img.y       = val.y
			img.alpha   = val.alpha
			parseEventHandlers( img )
			this:insert( img )
		else
			log:error("uiImage/setObject: IMAGE NOT FOUND")
		end

		img = imageUtils:loadImage( { 	filepath  = val.filepath, 
										directory = val.directory, 
										width     = val.width, 
										height    = val.height, 
										color     = "white", 
										url       = val.url } )
		img.anchorX = val.anchorX
		img.anchorY = val.anchorY
		img.x       = val.x
		img.y       = val.y
		img.alpha   = val.alpha
		parseEventHandlers( img )
		this:insert( img )

	end

	function this:removeTexture()
		if img ~= nil then
			img:removeSelf()
			img = nil
			return true
		else
			return false
		end
	end

	function this:setImage( newImage )
		val.img_filename = newImage
	end

	function this:setWidth ( newWidth )
		val.width = newWidth
	end

	function this:setHeight ( newHeight )
		val.height = newHeight
	end

	function this:setAlpha ( newAlpha )
		if newAlpha >= 0 and newAlpha <= 1 then
			val.alpha = newAlpha
		else
			log:warning("Alpha value must be in the range [0 , 1]")
		end
	end

	function this:setX ( newX )
		val.x = newX
	end

	function this:setY ( newY )
		val.y = newY
	end

	function this:setRP ( anchorX, anchorY )
		this:setAnchorX( anchorX )
		this:setAnchorY( anchorY )
	end

	function this:getRP()
		return this:getAnchorX(), this:getAnchorY()
	end

	function this:setAnchorX( anchorX )
		val.anchorX = anchorX
	end

	function this:getAnchorX()
		return val.anchorX
	end

	function this:setAnchorY( anchorY )
		val.anchorY = anchorY
	end

	function this:getAnchorY()
		return val.anchorY
	end

	function this:getImage()
		return val.img_filename
	end

	function this:getWidth()
		return val.width
	end

	function this:getHeight()
		return val.height
	end

	function this:getAlpha()
		return val.alpha
	end

	function this:getX()
		return val.x
	end

	function this:getY()
		return val.y
	end

	

	function this:addEventHandler( event, func )
		val.handlers_list[ event ] = func
	end

	function this:getRealHeight()
		return val.height
	end





	--. EVENT HANDLERS
	--. Adds an event listener .--
		--. RETURN: true if the event called has been implemented
		--. ARGUMENTS: 
		--. 	event: mainly it´s gonna be "touch"
		--. 	func: the function that´s gonna be called then the event is produced
	-- function this:addEventHandler( event, func )
	-- 	if event == "touch" then
	-- 		img:addEventListener( "touch", func )			
	-- 		return true
	-- 	else
	-- 		log:warning("uiImage/addEventHandler: event `" .. event .. "` not implemented.")
	-- 		return false
	-- 	end
	-- end

	function this:removeEventHandler( event, listenerFunc )
		img:removeEventListener( event , listenerFunc)
		return true
	end


	return this
end




return uiImage 
 