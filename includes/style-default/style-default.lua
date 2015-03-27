local worona = require "worona"
local user_config_style = require "worona-config.style"

local function newStyle()
	--== VARIABLES ==--

	-- style
	local style = {}

	-- show status bar on Android
	if worona.device:getPlatformName() == "Android" then
		display.setStatusBar( display.DefaultStatusBar )
	end

	-- paths
	local images_folder = "worona-core/includes/style-default/images"
	local icons_folder  = "worona-core/includes/style-default/icons"


	--== STYLES ==--

	---- ICONS ----
	style.icons = {
		back_left   = { default = icons_folder .. "/backLeftDefault.png", 	over = icons_folder .. "/backLeftOver.png", 	width = 68, height = 68  },
		back_right  = { default = icons_folder .. "/backRightDefault.png", 	over = icons_folder .. "/backRightOver.png", 	width = 68, height = 68  },
		refresh     = { default = icons_folder .. "/refreshDefault.png", 	over = icons_folder .. "/refreshOver.png", 		width = 68, height = 68  },
		more        = { default = icons_folder .. "/moreDefault.png", 		over = icons_folder .. "/moreOver.png", 		width = 68, height = 68  },
		favorite    = { default = icons_folder .. "/favoriteDefault.png", 	over = icons_folder .. "/favoriteOver.png", 	width = 68, height = 68  },
		is_favorite = { default = icons_folder .. "/isFavoriteDefault.png", over = icons_folder .. "/isFavoriteOver.png", 	width = 68, height = 68  },
		menu        = { default = icons_folder .. "/menuDefault.png", 		over = icons_folder .. "/menuOver.png", 		width = 68, height = 68  }
	}

	---- BASIC NAVBAR ----
	style.navbar = {
		height = 50 + user_config_style.navbar_stroke_height
	}
		
	style.navbar.background = {
		color = user_config_style.navbar_main_color
	}

	style.navbar.background.stroke = {
		color  = user_config_style.navbar_stroke_color,
		height = user_config_style.navbar_stroke_height
	}

	style.navbar.left_button = {
		image          = { default = images_folder .. "/basic-navbar/navBarButtonDefault.png", over = images_folder .. "/basic-navbar/navBarButtonOver.png" },
		height         = style.navbar.height,
		width          = style.navbar.height,
		margin_left    = 5,
		vertical_align = "center"
	}

	style.navbar.text = {
		fontSize       = 18,
		color          = user_config_style.navbar_text_color,
		vertical_align = "center"
	}


	---- TWO LINE NAVBAR ----
	style.two_line_navbar = {
		height = 100 + user_config_style.navbar_stroke_height,
		line_height = 50
	}
		
	style.two_line_navbar.background = {
		color = user_config_style.navbar_main_color
	}

	style.two_line_navbar.background.stroke = {
		color  = user_config_style.navbar_stroke_color,
		height = user_config_style.navbar_stroke_height
	}

	style.two_line_navbar.left_button = {
		image          = { default = images_folder .. "/basic-navbar/navBarButtonDefault.png", over = images_folder .. "/basic-navbar/navBarButtonOver.png" },
		height         = style.navbar.height,
		width          = style.navbar.height,
		margin_left    = 5,
		vertical_align = "center"
	}

	style.two_line_navbar.text = {
		fontSize       = 18,
		color          = user_config_style.navbar_text_color,
		vertical_align = "center"
	}

	---- TABBAR ----
	--style
	style.tabbar = {
		height = 0--68
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
	style.webview.y      = style.navbar.height + style.webview.height / 2 + display.topStatusBarContentHeight + style.navbar.background.stroke.height


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



	---- POST ----
	--style
	style.post = {}

	style.post.height = display.contentHeight - style.tabbar.height - display.topStatusBarContentHeight - style.navbar.height
	style.post.y      = display.topStatusBarContentHeight + style.navbar.height + style.navbar.background.stroke.height + style.post.height / 2

	style.post.background = {
		image = images_folder .. "/post/customcontentBG.png"
	}

	style.post.list = {
		height                 = 50,
		width                  = display.contentWidth - 20,
		space_between_elements = 10,
		color                  = { default = { 0.2, 0.2, 0.2, 1 }, over = { 0, 0, 0, 1 } }
	}

	style.post.list.sheet = {
		image   = images_folder .. "/post/listSheet.png",
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

	style.post.list.arrow = {
		image  = images_folder .. "/post/listArrow.png",
		width  = 14,
		height = 22
	}

	style.post.button = {
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
	    image = images_folder .. "/post/buttonSheet.png",
	    color = { default = { 1, 1, 1, 1 }, over = { 0, 0, 0, 1 } }
	}


	---- SCENE LIST ----
	--style
	style.scene_list = {
		title = {
			x          = 40,
			y          = 0,
			width      = display.contentWidth - 20,
			font_type  = native.systemFont,
			font_size  = 18,
			font_color = { r = 74/256, g = 74/256, b = 74/256 }
		},
		table_view = {
			left          = - 20,
			top           = display.topStatusBarContentHeight + style.navbar.height + style.navbar.background.stroke.height,
			height        = display.contentHeight - 50,
			width         = display.contentWidth + 40,
			hideScrollBar = true
		},
		no_posts_text = {
			x = display.contentWidth / 2,
			y = style.navbar.height + 50
		},
		row = {
			offset = 20
		}
	}


	---- ABOUT ----
	--style
	style.about = {
		title = {
			font_type = native.systemFont,
			font_size = 16
		},
		text = {
			x         = 10,
			y         = display.topStatusBarContentHeight + style.navbar.height + 10,
			font_size = 16,
			font_type = native.systemFont,
			font_color = { r = 74/256, g = 74/256, b = 74/256 }
		}
	}
	style.about.text.width = display.contentWidth - 2 * style.about.text.x
	

	return style
end
worona:do_action( "register_style", { style = "default", creator = newStyle } )
