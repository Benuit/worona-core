-- UI: uiList   
local uiList = {}

function uiList : new( bloodGroup )

	--: default list values :--
	local val = {
		number_of_elements = 5,
		x                  = 10,
		y                  = display.topStatusBarContentHeight + 10,
		anchorX            = 0,
		anchorY            = 0,
		text_left_gap      = 25,
		text_right_gap     = 49,
		gap_height         = 5,
	
	--: default element values :--
		text             = function(i) return "List Element " .. i; end,
		text_font        = native.systemFontBold,
		text_size        = 16,
		text_red         = 0.171875,
		text_green       = 0.2421875,
		text_blue        = 0.3125,
		text_alpha       = 1,
		text_align       = "left",			--: "center", "left" or "right" :--,
		text_height      = 0,			--: use it to allow multiline text :--,
		bg_default_image = "listRectDefaultBg.png",
		bg_over_image    = "listRectOverBg.png",
		bg_height        = 50,
		bg_width         = display.contentWidth - 20,
		bg_radius        = 0,
		bg_fill_red      = 200,
		bg_fill_green    = 200,
		bg_fill_blue     = 200,
		bg_fill_alpha    = 0,
		bg_stroke_red    = 255,
		bg_stroke_green  = 255,
		bg_stroke_blue   = 255,
		bg_stroke_alpha  = 0,
		bg_stroke_width  = 2,
		image            = "list-no-image.png",
		image_height     = 30,
		image_width      = 30,
		arrow_image      = "listArrow.png",
		arrow_width      = 15,
		arrow_height     = 23,
		element_align    = "center",		--: "center", "left" or "right" :--,
		link             = function(i) return function (event) if event.phase == "ended" then log:test( "List element " .. i .. " has been pressed" ); end end end  --: default touch function :--
	}

	-- creates the display object
	local this = uUI:new( "uiList", bloodGroup )

	--: private variables :--
	local listElements = {}
	local current_height = 0

	--: private functions :--
	local function generateElements( n )
		--: default values :--
		n = n or val.number_of_elements

		--: loop :--
		for i = 1, n do

			if listElements[ i ] == nil then

				listElements[ i ] = {}

				local listElement = listElements[ i ]

				listElement.text             = val.text(i)
				listElement.text_font        = val.text_font
				listElement.text_size        = val.text_size
				listElement.text_red         = val.text_red
				listElement.text_green       = val.text_green
				listElement.text_blue        = val.text_blue
				listElement.text_alpha       = val.text_alpha
				listElement.text_align       = val.text_align
				listElement.bg_default_image = val.bg_default_image
				listElement.bg_over_image    = val.bg_over_image
				listElement.bg_height        = val.bg_height
				listElement.bg_width         = val.bg_width
				listElement.bg_radius        = val.bg_radius
				listElement.bg_fill_red      = val.bg_fill_red
				listElement.bg_fill_green    = val.bg_fill_green
				listElement.bg_fill_blue     = val.bg_fill_blue
				listElement.bg_fill_alpha    = val.bg_fill_alpha
				listElement.bg_stroke_red    = val.bg_stroke_red
				listElement.bg_stroke_green  = val.bg_stroke_green
				listElement.bg_stroke_blue   = val.bg_stroke_blue
				listElement.bg_stroke_alpha  = val.bg_stroke_alpha
				listElement.bg_stroke_width  = val.bg_stroke_width
				listElement.image            = val.image
				listElement.image_height     = val.image_height
				listElement.image_width      = val.image_width
				listElement.arrow_image      = val.arrow_image
				listElement.arrow_width      = val.arrow_width
				listElement.arrow_height     = val.arrow_height
				listElement.element_align    = val.element_align
				listElement.link             = val.link(i)
			end
		end
	end

	local function renderElements( n )

		--: default values :--
		n = n or val.number_of_elements

		--: loop :--
		for i = 1, n do

			local listElement = listElements[ i ]
			local bgButton_image

			listElement.group = display.newGroup()

			--: background color :--
			listElement.bgColor = display.newRoundedRect( 0, current_height, listElement.bg_width, listElement.bg_height, listElement.bg_radius)
			listElement.bgColor:setFillColor( listElement.bg_fill_red, listElement.bg_fill_green, listElement.bg_fill_blue, listElement.bg_fill_alpha )
			listElement.bgColor:setStrokeColor( listElement.bg_stroke_red, listElement.bg_stroke_green, listElement.bg_stroke_blue, listElement.bg_stroke_alpha )
			listElement.bgColor.strokeWidth = listElement.bg_stroke_width
			listElement.group:insert( listElements[i].bgColor )

			--: background image :--

			listElement.bgButton = this.blood:getInjection( this, "uiButton" )     --: get a new uiImage to be used as bg :--
			listElement.bgButton:setDefaultImage( listElement.bg_default_image or "uiListDefault.png" )
			listElement.bgButton:setOverImage( listElement.bg_over_image or "uiListOver.png" )
			listElement.bgButton:setLabel( "" )
			listElement.bgButton:setWidth( listElement.bg_width )
			listElement.bgButton:setHeight( listElement.bg_height )
			listElement.bgButton:setX( 0 )
			listElement.bgButton:setY( current_height )
			listElement.bgButton:addEventHandler( "touch", listElement.link )
			listElement.bgButton:refresh()
			listElement.group:insert( listElements[i].bgButton )

			--: arrow image :--
			listElement.arrowImage = this.blood:getInjection( this, "uiImage" )
			listElement.arrowImage:setImage( listElement.arrow_image )
			listElement.arrowImage:setWidth( listElement.arrow_width )
			listElement.arrowImage:setHeight( listElement.arrow_height )
			listElement.arrowImage:setRP( 1, 0.5 )
			listElement.arrowImage:setX( val.bg_width - 10 )
			listElement.arrowImage:setY( current_height + listElement.bg_height/2 )
			listElement.arrowImage:refresh()
			listElement.group:insert( listElements[i].arrowImage )

			--: element image :--
			if listElement.image ~= false then
				listElement.thumbnail = this.blood:getInjection( this, "uiImage" )     --: get a new uiImage to be used as bg :--
				listElement.thumbnail:setImage( listElement.image )
				listElement.thumbnail:setWidth( listElement.image_width )
				listElement.thumbnail:setHeight( listElement.image_height )
				listElement.thumbnail:setRP( 0, 0.5 )
				listElement.thumbnail:setX( 10 )
				listElement.thumbnail:setY( current_height + listElement.bg_height/2 )
				listElement.thumbnail:refresh()
				listElement.group:insert( listElements[i].thumbnail )
			end

			--: text :--
			listElement.label = this.blood:getInjection( this, "uiText" )     --: get a new uiText :--
			listElement.label:setText( listElement.text )
			--listElement.label:setFont( listElement.text_font )	--: i forgot to include this in the uiText :--
			listElement.label:setSize( listElement.text_size )
			listElement.label:setColor( listElement.text_red, listElement.text_green, listElement.text_blue, listElement.text_alpha )
			listElement.label:setAlpha( listElement.text_alpha )
			listElement.label:setAlign( listElement.text_align )
			listElement.label:setRP( 0, 0.5 )
			local labelX = val.text_left_gap
			if listElement.image ~= false then labelX = labelX + listElement.image_width end
			listElement.label:setX( labelX )
			listElement.label:setY( current_height + listElement.bg_height/2 )
			listElement.label:setWidth( listElement.bg_width - labelX - val.text_right_gap )
			listElement.label:setHeight( 0 )
			listElement.label:refresh()
			listElement.group:insert( listElements[i].label )

			this:insert( listElements[i].group )

			current_height = current_height + listElement.bg_height + val.gap_height
		end
	end

	function this:refresh()

		this:removeTexture()

		generateElements( val.number_of_elements )

		renderElements( val.number_of_elements )

		this.anchorX = val.anchorX
		this.anchorY = val.anchorY
		this.x = val.x
		this.y = val.y
	end

	function this:removeTexture()

		for i = 1, #listElements do
			
			display.remove( listElements[i].bgColor )
			listElements[i].bgColor = nil
			
			display.remove( listElements[i].bgButton )
			listElements[i].bgButton = nil
			
			display.remove( listElements[i].thumbnail )
			listElements[i].thumbnail = nil
			
			display.remove( listElements[i].label )
			listElements[i].label = nil
			
			display.remove( listElements[i].group )
			listElements[i].group = nil
		end
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

	function this:setX( newX )
		val.x = newX
	end

	function this:getX()
		return val.x
	end

	function this:setY( newY )
		val.y = newY
	end

	function this:getY()
		return val.y
	end

	local function changeProperty( property, value, row )

		if row ~= nil then
			listElements[row][property] = value
			return nil
		else
			for i = 1, #listElements do
				listElements[i][property] = value
			end
			return value
		end
	end

	function this:setText( newText, row )

		val.text = changeProperty( "text", newText, row ) or val.text
	end

	function this:getText( row )
		if row ~= nil then
			return listElements[row].text
		else
			return val.text
		end
	end

	function this:setTextAlign( newTextAlign, row )

		val.text_align = changeProperty( "text_align", newTextAlign, row ) or val.text_align
	end

	function this:getTextAlign( row )
		if row ~= nil then
			return listElements[row].text_align
		else
			return val.text_align
		end
	end

	function this:setBgDefaultImage( newBgDefaultImage, row )

		val.bg_default_image = changeProperty( "bg_default_image", newBgDefaultImage, row ) or val.bg_default_image
	end

	function this:getBgDefaultImage( row )
		if row ~= nil then
			return listElements[row].bg_default_image
		else
			return val.bg_default_image
		end
	end

	function this:setBgOverImage( newBgOverImage, row )

		val.bg_over_image = changeProperty( "bg_over_image", newBgOverImage, row ) or val.bg_over_image
	end

	function this:getBgOverImage( row )
		if row ~= nil then
			return listElements[row].bg_over_image
		else
			return val.bg_over_image
		end
	end

	function this:setImage( newImage, row )

		_image = changeProperty( "image", newImage, row ) or val.image
	end

	function this:getImage( row )
		if row ~= nil then
			return listElements[row].image
		else
			return val.image
		end
	end

	function this:setBgColor( newR, newG, newB, newAlpha, row )

		val.bg_fill_red = changeProperty( "bg_fill_red", newR, row ) or val.bg_fill_red
		val.bg_fill_green = changeProperty( "bg_fill_green", newG, row ) or val.bg_fill_green
		val.bg_fill_blue = changeProperty( "bg_fill_blue", newB, row ) or val.bg_fill_blue
		val.bg_fill_alpha = changeProperty( "bg_fill_alpha", newAlpha, row ) or val.bg_fill_alpha
	end

	function this:getBgColor( row )
		if row ~= nil then
			return listElements[row].bg_fill_red, listElements[row].bg_fill_green, listElements[row].bg_fill_blue, listElements[row].bg_fill_alpha
		else
			return val.bg_fill_red, val.bg_fill_green, val.bg_fill_blue, val.bg_fill_alpha
		end
	end

	function this:setBgStrokeColor( newR, newG, newB, newAlpha, row )

		val.bg_stroke_red = changeProperty( "bg_stroke_red", newR, row ) or val.bg_stroke_red
		val.bg_stroke_green = changeProperty( "bg_stroke_green", newG, row ) or val.bg_stroke_green
		val.bg_stroke_blue = changeProperty( "bg_stroke_blue", newB, row ) or val.bg_stroke_blue
		val.bg_stroke_alpha = changeProperty( "bg_stroke_alpha", newAlpha, row ) or val.bg_stroke_alpha
	end

	function this:getBgStrokeColor( row )
		if row ~= nil then
			return listElements[row].bg_stroke_red, listElements[row].bg_stroke_green, listElements[row].bg_stroke_blue, listElements[row].bg_stroke_alpha
		else
			return val.bg_stroke_red, val.bg_stroke_green, val.bg_stroke_blue, val.bg_stroke_alpha
		end
	end

	function this:setBgStrokeWidth( newgetBgStrokeWidth, row )

		val.bg_stroke_width = changeProperty( "bg_stroke_width", newgetBgStrokeWidth, row ) or val.bg_stroke_width
	end

	function this:getBgStrokeWidth( row )
		if row ~= nil then
			return listElements[row].bg_stroke_width
		else
			return val.bg_stroke_width
		end
	end

	function this:setTextColor( newR, newG, newB, newAlpha, row )

		val.text_red = changeProperty( "text_red", newR, row ) or val.text_red
		val.text_green = changeProperty( "text_green", newG, row ) or val.text_green
		val.text_blue = changeProperty( "text_blue", newB, row ) or val.text_blue
		val.text_alpha = changeProperty( "text_alpha", newAlpha, row ) or val.text_alpha
	end

	function this:getTextColor( row )
		if row ~= nil then
			return listElements[row].text_red, listElements[row].text_green, listElements[row].text_blue, listElements[row].text_alpha
		else
			return val.text_red, val.text_green, val.text_blue, val.text_alpha
		end
	end

	function this:addEventHandler( type, func, row )

		if type == "touch" then
			if row ~= nil then
				listElements[row].link = func
			else
				for i = 1, #listElements do
					listElements[i].link = func
				end
			end
		else
			log:error( "uiList: trying to add an event handler for `" .. type .. "`. Not supported yet.")
		end
	end

	function this:setNumberRows( num_rows )
		val.number_of_elements = num_rows
		generateElements( val.number_of_elements )
	end

	function this:getRealHeight()
		return current_height
	end

	-- init
	function this:init()

		generateElements( val.number_of_elements )
	end

	-- methods



	this:init()

	return this

end

return uiList 
 