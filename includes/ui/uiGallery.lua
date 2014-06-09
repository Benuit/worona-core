-- UI: uiGallery   
local uiGallery = {}

function uiGallery:new( bloodGroup )

	--: DEFAULT VALUES :--
	local val = {
		y                  = display.topStatusBarContentHeight + 8,
		number_of_images   = 10,
		width              = display.contentWidth,
		images_per_row     = 4,
		space_between_rows = 8,
		image_width        = 70,
		image_height       = 70
	}

	local that = uUI:new( "uiGallery", bloodGroup )


	--: LIBRARIES :--
	local deviceUtils = "require.lib.deviceUtils"


	--: PRIVATE VARIABLES :--
	local _data_of_images            = {}
	local _instances_of_images       = {}
	local _default_thumbnail         = "unicornBLOOD.jpg"
	local _default_image             = "unicornBLOOD.jpg"
	local _image_set                 = { "unicornBLOOD.jpg", "unicornBLOOD.jpg" }
	local _default_touchEventHandler = function( event ) 
                                  if event.phase == "ended" then 
                                    
                                    that:renderSlideView()
                                  end 
                                end
	

	--: PRIVATE METHODS :--

	local function getCurrentRow( number_of_image )

		return math.floor( ( number_of_image - 1 ) / val.images_per_row ) + 1
	end


	local function getCurrentColumn( number_of_image )

		return ( ( number_of_image - 1 ) % val.images_per_row ) + 1
	end


	--: generate the tables to store all the image data :--
	local function generateImageData( number )
		
		for i = 1, number do
	
			_data_of_images[ i ] = _data_of_images[ i ] or {} --: creates the table if it doesn't exist :--

			image = _data_of_images[ i ]

			image.thumbnail = image.thumbnail or _default_thumbnail
			image.image = image.image or _default_image
			image.touchEventHandler = image.touchEventHandler or _default_touchEventHandler
		end
	end


	local function generateImageInstances( number )

		for i = 1, number do
			
			_instances_of_images[ i ] = _instances_of_images[ i ] or that.blood:getInjection( that, "uiImage" )
			
			local img                   = _instances_of_images[ i ]
			local data                  = _data_of_images[ i ]
			local current_row           = getCurrentRow( i )
			local current_column        = getCurrentColumn( i )
			local space_between_columns = that:getSpaceBetweenColumns()
			
			img:setImage( data.thumbnail )
			
			img:setWidth( val.image_width )
			img:setHeight( val.image_height )

			img:setRP( 0, 0 )
			img:setX( ( current_column * space_between_columns ) + ( ( current_column - 1 ) * val.image_width ) + ( display.contentWidth - val.width ) / 2 )
			img:setY( val.y + ( current_row - 1 ) * ( val.image_height + val.space_between_rows ) )
			img:addEventHandler( "touch", data.touchEventHandler )

			img:refresh()
		end
	end



	--: PUBLIC METHODS :--

	function that:refresh()

		that:removeTexture()
		generateImageData( val.number_of_images )
		generateImageInstances( val.number_of_images )

	end


	function that:removeTexture()
		for i = 1, #_instances_of_images do
			display.remove( _instances_of_images[ i ] )
			_instances_of_images[ i ] = nil
		end
	end


	function that:setNumberOfImages( number_of_images )
		val.number_of_images = number_of_images
		generateImageData( val.number_of_images )
	end


	function that:getNumberOfImages()
		return val.number_of_images
	end


	function that:setWidth( width )
		val.width = width
	end


	function that:getWidth()
		return val.width
	end


	function that:getHeight()
		local number_of_rows = math.ceil(val.number_of_images/val.images_per_row)
		return (number_of_rows - 1) * val.space_between_rows + number_of_rows * _defaultval.image_height
	end


	function that:setImagesPerRow( images_per_row )
		val.images_per_row = images_per_row
	end


	function that:getImagesPerRow()
		return val.images_per_row
	end


	function that:setSpaceBetweenRows( space_between_rows )
		val.space_between_rows = space_between_rows
	end


	function that:getSpaceBetweenRows()
		return val.space_between_rows
	end


	function that:getSpaceBetweenColumns()
		return ( val.width - ( val.image_width * val.images_per_row ) ) / ( val.images_per_row + 1 )
	end


	function that:setImageWidth( image_width )
		val.image_width = image_width
	end


	function that:getImage_width()
		return val.image_width
	end


	function that:setImageHeight( image_height )
		val.image_height = image_height
	end


	function that:getImageHeight()
		return val.image_height
	end


	function that:setThumbnail( thumbnail_file, image_number )
		
		--: generates more images if there are not enough :--
		if image_number > val.number_of_images then
			generateImageData( image_number )
		end

		--: stores the new thumbnail file value :--
		_data_of_images[ image_number ].thumbnail = thumbnail_file
	end


	function that:setImage( image_file, image_number )
		
		--: generates more images if there are not enough :--
		if image_number > val.number_of_images then
			generateImageData( image_number )
		end

		--: stores the new image file value :--
		_data_of_images[ image_number ].image = image_file
	end

	function that:setImageSet( image_set )
		_image_set = image_set
	end

	function that:setThumbnailSet( thumbnail_set )
		for i = 1, #thumbnail_set do
			that:setThumbnail( thumbnail_set[ i ], i )
		end
	end

	function that:renderSlideView()
		local slideView = that.blood:getInjection( that, "uiSlideView" )
		slideView:setImageSet( _image_set )
		slideView:refresh()
	end

	function that:addEventHandler( event, func, tab )

		if event == "touch" then

			if tab ~= nil then
				if tab <= val.number_of_images then
					_data_of_images[ tab ].touchEventHandler = func
				else
					log:warning( "uiTabBar: you are trying to add behavior to a tab which doesn't exist." )
				end
			else
				for i = 1, #_data_of_images do
					_data_of_images[ i ].touchEventHandler = func
				end
			end
			return true
		else
			log:warning( "uiGallery: in tabbars only `touch` is allowed. Do not use " .. event .. "." )
			return -1
		end
	end


	return that
end

return uiGallery 
 