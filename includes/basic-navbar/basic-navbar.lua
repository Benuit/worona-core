local worona = require "worona"

local function newBasicNavBar( params )

	local widget = require "widget"

	-- Create the display group
	local navbar = display.newGroup()

	-- Get the style

	local style = worona.style:get("navbar")

	local attributes = {
		navbar_x                = display.contentWidth / 2,
		navbar_y                = worona.style:getSetting( { ios7 = ( display.topStatusBarContentHeight + style.height ) / 2, default = display.topStatusBarContentHeight + style.height / 2 } ),
		navbar_center_point     = display.topStatusBarContentHeight + style.height / 2,
		navbar_height           = worona.style:getSetting( { ios7 = style.height + display.topStatusBarContentHeight, default = style.height } ),
		navbar_width            = style.width or display.contentWidth,
		background_color        = style.background.color,
		background_stroke_color = style.background.stroke.color,
		background_stroke_width = style.background.stroke.width,
		back_button_default_img = style.back_button.image.default,
		back_button_over_img    = style.back_button.image.over,
		back_button_height      = style.back_button.height,
		back_button_width       = style.back_button.width,
		text                    = "Untitled" or params.text,
		text_size               = style.text.fontSize,
		text_color              = style.text.color
	}

	-- Start the creation

	local background = display.newRect( attributes.navbar_x, attributes.navbar_y, attributes.navbar_width, attributes.navbar_height )
	background:setFillColor( attributes.background_color[1], attributes.background_color[2], attributes.background_color[3], attributes.background_color[4] )
	navbar:insert(background)

	local stroke = display.newRect( navbar, attributes.navbar_x, attributes.navbar_height + attributes.background_stroke_width / 2 - attributes.background_stroke_width, attributes.navbar_width, attributes.background_stroke_width )
	stroke:setFillColor( attributes.background_stroke_color[1], attributes.background_stroke_color[2], attributes.background_stroke_color[3], attributes.background_stroke_color[4] )

	local back_button_options = {
		x 			= attributes.back_button_width / 2,
		y 			= attributes.navbar_center_point,
	    width       = attributes.back_button_width,
	    height      = attributes.back_button_height,
	    defaultFile = attributes.back_button_default_img,
        overFile    = attributes.back_button_over_img,
        onRelease   = params.handler
	}
	local back_button = widget.newButton( back_button_options )
	navbar:insert( back_button )

	local text_options = {
		parent   = navbar,
		text     = params.text or "nothing",
		x        = attributes.navbar_x,
		y        = attributes.navbar_center_point,
		fontSize = attributes.text_size
	}

	local text = display.newText( text_options )
	text:setFillColor( attributes.text_color[1], attributes.text_color[2], attributes.text_color[3], attributes.text_color[4] )

	-- Insert navbar on the parent group
	if params ~= nil and params.sceneGroup ~= nil then
		params.sceneGroup:insert( navbar )
	end

	-- Return the object
	return navbar
end
worona:do_action( "extend_service", { service = "ui", creator = newBasicNavBar, name = "newBasicNavBar" } )


local function attachNavBar( params )

	local basic_navbar = worona.ui:newBasicNavBar({
		sceneGroup = params.sceneGroup,
		text       = params.pagetitle,
		handler    = function() worona:do_action( "load_previous_scene", { options = { effect = "slideRight", time = 200, params = params } } ) end
	})

	return basic_navbar
end
worona:add_action( "before_creating_scene", attachNavBar )