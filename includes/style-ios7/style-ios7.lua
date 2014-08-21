local worona = require "worona"

local function newStyle()
	--== VARIABLES ==--

	-- style
	local style = {}

	-- paths
	local images_folder = "worona/includes/style-ios7/images"

	-- colors
	local light_grey = { 0.968, 0.968, 0.968, 1 }
	local dark_grey  = { 0, 0, 0, 0.2 }

	-- common styles
	local stroke_width      = 1
	local light_text_color  = { 1, 1, 1, 1 }
	local dark_text_color   = { 0, 0, 0, 0.8 }


	--== STYLES ==--

	---- NAVBAR ----
	-- variables
	local navbar_margin_top     = worona.style:getSetting( { ios7 = 0, default = display.topStatusBarContentHeight } )
	local navbar_top_status_bar = worona.style:getSetting( { ios7 = display.topStatusBarContentHeight, default = 0 } )
	local navbar_height         = 50

	-- style
	style.navbar = {
		width      = display.contentWidth,
		height     = navbar_height + navbar_top_status_bar,
		margin_top = navbar_margin_top
	}
		
	style.navbar.background = {
		color  = light_grey
	}

	style.navbar.background.stroke = {
		color = dark_grey,
		width = stroke_width
	}

	style.navbar.back_button = {
		image          = { default = images_folder .. "/navbar/navBarButtonDefault.png", over = images_folder .. "/navbar/navBarButtonOver.png" },
		height         = navbar_height,
		width          = navbar_height,
		margin_left    = 5,
		vertical_align = "center"
	}

	style.navbar.text = {
		size           = 18,
		color          = light_text_color,
		vertical_align = "center"
	}

	---- TABBAR ----
	--style
	style.tabbar = {
		height = 50
	}

	style.tabbar.background = {
		image               = images_folder .. "/basic-tabbar/tabBarBg.png",
		tab_selected_left   = images_folder .. "/basic-tabbar/tabBar_tabSelectedLeft.png",
		tab_selected_middle = images_folder .. "/basic-tabbar/tabBar_tabSelectedMiddle.png",
		tab_selected_right  = images_folder .. "/basic-tabbar/tabBar_tabSelectedRight.png",
	}

	style.tabbar.text = {
		fontSize = 10,
		color = { default = { 0.57, 0.57, 0.57, 1 }, over = { 0.56, 0.074, 0.992, 1 } }
	}

	style.tabbar.icons = {
		width = 29,
		height = 50,
	}

	style.tabbar.icons[1] = {
		text = "Guía",
		image = { default = images_folder .. "/basic-tabbar/tabBarDefault_1.png", over = images_folder .. "/basic-tabbar/tabBarDefault_1.png" }
	}

	style.tabbar.icons[2] = {
		text = "Hoteles",
		image = { default = images_folder .. "/basic-tabbar/tabBarDefault_2.png", over = images_folder .. "/basic-tabbar/tabBarDefault_2.png" }
	}

	style.tabbar.icons[3] = {
		text = "Actividades",
		image = { default = images_folder .. "/basic-tabbar/tabBarDefault_3.png", over = images_folder .. "/basic-tabbar/tabBarDefault_3.png" }
	}

	style.tabbar.icons[4] = {
		text = "Traslados",
		image = { default = images_folder .. "/basic-tabbar/tabBarDefault_4.png", over = images_folder .. "/basic-tabbar/tabBarDefault_4.png" }
	}

	style.tabbar.icons[5] = {
		text = "Compras",
		image = { default = images_folder .. "/basic-tabbar/tabBarDefault_5.png", over = images_folder .. "/basic-tabbar/tabBarDefault_5.png" }
	}

	---- WEBVIEW ---
	--style
	style.webview = {}

	style.webview.height = display.contentHeight - style.tabbar.height - display.topStatusBarContentHeight - style.navbar.height
	style.webview.y      = style.navbar.height + style.webview.height / 2 + display.topStatusBarContentHeight


	---- LIST ----
	--style
	style.list = {
		title = {
			font_type = native.systemFontBold,
			font_size = 14
		}
	}

	

	return style
end
worona:do_action( "register_style", { style = "ios7", creator = newStyle } )