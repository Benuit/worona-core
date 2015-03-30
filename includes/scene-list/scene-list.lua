local worona = require "worona"
local user_config_style = require "worona-config.style"

local function newScene( scene_name )

	local composer     = require "composer"
	local widget       = require "widget" 
	local scene        = composer.newScene( scene_name )
	local style        = worona.style:get("scene_list")
	local navbar_style = worona.style:get("navbar")
	
	local spinner, content, sceneGroup, scrollView, no_posts_text, current_posts_shown, navbar

	worona.lang:load("worona-core.includes.scene-list.lang.scene-list-lang", "scene-list")

	local function loadMenuScene()
		worona.log:info("scene-list - loadMenuScene()")
		worona:do_action( "go_to_scene", { scene_type = "scene-menu", effect = "slideRight", time = 200 } )
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
			height                   = display.contentHeight - navbar_style.height - display.topStatusBarContentHeight, 
			horizontalScrollDisabled = true,
			verticalScrollDisabled   = false,
			topPadding               = 0,
			bottomPadding            = 30,
			hideBackground           = false,
			isBounceEnabled          = false,
			backgroundColor          = user_config_style.post_list_background_color,
			listener                 = scrollListener
		}

		scrollView_options = worona:do_filter( "filter_list_scrollView_options", scrollView_options )

		local scrollView = widget.newScrollView(scrollView_options)
		scrollView.current_y = 0
		scrollView.current_y = worona:do_filter( "filter_list_current_y_offset", scrollView.current_y )
		scrollView.row_elements = {}

		function scrollView:insertRow( params )
			
			local row_index = #scrollView.row_elements + 1
			scrollView.row_elements[row_index]        = {}
			scrollView.row_elements[row_index].params = params --. Insert params inside row object.
			scrollView.row_elements[row_index].row_y  = scrollView.current_y

			worona:do_action( "on_list_insert_row_start", { row = scrollView.row_elements[row_index] } )

			--. Set row height
			local row_height = params.row_height + 2 * style.row.offset
			row_height = worona:do_filter( "filter_list_row_height", row_height )
			scrollView.row_elements[row_index].row_height = row_height

			worona:do_action( "on_list_insert_row_after_set_row_height", { row = scrollView.row_elements[row_index] } )
			
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
	                worona:do_action( "load_url", { url = params.content.link } )
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
			row_line.strokeWidth = worona:do_filter( "filter_scene_list_row_line_width", row_line.strokeWidth)
			
			--. Insert all elements into the scrollView group
			params.row_group:insert(row_rect)
			row_rect:toBack()
			scrollView:insert(params.row_group)
			params.row_group:insert(row_line)

			--. Update current_y
			params.row_group.y = scrollView.row_elements[row_index].row_y
			scrollView.current_y = scrollView.current_y + row_height

			worona:do_action( "on_list_insert_row_end", { row = scrollView.row_elements[row_index], row_title = row_title, title_options = title_options } )

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

	local function insertContentInArrayOrderedByDate()

		--. Create a list with posts IDs ordered by date:
		local post_list_ordered = {}

		--. Function to insert a post in its correct place of a list ordered by date.
		local function insertCurrentPostInOrder( current_post, index )
			if current_post.date_timestamp < post_list_ordered[index].date_timestamp then
				if index < #post_list_ordered then
					insertCurrentPostInOrder(current_post, index + 1)
				elseif index == #post_list_ordered then
					post_list_ordered[index + 1] = current_post
				else
					worona.log:error("scene-list.lua/insertCurrentPostInOrder - Error")
				end
			else
				for i=#post_list_ordered, index, -1 do
					post_list_ordered[i+1] = post_list_ordered[i]
				end
				post_list_ordered[index] = current_post
			end
		end

		if content ~= nil then
			if type(content) == "table" then
				--. Loop content to identify published posts and insert them in the array post_list_ordered.
				for k,v in pairs(content) do	
					v.date_timestamp = worona.date:convertWpDateToTimestamp( v.date )
					
					if v.status == "publish" then
						if #post_list_ordered ~= 0 then
							insertCurrentPostInOrder(v, 1)
						else
							post_list_ordered[1] = v
						end
					end
				end
			end
		else
			worona.log:error("scene-list/insertContentInArrayOrderedByDate: content = nil")
		end

		return post_list_ordered
	end

	local function showNoPostsAvailable( params )
		no_posts_text = display.newText( { 
			text     = worona.lang:get("no_posts_available", "scene-list"), 
			fontSize = 20,
			x        = style.no_posts_text.x, 
			y        = style.no_posts_text.y,
			width    = display.contentWidth - 20,
			align    = "center" } )
		no_posts_text:setFillColor( 0, 0, 0, 0.8 )
		sceneGroup:insert( no_posts_text )
	end

	local function insertContentInScrollView()
	
		local post_list = {}
		local inserted_posts_counter = 0
		post_list = insertContentInArrayOrderedByDate()

		if post_list ~= nil then

			--. Insert rows with post_list into scrollView
			for i = 1, #post_list do

				local insert_current_row = worona:do_filter( "filter_list_insert_current_row", true, { post = post_list[i]} )

				if insert_current_row == true then

					local row_group = display.newGroup() --. All row elements must me inserted in this group.

					local unescaped_title = worona.string:unescape(post_list[i].title)

					local title_options = 
					{	
					    text     = unescaped_title,
					    x        = display.contentWidth/2, 
					    y        = style.row.offset,
					    width    = style.title.width,     --required for multi-line and alignment
					    font     = style.title.font_type,
					    fontSize = style.title.font_size
					}
					title_options = worona:do_filter( "filter_list_row_title_options", title_options )

					local row_text = display.newText( title_options )
					row_text:setFillColor( style.title.font_color.r, style.title.font_color.g, style.title.font_color.b )
					row_text.anchorY = 0
					row_group:insert(row_text)

					local row_options = 
					{
				    	row_text   = row_text,
				    	row_height = row_text.height,
				    	row_color  = user_config_style.post_list_row_color,
				    	content    = post_list[i],
				    	row_group  = row_group					    	
					}
					row_options = worona:do_filter( "filter_list_row_options", row_options )

				    --. Insert the current row into the scrollView
				    scrollView:insertRow (row_options)
				    inserted_posts_counter = inserted_posts_counter + 1
				end
			end

			if inserted_posts_counter == 0 and spinner.alpha == 0 then
				showNoPostsAvailable()
			end
		else
			worona.log:error("scene-list/insertContentInScrollView: post_list = nil")
		end
	end

	--. Configure hooks to content-download-type actions
	

	local function onContentUpdateStart()
		worona.log:info("scene-list - onContentUpdateStart()")
		scrollView.alpha = 0

		display.remove(no_posts_text)
		
		spinner:start()
		spinner.alpha = 1
	end
	worona:add_action( "on_content_update_start", onContentUpdateStart)

	local function loadSavedListData()
		spinner:stop()
		spinner.alpha = 0

		worona.log:info("scene-list - loadSavedListData()")
		
		if content ~= nil then
			
			if content == -1 or #content == 0 then
				worona.log:error("scene-list/loadSavedListData: content = -1 or #content = 0")
				showNoPostsAvailable()				
			else
				
				transition.to( scrollView, { time=1000, alpha=1.0 } )
			end
		else
			worona.log:error("scene-list/loadSavedListData: content = nil")
			showNoPostsAvailable()
		end	
	end
	worona:add_action( "connection_not_available", loadSavedListData )

	local function refreshScrollViewContent( params )
		content = worona.content:getPostList(worona.content_type)
		
		scrollView:deleteAllRows()
		insertContentInScrollView()
		
		spinner:stop()
		spinner.alpha = 0
		
		if content ~= nil then
			if content == -1 or #content == 0 then
				showNoPostsAvailable()
			else
				transition.to( scrollView, { time=1000, alpha=1.0 } )
				display.remove(no_posts_text)
			end
		else
			worona.log:error("scene-list/refreshScrollViewContent: content = nil")
			showNoPostsAvailable()
		end

		worona.log:info("scene-list - refreshScrollViewContent()")
	end
	worona:add_action( "content_file_updated", refreshScrollViewContent )

	local function downloadContent()
		worona.content:update( { content_type = worona.content_type, url = worona.wp_url } )
		if content ~= nil then
			if content == -1 or #content == 0 then
				worona.log:warning("scene-list/downloadContent: content has been downloaded, but it is empty.")
			else	
				worona.log:info("scene-list/downloadContent: content downloaded sucessfully.")
			end
		else
			worona.log:error("scene-list/downloadContent: content = nil.")
		end
	end

	local function isThisPostFavorite( default_value, params )
		
		if worona.favorite:isFavorite( { post_id = params.post.ID } ) == true then
			return true
		else
			return false
		end
	end

	-- -----------------------------------------------------------------------------------------------------------------
	-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
	-- -----------------------------------------------------------------------------------------------------------------

	-- "scene:create()"
	function scene:create( event )
		-- Initialize the scene here.
		-- Example: add display objects to "sceneGroup", add touch listeners, etc.

		worona:do_action( "before_creating_scene_list" )

		current_posts_shown = event.params.show_posts
		content = worona.content:getPostList(worona.content_type)

		--. View elements
		sceneGroup = self.view

		local background = display.newRect	( 	display.contentWidth / 2, 
												display.contentHeight / 2, 
												display.contentWidth, 
												display.contentHeight 
											)
		sceneGroup:insert( background )

		spinner = widget.newSpinner
		{
		    x = display.contentWidth / 2,
		    y = 50 + (display.contentHeight - 50) / 2
		}
		spinner.alpha = 0
		sceneGroup:insert(spinner)


		if scrollView == nil then
			scrollView = createScrollview({ parent_group = sceneGroup })
			scrollView.alpha = 0
		end

		downloadContent()


		worona:do_action( "after_creating_scene_list" )
	end

	-- "scene:show()"
	function scene:show( event )

		sceneGroup = self.view
		local phase = event.phase

		if ( phase == "will" ) then
			-- Called when the scene is still off screen (but is about to come on screen).

			worona:do_action( "remove_tabbar" )

			local navbar_title = worona.app_title
			
			scrollView:deleteAllRows()

			if event.params ~= nil then
				if event.params.show_posts == "favorites" then
					worona:add_filter( "filter_list_insert_current_row", isThisPostFavorite )
					navbar_title = worona.lang:get("favorites", "scene-list")
				else
					worona:remove_filter( "filter_list_insert_current_row", isThisPostFavorite )
				end

				current_posts_shown = event.params.show_posts
			end

			insertContentInScrollView()	
			scrollView:scrollTo( "top", { time = 0 } )

			--: load the navbar
			navbar = worona.ui:newBasicNavBar({
				parent            = sceneGroup,
				text              = navbar_title,
				left_button_icon  = worona.style:get("icons").menu,
				right_button_icon = worona.style:get("icons").refresh
			})

		elseif ( phase == "did" ) then
			-- Called when the scene is now on screen.
			-- Insert code here to make the scene come alive.
			-- Example: start timers, begin animation, play audio, etc.

			worona:add_action("navbar_right_button_pushed", downloadContent)
			worona:add_action("navbar_left_button_pushed", loadMenuScene)
			worona:add_action("android_back_button_pushed", exitApp)	 
		end
	end

	-- "scene:hide()"
	function scene:hide( event )

		sceneGroup = self.view
		local phase = event.phase

		if ( phase == "will" ) then
			-- Called when the scene is on screen (but is about to go off screen).
			-- Insert code here to "pause" the scene.
			-- Example: stop timers, stop animation, stop audio, etc.

			worona:remove_action("navbar_right_button_pushed", downloadContent)
			worona:remove_action("navbar_left_button_pushed", loadMenuScene)
			worona:remove_action("android_back_button_pushed", exitApp)	 

		elseif ( phase == "did" ) then
			-- Called immediately after scene goes off screen.
			display.remove(navbar)
			display.remove( no_posts_text )
		end
	end

	-- "scene:destroy()"
	function scene:destroy( event )

		sceneGroup = self.view


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
worona:do_action( "register_scene", { scene_type = "scene-list", creator = newScene } )


