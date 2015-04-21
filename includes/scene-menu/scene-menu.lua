local worona = require "worona"
local user_config_style = require "worona-config.style"

local function newScene( scene_name )

	local composer     = require "composer"
	local widget       = require "widget" 
	local scene        = composer.newScene( scene_name )
	local style        = worona.style:get("scene_list")
	local navbar_style = worona.style:get("navbar")
	
	local scrollView, no_posts_text, powered_img
	local scene_action = {}

	worona.lang:load("worona-core.includes.scene-menu.lang.scene-menu-lang", "scene-menu")

	local all_posts_text = worona.lang:get("all_posts", "scene-menu")
	local favorite_posts_text = worona.lang:get("favorite_posts", "scene-menu")
	local about_text = worona.lang:get("about", "scene-menu")

	local menu_items_table = worona:do_filter( "filter_menu_list_items_table",
		{ 
			
			{ 
				text = all_posts_text,
				action = {
					name   = "go_to_scene", 
					params = { scene_type = "scene-list", effect = "slideLeft", time = 200, params = { show_posts = "all" } }
				}
			},
			{ 
				text = favorite_posts_text,
				action = {
					name   = "go_to_scene", 
					params = { scene_type = "scene-list", effect = "slideLeft", time = 200, params = { show_posts = "favorites" } }
				}
			},
			{ 
				text = about_text,
				action = {
					name   = "go_to_scene", 
					params = { scene_type = "scene-about", effect = "slideLeft", time = 200 }
				}
			}
		}
	)

	

	local function loadSceneList()
		worona.log:info("scene-menu - loadSceneList()")
		worona:do_action( "go_to_scene", { scene_type = "scene-list", effect = "slideLeft", time = 200 } )
	end

	local function exitApp()
		native.requestExit()
	end

	local function createScrollview( params )

		local function scrollListener( event )
			local phase = event.phase
			local direction = event.direction

			if "began" == phase then
				-- print( "Began" )
			elseif "moved" == phase then
				-- print( "Moved" )
			elseif "ended" == phase then
				-- print( "Ended" )
			end

			-- If the scrollView has reached it's scroll limit
			if event.limitReached then
				if "up" == direction then
					-- print( "Reached Top Limit" )
				elseif "down" == direction then
					-- print( "Reached Bottom Limit" )
				elseif "left" == direction then
					-- print( "Reached Left Limit" )
				elseif "right" == direction then
					-- print( "Reached Right Limit" )
				end
			end
			     
			return true
		end

		local scrollView_options = 
		{
			top                      = navbar_style.height + display.topStatusBarContentHeight, 
			left                     = 0,
			width                    = display.contentWidth,
			height                   = display.contentHeight - navbar_style.height - display.topStatusBarContentHeight - powered_img.height - 10, 
			horizontalScrollDisabled = true,
			verticalScrollDisabled   = false,
			topPadding               = 0,
			bottomPadding            = 30,
			hideBackground           = false,
			isBounceEnabled          = false,
			backgroundColor          = user_config_style.post_list_background_color,
			listener                 = scrollListener
		}

		scrollView_options = worona:do_filter( "filter_list_menu_scrollView_options", scrollView_options )

		local scrollView = widget.newScrollView(scrollView_options)
		scrollView.current_y = 0
		scrollView.current_y = worona:do_filter( "filter_list_menu_current_y_offset", scrollView.current_y )
		scrollView.row_elements = {}

		function scrollView:insertRow( params )
			
			local row_index = #scrollView.row_elements + 1
			scrollView.row_elements[row_index]        = {}
			scrollView.row_elements[row_index].params = params --. Insert params inside row object.
			scrollView.row_elements[row_index].row_y  = scrollView.current_y

			worona:do_action( "on_list_menu_insert_row_start", { row = scrollView.row_elements[row_index] } )

			--. Set row height
			local row_height = params.row_text.height + 2 * style.row.offset
			row_height = worona:do_filter( "filter_list_menu_row_height", row_height )
			scrollView.row_elements[row_index].row_height = row_height

			worona:do_action( "on_list_insert_menu_row_after_set_row_height", { row = scrollView.row_elements[row_index] } )
			
			--. Create background rectangle to get touch events
			local row_rect         = display.newRect( display.contentWidth/2, 0, display.contentWidth, row_height )
			row_rect.anchorY       = 0
			row_rect:setFillColor( params.row_color.default[1], params.row_color.default[2], params.row_color.default[3], params.row_color.default[4] )
			row_rect.isHitTestable = true
			
			local function scrollableRowHandler( event )
		        
	            if event.phase == "began" then
	            	row_rect:setFillColor( params.row_color.over[1], params.row_color.over[2], params.row_color.over[3], params.row_color.over[4] ) 
	            elseif event.phase == "moved" then
	            	row_rect:setFillColor( params.row_color.default[1], params.row_color.default[2], params.row_color.default[3], params.row_color.default[4] ) 

	                local dx = math.abs( event.x - event.xStart )
	                local dy = math.abs( event.y - event.yStart )

	                if dx > 5 or dy > 5 then
	                    scrollView:takeFocus( event )
	                end
	            elseif event.phase == "ended" then
	            	row_rect:setFillColor( params.row_color.default[1], params.row_color.default[2], params.row_color.default[3], params.row_color.default[4] ) 
	                display.getCurrentStage():setFocus(nil)

	                if scene_action.name == "show" and scene_action.phase == "did" then
						worona:do_action( params.row_action.name, params.row_action.params )
					end
	            elseif event.phase == "cancelled" then
	            	row_rect:setFillColor( params.row_color.default[1], params.row_color.default[2], params.row_color.default[3], params.row_color.default[4] ) 
	            end

	            return true
		    end
			row_rect:addEventListener("touch", scrollableRowHandler)

			--. Create separation line between rows
			local row_line = display.newLine( 0, row_height, display.contentWidth, row_height )
			row_line:setStrokeColor( user_config_style.post_list_row_line_stroke_color[1], user_config_style.post_list_row_line_stroke_color[2], user_config_style.post_list_row_line_stroke_color[3], user_config_style.post_list_row_line_stroke_color[4] )
			row_line.strokeWidth = user_config_style.post_list_row_line_stroke_width
			row_line.strokeWidth = worona:do_filter( "filter_menu_list_row_line_width", row_line.strokeWidth)
			
			--. Insert all elements into the scrollView group
			params.row_group:insert(row_rect)
			row_rect:toBack()
			scrollView:insert(params.row_group)
			params.row_group:insert(row_line)

			--. Update current_y
			params.row_group.y = scrollView.row_elements[row_index].row_y
			scrollView.current_y = scrollView.current_y + row_height

			worona:do_action( "on_list_menu_insert_row_end", { row = scrollView.row_elements[row_index], row_title = row_title, title_options = title_options } )

		end
		
		function scrollView:deleteAllRows( )
			
			local i 

			for i=1,#scrollView.row_elements do
				display.remove( scrollView.row_elements[i].params.row_group )
				scrollView.row_elements[i] = nil
			end

			scrollView.current_y = 0
		end

		if params.parent_group ~= nil then
			params.parent_group:insert(scrollView)
		end

		return scrollView
	end

	local function insertContentInScrollView( )
		
		for i=1,#menu_items_table do
			
			local row_group = display.newGroup() --. All row elements must me inserted in this group.

			local title_options = 
			{	
			    text     = menu_items_table[i].text,
			    x        = display.contentWidth/2, 
			    y        = style.row.offset,
			    width    = style.title.width,     --required for multi-line and alignment
			    font     = style.title.font_type,
			    fontSize = style.title.font_size
			}
			title_options = worona:do_filter( "filter_menu_list_row_title_options", title_options )

			local row_text = display.newText( title_options )
			row_text:setFillColor( style.title.font_color.r, style.title.font_color.g, style.title.font_color.b )
			row_text.anchorY = 0
			row_group:insert(row_text)

			local row_options = 
			{
		    	row_text  = row_text,
		    	row_color = user_config_style.post_list_row_color,
		    	row_action = {
		    		name = menu_items_table[i].action.name,
		    		params = menu_items_table[i].action.params
		    	},
		    	row_group = row_group					    	
			}
			row_options = worona:do_filter( "filter_menu_list_row_options", row_options )

		    --. Insert the current row into the scrollView
		    scrollView:insertRow (row_options)
		end
	end

	-- -----------------------------------------------------------------------------------------------------------------
	-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
	-- -----------------------------------------------------------------------------------------------------------------

	-- "scene:create()"
	function scene:create( event )
		-- Initialize the scene here.
		-- Example: add display objects to "sceneGroup", add touch listeners, etc.

		scene_action = {
			name = "create",
			phase = nil
		}

		worona:do_action( "before_creating_scene_menu" )

		--. View elements
		local sceneGroup = self.view

		local background = display.newRect	( 	display.contentWidth / 2, 
												display.contentHeight / 2, 
												display.contentWidth, 
												display.contentHeight 
											)
		sceneGroup:insert( background )

		local bg_rect = display.newRect( sceneGroup, display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )
		bg_rect:setFillColor( user_config_style.post_list_background_color[1], user_config_style.post_list_background_color[2], user_config_style.post_list_background_color[3] )

		if worona:do_filter( "filter_scene_menu_powered_img", true ) == true then
			powered_img = display.newImageRect( "worona-core/includes/scene-about/img/Worona-badge.png", 185, 35 )
			powered_img.anchorX = 0.5
			powered_img.anchorY = 1
			powered_img.x = display.contentWidth / 2
			powered_img.y = display.contentHeight - 10
			sceneGroup:insert(powered_img)

			--: open safari with worona.org when they tap on the badge
			powered_img:addEventListener( "touch", function(e) if e.phase == "ended" then system.openURL( "http://www.worona.org" ) end  end )
		else
			powered_img = { height = 0 }
		end		

		scrollView = createScrollview({ parent_group = sceneGroup })
		scrollView.alpha = 0

		insertContentInScrollView()
		transition.to( scrollView, { time=200, alpha=1.0 } )



		local navbar_options = worona:do_filter( "filter_menu_list_nabvar_options", {
			parent            = sceneGroup,
			text              = "Menu"
		})

		--: load the navbar
		local navbar = worona.ui:newBasicNavBar( navbar_options )

		worona:do_action( "after_creating_scene_menu" )
	end

	-- "scene:show()"
	function scene:show( event )

		local sceneGroup = self.view
		local phase = event.phase

		scene_action.name = "show"
			

		if ( phase == "will" ) then
			-- Called when the scene is still off screen (but is about to come on screen).
			scene_action.phase = "will"
			
			worona:do_action( "remove_tabbar" )

		elseif ( phase == "did" ) then
			-- Called when the scene is now on screen.
			-- Insert code here to make the scene come alive.
			-- Example: start timers, begin animation, play audio, etc.
			scene_action.phase = "did"

			worona:add_action("android_back_button_pushed", exitApp)	 
		end
	end

	-- "scene:hide()"
	function scene:hide( event )

		local sceneGroup = self.view
		local phase = event.phase
		scene_action.name = "hide"

		if ( phase == "will" ) then
			-- Called when the scene is on screen (but is about to go off screen).
			-- Insert code here to "pause" the scene.
			-- Example: stop timers, stop animation, stop audio, etc.
			scene_action.phase = "will"

			worona:remove_action("android_back_button_pushed", exitApp)	 

		elseif ( phase == "did" ) then
			-- Called immediately after scene goes off screen.
			scene_action.phase = "did"
		end
	end

	-- "scene:destroy()"
	function scene:destroy( event )

		scene_action.name  = "destroy"
		scene_action.phase = nil

		local sceneGroup = self.view


		-- Called prior to the removal of scene's view ("sceneGroup").
		-- Insert code here to clean up the scene.
		-- Example: remove display objects, save state, etc.
	end

	-- -------------------------------------------------------------------------------

	-- Listener setup
	scene:addEventListener( "create", scene )
	scene:addEventListener( "show", scene )
	scene:addEventListener( "hide", scene )
	scene:addEventListener( "destroy", scene )

	-- -------------------------------------------------------------------------------
	return scene
end
worona:do_action( "register_scene", { scene_type = "scene-menu", creator = newScene } )


