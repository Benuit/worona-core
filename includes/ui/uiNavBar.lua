-- UI: uiNavBar   
local uiNavBar = {}

function uiNavBar : new( bloodGroup )

	--. variables needed to perform operations in default values .--
	local deviceUtils = require "worona.lib.utils.deviceUtils"
	local statusBarHeight = deviceUtils:getSetting( { ios7 = 0, default = display.topStatusBarContentHeight } )

	--: DEFAULT VALUES :--
	local val = {
		x                         = 0,
		y                         = deviceUtils:getSetting( { ios7 = 0, default = display.topStatusBarContentHeight } ),
		bg_height                 = 68,
		bg_width                  = display.contentWidth,
		bg_red                    = 0.203125,
		bg_green                  = 0.59375,
		bg_blue                   = 0.85546875,
		bg_alpha                  = 1,
		bg_stroke_red             = 1,
		bg_stroke_green           = 1,
		bg_stroke_blue            = 1,
		bg_stroke_alpha           = 1,
		bg_stroke_width           = 0,
		bg_image_left             = "navBarBgLeft.png",
		bg_image_left_width       = 68.25,
		bg_image_middle           = "navBarBgMiddle.png",
		bg_image_middle_width     = 1,
		bg_image_right            = "navBarBgRight.png",
		bg_image_right_width      = 68.25,
		text                      = "Dónde dormir",
		text_size                 = 18,
		link                      = function() log:info("Back button of the navbar pushed") end,
		back_button_default_image = "navBarBackButtonDefault.png",
		back_button_over_image    = "navBarBackButtonOver.png",
		back_button_height        = 25.5,
		back_button_width         = 16.5,
		back_button_x             = 0
	}
	val.back_button_y             = ( deviceUtils:getSetting( { default = 0, ios7 = display.topStatusBarContentHeight } ) + val.bg_height ) / 2
	val.text_x                    = val.back_button_width
	val.text_y                    = ( deviceUtils:getSetting( { default = 0, ios7 = display.topStatusBarContentHeight } ) + val.bg_height ) / 2
	--: END OF DEFAULT VALUES :--

	-- creates the display object
	local this = uUI:new( "uiNavBar", bloodGroup )

	--: ui variables :--
	local group, background, bg_image_middle, statusBarRectangle

	local text           = this.blood:getInjection( this, "uiText" )
	local bg_image_left  = this.blood:getInjection( this, "uiImage" )
	local bg_image_right = this.blood:getInjection( this, "uiImage" )
	local back_button    = this.blood:getInjection( this, "uiButton" )

	
	-- init
	function this:init()

		--this:refresh()
	end

	-- methods
	function this:refresh()

		this:removeTexture()

		--: group :--
		group = display.newGroup()

		--: background color :--
		background = display.newRect( 0, 0, val.bg_width, val.bg_height )
		background:setFillColor( val.bg_red, val.bg_green, val.bg_blue, val.bg_alpha )
		background:setStrokeColor( val.bg_stroke_red, val.bg_stroke_green, val.bg_stroke_blue, val.bg_stroke_alpha )
		background.strokeWidth = val.bg_stroke_width
		group:insert( background )

		-- --: iOS7 status bar background :--
		-- statusBarRectangle = display.newRect( 0, 0, display.contentWidth, display.topStatusBarContentHeight )
		-- statusBarRectangle:setFillColor( val.bg_red, val.bg_green, val.bg_blue, val.bg_alpha )

		--: background images :--
		if val.bg_image_left ~= false then
			bg_image_left:setRP( 0, 0 )
			bg_image_left:setX( 0 )
			bg_image_left:setY( 0 )
			bg_image_left:setWidth( val.bg_image_left_width )
			bg_image_left:setHeight( val.bg_height )
			bg_image_left:setImage( val.bg_image_left )
			bg_image_left:refresh()
			group:insert( bg_image_left )
		end
		if val.bg_image_middle ~= false then
			
			bg_image_middle = {}
			local pixels = ( display.contentWidth - val.bg_image_left_width - val.bg_image_right_width ) / val.bg_image_middle_width

			for i = 1, pixels+1 do
				local bg_image_middle_item = bg_image_middle[i]
				bg_image_middle_item = this.blood:getInjection( this, "uiImage" )
				bg_image_middle_item:setRP( 0, 0 )
				bg_image_middle_item:setX( val.bg_image_left_width + i - 1 )
				bg_image_middle_item:setY( 0 )
				bg_image_middle_item:setWidth( val.bg_image_middle_width )
				bg_image_middle_item:setHeight( val.bg_height )
				bg_image_middle_item:setImage( val.bg_image_middle )
				bg_image_middle_item:refresh()
				group:insert( bg_image_middle_item )
			end
		end
		if val.bg_image_right ~= false then
			bg_image_right:setRP( 1, 0 )
			bg_image_right:setX( display.contentWidth )
			bg_image_right:setY( 0 )
			bg_image_right:setWidth( val.bg_image_right_width )
			bg_image_right:setHeight( val.bg_height )
			bg_image_right:setImage( val.bg_image_right )
			bg_image_right:refresh()
			group:insert( bg_image_right )
		end

		--: button :--
		if val.back_button_default_image ~= false then
			back_button:setLabel("")
			back_button:setDefaultImage( val.back_button_default_image )
			back_button:setOverImage( val.back_button_over_image or val.back_button_default_image )
			back_button:setHeight( val.back_button_height )
			back_button:setWidth( val.back_button_width )
			back_button:setRP( 0, 0.5 )
			back_button:setX( val.back_button_x )
			back_button:setY( val.back_button_y )
			back_button:addEventHandler( "touch", val.link )
			back_button:refresh()
			group:insert( back_button )
		end


		--: text :--
		text:setRP( 0, 0.5 )
		text:setWidth( val.bg_width - val.back_button_width )
		text:setAlign( "center" )
		text:setY( val.text_y )
		text:setX( val.text_x )
		text:setText( val.text )
		text:setSize( val.text_size )
		text:refresh()
		group:insert( text )

		--: group :--
		group.x = val.x
		group.y = val.y
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

	

	function this:setHeight( newHeight )
		val.bg_height = newHeight
	end

	function this:getHeight()
		return val.bg_height
	end

	function this:setText( newText )
		val.text = newText
	end

	function this:getText()
		return val.text
	end

	function this:setTextX( newTextX )
		val.text_x = newTextX
	end

	function this:getTextX()
		return val.text_x
	end

	function this:setTextY( newTextY )
		val.text_y = newTextY
	end

	function this:getTextY()
		return val.text_y
	end

	function this:setTextSize( newTextSize )
		val.text_size = newTextSize
	end

	function this:getTextSize()
		return val.text_size
	end

	function this:setBgImageLeft( newBgImageLeft )
		val.bg_image_left = newBgImageLeft
	end

	function this:getBgImageLeft()
		return val.bg_image_left
	end

	function this:setBgImageRight( newBgImageRight )
		val.bg_image_right = newBgImageRight
	end

	function this:getBgImageRight()
		return val.bg_image_right
	end

	function this:setBgImageMiddle( newBgImageMiddle )
		val.bg_image_middle = newBgImageMiddle
	end

	function this:getBgImageMiddle()
		return val.bg_image_middle
	end

	function this:setBgImageLeftWidth( newBgImageLeftWidth )
		val.bg_image_left_width = newBgImageLeftWidth
	end

	function this:getBgImageLeftWidth()
		return val.bg_image_left_width
	end

	function this:setBgImageRightWidth( newBgImageRightWidth )
		val.bg_image_right_width = newBgImageRightWidth
	end

	function this:getBgImageRightWidth()
		return val.bg_image_right_width
	end

	function this:setBgImageMiddleWidth( newBgImageMiddleWidth )
		val.bg_image_middle_width = newBgImageMiddleWidth
	end

	function this:getBgImageMiddleWidth()
		return val.bg_image_middle_width
	end

	function this:setBgColor( r, g, b, a )
		val.bg_red, val.bg_green, val.bg_blue, val.bg_alpha = r, g, b, a
	end

	function this:getBgColor()
		return val.bg_red, val.bg_green, val.bg_blue, val.bg_alpha
	end

	function this:setBgStrokeColor( r, g, b, a )
		val.bg_stroke_red, val.bg_stroke_green, val.bg_stroke_blue, val.bg_stroke_alpha = r, g, b, a
	end

	function this:getBgStrokeColor()
		return val.bg_stroke_red, val.bg_stroke_green, val.bg_stroke_blue, val.bg_stroke_alpha
	end

	function this:setBgStrokeWidth( newBgStrokeWidth )
		val.bg_stroke_width = newBgStrokeWidth
	end

	function this:getBgStrokeWidth()
		return val.bg_stroke_width
	end

	function this:setBackButtonDefaultImage( newBackButtonDefaultImage )
		val.back_button_default_image = newBackButtonDefaultImage
	end

	function this:getBackButtonDefaultImage()
		return val.back_button_default_image
	end

	function this:setBackButtonOverImage( newBackButtonOverImage )
		val.back_button_over_image = newBackButtonOverImage
	end

	function this:getBackButtonOverImage()
		return val.back_button_over_image
	end

	function this:setBackButtonHeight( newBackButtonHeight )
		val.back_button_height = newBackButtonHeight
	end

	function this:getBackButtonHeight()
		return val.back_button_height
	end

	function this:setBackButtonWidth( newBackButtonWidth )
		val.back_button_width = newBackButtonWidth
	end

	function this:getBackButtonWidth()
		return val.back_button_width
	end

	function this:setBackButtonX( newBackButtonX )
		val.back_button_x = newBackButtonX
	end

	function this:getBackButtonX()
		return val.back_button_x
	end

	function this:setBackButtonY( newBackButtonY )
		val.back_button_y = newBackButtonY
	end

	function this:getBackButtonY()
		return val.back_button_y
	end

	function this:addEventHandler( type, func )
		if type == "touch" then
			val.link = func
		else
			log:warning( "uiNavBar: Only touch handlers are allowed. Do not use `" .. type .. "`" )
		end
	end

	function this:getRealHeight()
		return val.bg_height
	end

	function this:removeTexture()
		display.remove( group )
	end


	this:init()

	return this

end

return uiNavBar 
 