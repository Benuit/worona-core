local worona = require "worona"

local function newScene( scene_name )

	local composer = require "composer"
	local widget   = require "widget" 
	local scene    = composer.newScene( scene_name )
	local style    = worona.style:get("list")
	
	local spinner, tableView, no_posts_text

	local function loadAboutScene()
		worona.log:info("scene-list - loadAboutScene()")
		worona:do_action( "go_to_scene", { scene_type = "scene-about", effect = "slideRight", time = 200 } )
	end


	worona.lang:load("worona-core.includes.scene-list.lang.scene-list-lang", "scene-list")

	local function downloadContent()
		worona.log:info("scene-list - downloadContent()")
		tableView.alpha = 0

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

		
		local function createTableView( parent_group )

			local table_view
			
			local function onRowRender( event )

			    -- Get reference to the row group
			    local row = event.row

			    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
			    local rowHeight = row.contentHeight
			    local rowWidth = row.contentWidth

			    worona:do_action( "on_list_row_render_start", { row = row } )

			    --. POST TITLE
			    local title_options = 
			    {	
			    	parent   = row,
			        text     = row.params.title_options.text,    
			        x        = row.params.title_options.x,   
			        y        = row.params.title_options.y,       
			        width    = row.params.title_options.width,   
			        font     = row.params.title_options.font,    
			        fontSize = row.params.title_options.fontSize
			    }
			    title_options = worona:do_filter( "list_row_title_options_filter", title_options )
			    local row_title = display.newText( title_options )
			    row_title:setFillColor( style.title.font_color.r, style.title.font_color.g, style.title.font_color.b )

			    -- Align the label left and vertically centered
			    row_title.anchorX = 0.5
			    row_title.x = rowWidth / 2
			    row_title.anchorY = 0.5
			    row_title.y = rowHeight / 2

			    worona:do_action( "on_list_row_render_end", { row = row, row_title = row_title, title_options = title_options } )
			end

			local function onRowTouch( event )
				if event.phase == "release" or event.phase == "tap" then
					local params = event.target.params
					worona:do_action( "load_url", { url = params.content.link } )
					return true
				end

				return true
			end

			local tableview_options = 
			{
				left = style.table_view.left,
				top = style.table_view.top,
				height = style.table_view.height,
				width = style.table_view.width,
				hideScrollBar = style.table_view.hideScrollBar,
				onRowRender = onRowRender,
				onRowTouch = onRowTouch,
				listener = scrollListener,
				bottomPadding = 50
			}
			tableview_options = worona:do_filter( "list_tableview_options_filter", tableview_options )

			local borrar = 0

			-- Create the widget
			table_view = widget.newTableView(tableview_options)

			if parent_group ~= nil then
				parent_group:insert(table_view)
			end

			return table_view
		end
		
		local function insertContentInTableView(table_view)

			--. Create a list with posts IDs ordered by date:
			local post_list_ordered = {}

			--. Recursive function to insert a post in a list ordered by date.
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
				worona.log:error("scene-list/insertContentInTableView: content = nil")
			end

			
			if content ~= nil then
				--. Insert rows with content into table_view
				for i = 1, #content do

					local unescaped_title = worona.string:unescape(content[i].title)

					local title_options = 
					{	
					    text     = unescaped_title,
					    x        = style.title.x,
					    y        = style.title.y,
					    width    = style.title.width,     --required for multi-line and alignment
					    font     = style.title.font_type,
					    fontSize = style.title.font_size
					}
					title_options = worona:do_filter( "list_row_dummy_title_options_filter", title_options )
					local dummy_text = display.newText( title_options )
					dummy_text.alpha = 0
					local text_height = dummy_text.height
					display.remove( dummy_text )

					local row_options = {

				    	is_category  = false,
				    	row_height   = text_height + 30,
				    	row_color    = { default = { 1, 1, 1 }, over = { 1, 0.5, 0, 0.2 } },
				    	line_color   = { 0.5, 0.5, 0.5 },
				    	params       = {
				    						content = content[i],
				    						title_options = title_options
										}
					}

					row_options = worona:do_filter( "list_row_options_filter", row_options )

				    -- Insert a row into the tableView
				    table_view:insertRow(
				        {
				            isCategory = row_options.is_category,
				            rowHeight  = row_options.row_height,
				            rowColor   = row_options.row_color,
				            lineColor  = row_options.line_color,
				            params     = row_options.params
				        }
				    )
				
				end
			else
				worona.log:error("scene-list/insertContentInTableView: content = nil")
			end
		end
		tableView = createTableView(sceneGroup)
		tableView.alpha = 0


		
		downloadContent(tableView, spinner)


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
			        	tableView.alpha = 0
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
					transition.to( tableView, { time=1000, alpha=1.0 } )
				end
			else
				worona.log:error("scene-list/loadSavedListData: content = nil")
				showNoPostsAvailable()
			end

			
		end
		
		worona:add_action( "connection_not_available", loadSavedListData)

		local function refreshTableViewContent( params )
			content = worona.content:getPostList(worona.content_type)
			tableView:deleteAllRows()
			insertContentInTableView( tableView )
			spinner:stop()
			spinner.alpha = 0
			
			

			if content ~= nil then
				if content == -1 or #content == 0 then
					
					showNoPostsAvailable()
				else
					transition.to( tableView, { time=1000, alpha=1.0 } )
					
					display.remove(no_posts_text)
					
					
				end
			else
				worona.log:error("scene-list/refreshTableViewContent: content = nil")
				showNoPostsAvailable()
			end

			worona.log:info("scene-list - refreshTableViewContent()")
		
		end
		worona:add_action( "content_file_updated", refreshTableViewContent)


		if content ~= nil then
			if content == -1 or #content == 0 then
				
			else
				
				insertContentInTableView(tableView)
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


