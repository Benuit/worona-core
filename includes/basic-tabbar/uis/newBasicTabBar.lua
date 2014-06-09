local worona = require "worona"
local widget = require "widget"

local ui = {}

function ui:newBasicTabBar( params )

	local style = worona.style:get("tabbar")

	local values = {
		tabbar_width  = style.width or display.contentWidth,
		tabbar_height = style.height,
		images_width  = style.icons.width,
		images_height = style.icons.height,
		size          = style.text.fontSize,
		labelColor    = style.text.color,
		labelXOffset  = 0,
		labelYOffset  = 0
	}

	local function onPress( tab, page_type, page_id )
		return function()
			selected_tab = tab
			worona:do_action( "load_page", { page_id = page_id, page_type = page_type } )
		end
	end

	-- Configure the tab buttons to appear within the bar
	local tabButtons = {
	    {
	        width        = values.images_width, 
	        height       = values.images_height,
	        defaultFile  = style.icons[1].image.default,
	        overFile     = style.icons[1].image.over,
	        label        = style.icons[1].text,
	        labelColor   = values.labelColor,
	        font         = native.systemFontBold,
	        selected     = true,
	        size         = values.size,
	        labelXOffset = values.labelYOffset,
	        labelYOffset = values.labelXOffset,
	        onPress      = onPress( 1, params.pages[1].page_type, params.pages[1].page_id )
	    },
	    {
	        width        = values.images_width, 
	        height       = values.images_height,
	        defaultFile  = style.icons[2].image.default,
	        overFile     = style.icons[2].image.over,
	        label        = style.icons[2].text,
	        labelColor   = values.labelColor,
	        font         = native.systemFontBold,
	        size         = values.size,
	        labelXOffset = values.labelYOffset,
	        labelYOffset = values.labelXOffset,
	        onPress      = onPress( 2, params.pages[2].page_type, params.pages[2].page_id )
	    },
	    {
	        width        = values.images_width, 
	        height       = values.images_height,
	        defaultFile  = style.icons[3].image.default,
	        overFile     = style.icons[3].image.over,
	        label        = style.icons[3].text,
	        labelColor   = values.labelColor,
	        font         = native.systemFontBold,
	        size         = values.size,
	        labelXOffset = values.labelYOffset,
	        labelYOffset = values.labelXOffset,
	        onPress      = onPress( 3, params.pages[3].page_type, params.pages[3].page_id )
	    },
	    {
	        width        = values.images_width, 
	        height       = values.images_height,
	        defaultFile  = style.icons[4].image.default,
	        overFile     = style.icons[4].image.over,
	        label        = style.icons[4].text,
	        labelColor   = values.labelColor,
	        font         = native.systemFontBold,
	        size         = values.size,
	        labelXOffset = values.labelYOffset,
	        labelYOffset = values.labelXOffset,
	        onPress      = onPress( 4, params.pages[4].page_type, params.pages[4].page_id )
	    },
	    {
	        width        = values.images_width, 
	        height       = values.images_height,
	        defaultFile  = style.icons[5].image.default,
	        overFile     = style.icons[5].image.over,
	        label        = style.icons[5].text,
	        labelColor   = values.labelColor,
	        font         = native.systemFontBold,
	        size         = values.size,
	        labelXOffset = values.labelYOffset,
	        labelYOffset = values.labelXOffset,
	        onPress      = onPress( 5, params.pages[5].page_type, params.pages[5].page_id )
	    }
	}

	-- Create the widget
	local widget = require "widget"
	local tabbar = widget.newTabBar
	{
	    left                   = 0,
	    top                    = display.contentHeight - values.tabbar_height,
	    width                  = values.tabbar_width,
	    height                 = values.tabbar_height,
	    backgroundFile         = style.background.image,
	    tabSelectedLeftFile    = style.background.tab_selected_left,
	    tabSelectedRightFile   = style.background.tab_selected_middle,
	    tabSelectedMiddleFile  = style.background.tab_selected_right,
	    tabSelectedFrameWidth  = values.tabbar_width / values.tabbar_height / 2,
	    tabSelectedFrameHeight = values.tabbar_height,
	    buttons                = tabButtons
	}

	if params.group ~= nil then	
		params.group:insert( tabbar )
	end

	return tabbar
end

return ui