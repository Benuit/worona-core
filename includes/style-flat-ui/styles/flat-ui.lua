local worona = require "worona"

local style = {}


--== VARIABLES ==--

-- paths
local images_folder = "worona/includes/style-flat-ui/images"

-- colors
local light_blue = { 0.203125, 0.59375, 0.85546875, 1 }
local dark_blue  = { 0.16, 0.5, 0.72, 1 }

-- common styles
local stroke_width     = 4
local light_text_color = { 1, 1, 1, 1 }
local dark_text_color  = { 0.2, 0.2, 0.2, 1 }


--== STYLES ==--

---- NAVBAR ----
-- style
style.navbar = {
	height = 50
}
	
style.navbar.background = {
	color = light_blue
}

style.navbar.background.stroke = {
	color = dark_blue,
	width = stroke_width
}

style.navbar.back_button = {
	image          = { default = images_folder .. "/basic-navbar/navBarButtonDefault.png", over = images_folder .. "/basic-navbar/navBarButtonOver.png" },
	height         = style.navbar.height,
	width          = style.navbar.height,
	margin_left    = 5,
	vertical_align = "center"
}

style.navbar.text = {
	fontSize       = 18,
	color          = light_text_color,
	vertical_align = "center"
}


---- TABBAR ----
--style
style.tabbar = {
	height = 68
}

style.tabbar.background = {
	image               = images_folder .. "/basic-tabbar/tabBarBg.png",
	tab_selected_left   = images_folder .. "/basic-tabbar/tabBar_tabSelectedLeft.png",
	tab_selected_middle = images_folder .. "/basic-tabbar/tabBar_tabSelectedMiddle.png",
	tab_selected_right  = images_folder .. "/basic-tabbar/tabBar_tabSelectedRight.png",
}

style.tabbar.text = {
	fontSize = 10,
	color = { default = { 1, 1, 1, 1 }, over = { 1, 1, 1, 1 } }
}

style.tabbar.icons = {
	width = 40,
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
	text = "Mapa",
	image = { default = images_folder .. "/basic-tabbar/tabBarDefault_5.png", over = images_folder .. "/basic-tabbar/tabBarDefault_5.png" }
}


---- WELCOMESCREEN ----
--style
style.welcomescreen = {}

style.welcomescreen.background = {
	image = images_folder .. "/welcomescreen/welcomeScreenBg.jpg"
}

style.welcomescreen.title = {
	fontSize = 48,
	font     = native.systemFont
}

style.welcomescreen.big_button = {
	image    = { default = images_folder .. "/welcomescreen/welcomeScreenBigButtonDefault.png", over = images_folder .. "/welcomescreen/welcomeScreenBigButtonOver.png" },
	width    = 281,
	height   = 90,
	fontSize = 30,
	font     = native.systemFont,
	color    = { default = { 1, 1, 1, 1 }, over = { 1, 1, 1, 1 } }
}

style.welcomescreen.small_button = {
	image    = { default = images_folder .. "/welcomescreen/welcomeScreenSmallButtonDefault.png", over = images_folder .. "/welcomescreen/welcomeScreenSmallButtonOver.png" },
	width    = 123,
	height   = 70,
	fontSize = 16,
	font     = native.systemFont,
	color    = { default = { 1, 1, 1, 1 }, over = { 1, 1, 1, 1 } }
}


---- WEBVIEW ---
--style
style.webview = {}

style.webview.height = display.contentHeight - style.tabbar.height - display.topStatusBarContentHeight - style.navbar.height
style.webview.y      = style.navbar.height + style.webview.height / 2 + display.topStatusBarContentHeight


---- CUSTOMCONTENT ----
--style
style.customcontent = {}

style.customcontent.height = display.contentHeight - style.tabbar.height - display.topStatusBarContentHeight - style.navbar.height
style.customcontent.y      = style.navbar.height + style.customcontent.height / 2 + display.topStatusBarContentHeight

style.customcontent.background = {
	image = images_folder .. "/customcontent/customcontentBG.png"
}

style.customcontent.list = {
	height                 = 50,
	width                  = display.contentWidth - 20,
	space_between_elements = 10,
	color                  = { default = { 0.2, 0.2, 0.2, 1 }, over = { 0, 0, 0, 1 } }
}

style.customcontent.list.sheet = {
	image   = images_folder .. "/customcontent/listSheet.png",
	options = {
        frames =
        {
           { x=0, y=0, width=1, height=1 },
           { x=0, y=1, width=1, height=1 },
           { x=0, y=2, width=1, height=1 },
           { x=1, y=0, width=1, height=1 },
           { x=1, y=1, width=1, height=1 },
           { x=1, y=2, width=1, height=1 }
        },
        sheetContentWidth  = 2,
        sheetContentHeight = 3
	}
}

style.customcontent.list.arrow = {
	image  = images_folder .. "/customcontent/listArrow.png",
	width  = 14,
	height = 22
}

style.customcontent.button = {
	sheet_options = {
             frames =
             {
                { x=0, y=0, width=1, height=1 },
                { x=0, y=1, width=1, height=1 },
                { x=0, y=2, width=1, height=1 },
                { x=1, y=0, width=1, height=1 },
                { x=1, y=1, width=1, height=1 },
                { x=1, y=2, width=1, height=1 }
             },
             sheetContentWidth  = 2,
             sheetContentHeight = 3
        },
    image = images_folder .. "/customcontent/buttonSheet.png",
    color = { default = { 1, 1, 1, 1 }, over = { 0, 0, 0, 1 } }
}

return style