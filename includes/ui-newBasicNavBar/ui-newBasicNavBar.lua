local worona = require "worona"

local function newBasicNavBar( self, params )

	local widget = require "widget"

	-- Create the display group
	local navbar = {}

	navbar.display_group = display.newGroup()


	--[[.	
		replaceButton 
		
		Replaces the icon from "side" button for "new_icon"	
		 	
		@type: navbar service
		@date: 03/15
		@since: 0.6.8
	
		@param: side (str): "left" or "right".
				new_icon: icon table, as in style-default.
		@return: -
	
		@example: basic_navbar:replaceButton ( "right", worona.style:get("icons").is_favorite )
	]]--
	function navbar:replaceButton( side, new_icon )

		if new_icon ~= nil then
			local button_options = {
				y 			= navbar.attributes.navbar_center_point,
			    width       = new_icon.width,
			    height      = new_icon.height,
			    defaultFile = new_icon.default,
		        overFile    = new_icon.over,
			}


			if side == "left" then
				
				display.remove( navbar.left_button )

				navbar.left_button_width = new_icon.width
				button_options.x         = new_icon.width / 2 - 15
				button_options.onRelease = function() worona:do_action( "navbar_left_button_pushed" ); return true end
				navbar.left_button       = widget.newButton( button_options )
				navbar.display_group:insert( navbar.left_button )
			
			elseif side == "right" then

				display.remove( navbar.right_button )
				
				navbar.right_button_width = new_icon.width
				button_options.x          = display.contentWidth - ( params.right_button_icon.width / 2 ) + 15
				button_options.onRelease  = function() worona:do_action( "navbar_right_button_pushed" ); return true end
				navbar.right_button       = widget.newButton( button_options )
				navbar.display_group:insert( navbar.right_button )
			else
				worona.log:error('ui-newBasicNavBar/replaceButton: "' .. side .. '" should be "left" or "right". Please change.')
			end
		end
	end

	-- Get the style

	local style = worona.style:get("navbar")

	local ios7and8_y      = ( display.topStatusBarContentHeight + style.height ) / 2
	local ios7and8_height = style.height + display.topStatusBarContentHeight

	navbar.attributes = {
		navbar_x                 = display.contentWidth / 2,
		navbar_y                 = worona.style:getSetting( { ios7 = ios7and8_y, ios8 = ios7and8_y, default = display.topStatusBarContentHeight + style.height / 2 } ),
		navbar_center_point      = display.topStatusBarContentHeight + style.height / 2,
		navbar_height            = worona.style:getSetting( { ios7 = ios7and8_height, ios8 = ios7and8_height, default = style.height } ),
		navbar_width             = style.width or display.contentWidth,
		background_color         = style.background.color,
		background_stroke_color  = style.background.stroke.color,
		background_stroke_height = style.background.stroke.height,
		text                     = "Untitled" or params.text,
		text_size                = style.text.fontSize,
		text_color               = style.text.color
	}

	-- Start the creation

	local background = display.newRect( navbar.attributes.navbar_x, navbar.attributes.navbar_y, navbar.attributes.navbar_width, navbar.attributes.navbar_height )
	background:setFillColor( navbar.attributes.background_color[1], navbar.attributes.background_color[2], navbar.attributes.background_color[3], navbar.attributes.background_color[4] )
	navbar.display_group:insert(background)

	local stroke = display.newRect( navbar.attributes.navbar_x, navbar.attributes.navbar_center_point + ( style.height + navbar.attributes.background_stroke_height ) / 2, navbar.attributes.navbar_width, navbar.attributes.background_stroke_height )
	stroke:setFillColor( navbar.attributes.background_stroke_color[1], navbar.attributes.background_stroke_color[2], navbar.attributes.background_stroke_color[3], navbar.attributes.background_stroke_color[4] )
	navbar.display_group:insert(stroke)

	navbar.left_button_width = 0
	if params.left_button_icon ~= nil then
		local left_button_options = {
			x 			= params.left_button_icon.width / 2 - 15,
			y 			= navbar.attributes.navbar_center_point,
		    width       = params.left_button_icon.width,
		    height      = params.left_button_icon.height,
		    defaultFile = params.left_button_icon.default,
	        overFile    = params.left_button_icon.over,
	        onRelease   = function() worona:do_action( "navbar_left_button_pushed" ); return true end
		}
		navbar.left_button_width = params.left_button_icon.width
		navbar.left_button = widget.newButton( left_button_options )
		navbar.display_group:insert( navbar.left_button )
	end

	navbar.right_button_width = 0
	if params.right_button_icon ~= nil then
		local right_button_options = {
			x 			= display.contentWidth - ( params.right_button_icon.width / 2 ) + 15,
			y 			= navbar.attributes.navbar_center_point,
		    width       = params.right_button_icon.width,
			height      = params.right_button_icon.height,
		    defaultFile = params.right_button_icon.default,
	        overFile    = params.right_button_icon.over,
	        onRelease   = function() worona:do_action( "navbar_right_button_pushed" ); return true end
		}
		navbar.right_button_width = params.left_button_icon.width
		navbar.right_button = widget.newButton( right_button_options )
		navbar.display_group:insert( navbar.right_button )

	end

	local text_options = {
		parent   = navbar.display_group,
		text     = params.text or "nothing",
		x        = navbar.attributes.navbar_x,
		y        = navbar.attributes.navbar_center_point,
		fontSize = navbar.attributes.text_size
	}

	local text = display.newText( text_options )
	text:setFillColor( navbar.attributes.text_color[1], navbar.attributes.text_color[2], navbar.attributes.text_color[3], navbar.attributes.text_color[4] )

	--. If text is too wide, cut it and add "..."
	local navbar_available_space = display.contentWidth - navbar.right_button_width - navbar.left_button_width - 10
	if text.width > navbar_available_space then
		--. Calculate the width of a character:
		text.text = "o"
		local character_width = text.width

		--. Calculate how many character can be placed in the navbar:
		local characters_number = math.floor(navbar_available_space / character_width)

		--. Insert text with new length
		text.text = text_options.text:sub(1, characters_number - 3) .. "..."
	end

	-- Insert navbar on the parent group
	if params ~= nil and params.parent ~= nil then
		params.parent:insert( navbar.display_group )
	end

	-- Return the object
	return navbar
end
worona:do_action( "extend_service", { service = "ui", creator = newBasicNavBar, name = "newBasicNavBar" } )