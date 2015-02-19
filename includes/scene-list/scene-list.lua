local worona = require "worona"

local function newScene( scene_name )

	local composer = require "composer"
	local widget   = require "widget" 
	local scene    = composer.newScene( scene_name )
	local style    = worona.style:get("list")
	
	local spinner, scrollView, no_posts_text

	local function loadAboutScene()
		worona.log:info("scene-list - loadAboutScene()")
		worona:do_action( "go_to_scene", { scene_type = "scene-about", effect = "slideRight", time = 200 } )
	end


	worona.lang:load("worona-core.includes.scene-list.lang.scene-list-lang", "scene-list")

	local function downloadContent()
		worona.log:info("scene-list - downloadContent()")
		scrollView.alpha = 0

		display.remove(no_posts_text)
		
		spinner:start()
		spinner.alpha = 1
		worona.content:update( { content_type = worona.content_type, url = worona.wp_url } )
	end

	local function exitApp()
		native.requestExit()
	end

	-- -----------------------------------------------------------------------------------------------------------------
	-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
	-- -----------------------------------------------------------------------------------------------------------------

	-- "scene:create()"
	function scene:create( event )
		-- Initialize the scene here.
		-- Example: add display objects to "sceneGroup", add touch listeners, etc.

		worona:do_action( "before_creating_scene" )

		local content = worona.content:getPostList(worona.content_type)

		--. View elements
		local sceneGroup = self.view

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


		local function createScrollview( params )

			local function scrollListener( event )
				local phase = event.phase
				local direction = event.direction

				if "began" == phase then
					print( "Began" )
				elseif "moved" == phase then
					print( "Moved" )
				elseif "ended" == phase then
					print( "Ended" )
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

			local function onRowTouch( event )
				if event.phase == "release" or event.phase == "tap" then
					local params = event.target.params
					worona:do_action( "load_url", { url = params.content.link } )
					return true
				end

				return true
			end

			local scrollView_options = 
			{
				y                        = display.contentHeight/2, -- CAMBIAR
				x                        = display.contentWidth/2, --CAMBIAR
				width                    = display.contentWidth, --CAMBIAR
				height                   = display.contentHeight - 50, -- CAMBIAR
				horizontalScrollDisabled = true,
				verticalScrollDisabled   = false,
				topPadding               = 10,
				bottomPadding            = 30,
				hideBackground           = false,
				backgroundColor          = { 0.8, 0.8, 0.8 },
				listener                 = scrollListener
			}

			scrollView_options = worona:do_filter( "list_scrollView_options_filter", scrollView_options )

			local scrollView = widget.newScrollView(scrollView_options)

			function scrollView:insertRow( params )
				worona.log:debug("ahora inserto una fila")

				local row = {}
				row.params = params --. Insert params in row.

				worona:do_action( "on_list_row_render_start", { row = row } )

				--. POST TITLE
				-- local title_options = 
				-- {	
				-- 	parent   = scrollView,
				--     text     = row.params.title_options.text,    
				--     x        = 100, -- row.params.title_options.x,   
				--     y        = 200, -- row.params.title_options.y,       
				--     width    = 200, -- row.params.title_options.width,   
				--     font     = row.params.title_options.font,    
				--     fontSize = row.params.title_options.fontSize
				-- }
				-- title_options = worona:do_filter( "list_row_title_options_filter", title_options )
				-- local row_title = display.newText( title_options )
				-- row_title:setFillColor( style.title.font_color.r, style.title.font_color.g, style.title.font_color.b )

				scrollView:insert(row.params.row_group)

				-- Align the label left and vertically centered
				-- row_title.anchorX = 0.5
				-- row_title.x = display.contentWidth / 2 -- CAMBIAR
				-- row_title.anchorY = 0.5
				-- row_title.y = 200 -- display.contentHeight / 2 -- CAMBIAR

				worona:do_action( "on_list_row_render_end", { row = row, row_title = row_title, title_options = title_options } )

			end

			function scrollView:deleteAllRows( )
				worona.log:debug("ahora borro todas las filas")
				local prueba = self

				worona.log:debug("prueba.y = " .. prueba.y)
			end
			
			if params.parent_group ~= nil then
				params.parent_group:insert(scrollView)
			end

			return scrollView
		end


		local function insertContentInScrollView()
	
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
				else
					worona.log:error("scene-list/insertContentInScrollView: content = nil")
				end

				return post_list_ordered
			end

			local post_list = {}
			post_list = insertContentInArrayOrderedByDate()

			if post_list ~= nil then

				local current_y = 0

				--. Insert rows with post_list into scrollView
				for i = 1, #post_list do

					local row_group = display.newGroup() --. All row elements must me inserted in this group.

					if i == 1 then 
						local navbar_style = worona.style:get("navbar")
						current_y = display.topStatusBarContentHeight + navbar_style.height
					end

					local unescaped_title = worona.string:unescape(post_list[i].title)

					local title_options = 
					{	
					    text     = unescaped_title,
					    x        = display.contentWidth/2, -- CAMBIAR style.title.x,
					    y        = 20, -- CAMBIAR style.title.y,
					    width    = style.title.width,     --required for multi-line and alignment
					    font     = style.title.font_type,
					    fontSize = style.title.font_size
					}

					local row_text = display.newText( title_options )
					row_text:setFillColor( style.title.font_color.r, style.title.font_color.g, style.title.font_color.b )

					row_group:insert(row_text)
					row_group.y = current_y
					
					current_y = current_y + row_text.height + title_options.y

					local row_options = 
					{
				    	content = post_list[i],
				    	row_group = row_group
					}

					row_options = worona:do_filter( "list_row_options_filter", row_options )

				    --. Insert the current row into the scrollView
				    scrollView:insertRow (row_options)
				end
			else
				worona.log:error("scene-list/insertContentInScrollView: post_list = nil")
			end
		end


		scrollView = createScrollview({ parent_group = sceneGroup })
		scrollView.alpha = 0


		

		local function showNoPostsAvailable()
			no_posts_text = display.newText( { 
				text = worona.lang:get("no_posts_available", "scene-list"), 
				fontSize = 20,
				x = style.no_posts_text.x, 
				y = style.no_posts_text.y } )
			no_posts_text:setFillColor( 0, 0, 0, 0.8 )
			sceneGroup:insert( no_posts_text )
		end

		--. Configure hooks to content-download-type actions
		local function loadSavedListData()
			spinner:stop()
			spinner.alpha = 0

			local function nativeAlertListener( event )
			    if "clicked" == event.action then
			        if event.index == 1 then
			        	worona.log:info("scene-list - nativeAlertListener() - option 1 selected")
			        elseif event.index == 2 then
						worona.log:info("scene-list - nativeAlertListener() - option 2 selected")
			        	scrollView.alpha = 0
			        	spinner:start()
			        	spinner.alpha = 1
			            timer.performWithDelay( 1000, downloadContent )
			        end
			    end
			end

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
		worona:add_action( "connection_not_available", loadSavedListData)

		local function refreshScrollViewContent( params )
			content = worona.content:getPostList(worona.content_type)
			scrollView:deleteAllRows()
			insertContentInScrollView( scrollView )
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
		worona:add_action( "content_file_updated", refreshScrollViewContent)


		downloadContent()
		if content ~= nil then
			if content == -1 or #content == 0 then
				-- no content
			else		
				insertContentInScrollView(scrollView)
			end
		else
			worona.log:error("scene-list/create: content = nil")
		end


		--: load the navbar
		local basic_navbar = worona.ui:newBasicNavBar({
			parent            = sceneGroup,
			text              = worona.app_title,
			left_button_icon  = worona.style:get("icons").more,
			right_button_icon = worona.style:get("icons").refresh
		})

		worona:do_action( "after_creating_scene" )
	end

	-- "scene:show()"
	function scene:show( event )

		local sceneGroup = self.view
		local phase = event.phase

		if ( phase == "will" ) then
			-- Called when the scene is still off screen (but is about to come on screen).

			worona:do_action( "remove_tabbar" )

		elseif ( phase == "did" ) then
			-- Called when the scene is now on screen.
			-- Insert code here to make the scene come alive.
			-- Example: start timers, begin animation, play audio, etc.

			worona:add_action("navbar_right_button_pushed", downloadContent)
			worona:add_action("navbar_left_button_pushed", loadAboutScene)
			worona:add_action("android_back_button_pushed", exitApp)	 
		end
	end

	-- "scene:hide()"
	function scene:hide( event )

		local sceneGroup = self.view
		local phase = event.phase

		if ( phase == "will" ) then
			-- Called when the scene is on screen (but is about to go off screen).
			-- Insert code here to "pause" the scene.
			-- Example: stop timers, stop animation, stop audio, etc.

			worona:remove_action("navbar_right_button_pushed", downloadContent)
			worona:remove_action("navbar_left_button_pushed", loadAboutScene)
			worona:remove_action("android_back_button_pushed", exitApp)	 

		elseif ( phase == "did" ) then
			-- Called immediately after scene goes off screen.
		end
	end

	-- "scene:destroy()"
	function scene:destroy( event )

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
worona:do_action( "register_scene", { scene_type = "scene-list", creator = newScene } )


