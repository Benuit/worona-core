local worona = require "worona"

local function newTwoLineNavBar( self, params )

	local widget = require "widget"

	-- Create the display group
	local navbar = display.newGroup()

	-- Get the style

	local style = worona.style:get("two_line_navbar")

	local ios7and8_y      = ( display.topStatusBarContentHeight + style.height ) / 2
	local ios7and8_height = style.height + display.topStatusBarContentHeight

	local line1_attributes = {
		navbar_x                 = display.contentWidth / 2,
		navbar_y                 = worona.style:getSetting( { ios7 = ios7and8_y, ios8 = ios7and8_y, default = display.topStatusBarContentHeight + style.height / 2 } ),
		navbar_center_point      = display.topStatusBarContentHeight + style.height / 2,
		navbar_height            = worona.style:getSetting( { ios7 = ios7and8_height, ios8 = ios7and8_height, default = style.height } ),
		navbar_width             = style.width or display.contentWidth,
		line1_background_color         = style.background.color,
		line1_background_stroke_color  = style.background.stroke.color,
		line1_background_stroke_height = style.background.stroke.height,
		text                     = "Untitled" or params.text,
		text_size                = style.text.fontSize,
		text_color               = style.text.color
	}

	-- Start the creation

	local line1_background = display.newRect( line1_attributes.navbar_x, line1_attributes.navbar_y, line1_attributes.navbar_width, line1_attributes.navbar_height )
	line1_background:setFillColor( line1_attributes.line1_background_color[1], line1_attributes.line1_background_color[2], line1_attributes.line1_background_color[3], line1_attributes.line1_background_color[4] )
	navbar:insert(line1_background)

	local stroke = display.newRect( line1_attributes.navbar_x, line1_attributes.navbar_center_point + ( style.height + line1_attributes.line1_background_stroke_height ) / 2, line1_attributes.navbar_width, line1_attributes.line1_background_stroke_height )
	stroke:setFillColor( line1_attributes.line1_background_stroke_color[1], line1_attributes.line1_background_stroke_color[2], line1_attributes.line1_background_stroke_color[3], line1_attributes.line1_background_stroke_color[4] )
	navbar:insert(stroke)

	local left_button_width = 0
	if params.left_button_icon ~= nil then
		local left_button_options = {
			x 			= params.left_button_icon.width / 2 - 15,
			y 			= line1_attributes.navbar_center_point,
		    width       = params.left_button_icon.width,
		    height      = params.left_button_icon.height,
		    defaultFile = params.left_button_icon.default,
	        overFile    = params.left_button_icon.over,
	        onRelease   = function() worona:do_action( "navbar_left_button_pushed" ); return true end
		}
		left_button_width = params.left_button_icon.width
		local left_button = widget.newButton( left_button_options )
		navbar:insert( left_button )
	end

	local right_button_width = 0
	if params.right_button_icon ~= nil then
		local right_button_options = {
			x 			= display.contentWidth - ( params.right_button_icon.width / 2 ) + 15,
			y 			= line1_attributes.navbar_center_point,
		    width       = params.right_button_icon.width,
			height      = params.right_button_icon.height,
		    defaultFile = params.right_button_icon.default,
	        overFile    = params.right_button_icon.over,
	        onRelease   = function() worona:do_action( "navbar_right_button_pushed" ); return true end
		}
		right_button_width = params.left_button_icon.width
		local right_button = widget.newButton( right_button_options )
		navbar:insert( right_button )

	end

	local text_options = {
		parent   = navbar,
		text     = params.text or "nothing",
		x        = line1_attributes.navbar_x,
		y        = line1_attributes.navbar_center_point,
		fontSize = line1_attributes.text_size
	}

	local text = display.newText( text_options )
	text:setFillColor( line1_attributes.text_color[1], line1_attributes.text_color[2], line1_attributes.text_color[3], line1_attributes.text_color[4] )

	--. If text is too wide, cut it and add "..."
	local nabvar_available_space = display.contentWidth - right_button_width - left_button_width - 10
	if text.width > nabvar_available_space then
		--. Calculate the width of a character:
		text.text = "o"
		local character_width = text.width
		
		--. Calculate how many character can be placed in the nabvar:
		local characters_number = math.floor(nabvar_available_space / character_width)

		--. Insert text with new length
		text.text = text_options.text:sub(1, characters_number - 3) .. "..."
	end

	-- Insert navbar on the parent group
	if params ~= nil and params.parent ~= nil then
		params.parent:insert( navbar )
	end

	-- Return the object
	return navbar
end
worona:do_action( "extend_service", { service = "ui", creator = newTwoLineNavBar, name = "newTwoLineNavBar" } )