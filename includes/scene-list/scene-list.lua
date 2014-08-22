local worona = require "worona"
local widget = require "widget" 

local spinner = widget.newSpinner
{
    x = display.contentWidth / 2,
    y = 50 + (display.contentHeight - 50) / 2
}
spinner.alpha = 0

local tableView

worona.lang:load("worona.includes.scene-list.lang.scene-list-lang", "scene-list")

local function newScene( scene_name )

	local composer     = require "composer"
	local scene        = composer.newScene( scene_name )
	local style        = worona.style:get("list")

	-- -----------------------------------------------------------------------------------------------------------------
	-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
	-- -----------------------------------------------------------------------------------------------------------------

	-- "scene:create()"
	function scene:create( event )

		local sceneGroup = self.view

		

		-- Initialize the scene here.
		-- Example: add display objects to "sceneGroup", add touch listeners, etc.
		
	
		
		--: BACKGROUND
		local background = display.newRect( display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )
		sceneGroup:insert( background )
		sceneGroup:insert(spinner)

		local content = worona.content:getPostList("post")

		if content == -1 then
			local no_posts = display.newText( { 
				text = "Sorry, no posts available", 
				x = display.contentWidth/2, 
				y = display.contentHeight/2  } )
			no_posts:setFillColor( 1, 1, 1, 1 )
			sceneGroup:insert( no_posts )
		else

			--. Create a list with posts IDs ordered by date:
			local post_list_ordered = {}

			local function insertPostInOrder( current_post, index )

				if current_post.date_timestamp < post_list_ordered[index].date_timestamp then
					if index < #post_list_ordered then
						insertPostInOrder(current_post, index + 1)
					elseif index == #post_list_ordered then
						post_list_ordered[index + 1] = current_post
					else
						worona.log:error("scene-list.lua/insertPostInOrder - Error")
					end
				else
					for i=#post_list_ordered, index, -1 do
						post_list_ordered[i+1] = post_list_ordered[i]
					end
					post_list_ordered[index] = current_post
				end
			end

			for k,v in pairs(content) do
				
				v.date_timestamp = worona.date:convertWpDateToTimestamp( v.date )
				
				if v.status == "publish" then
					if #post_list_ordered ~= 0 then
						insertPostInOrder(v, 1)
					else
						post_list_ordered[1] = v
					end
				end
			end
			

			-- The "onRowRender" function may go here (see example under "Inserting Rows", above)
			local function onRowRender( event )

			    -- Get reference to the row group
			    local row = event.row

			    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
			    local rowHeight = row.contentHeight
			    local rowWidth = row.contentWidth

			    --. POST TITLE
			    local title_options = 
			    {	
			    	parent = row,
			        text     = row.params.content.title,
			        x        = 40,
			        y        = 0,
			        width    = display.contentWidth - 20,     --required for multi-line and alignment
			        font     = style.title.font_type,
			        fontSize = style.title.font_size
			    }
			    local rowTitle = display.newText( title_options )
			    rowTitle:setFillColor( 0 )

			    -- Align the label left and vertically centered
			    rowTitle.anchorX = 0.5
			    rowTitle.x = rowWidth / 2
			    rowTitle.anchorY = 0.5
			    rowTitle.y = rowHeight / 2
			end

			local function onRowTouch( event )
				local params = event.target.params
				worona:do_action( "load_url", { url = params.content.link } )
			end

			-- Create the widget
			tableView = widget.newTableView
			{
			    left = - 20,
			    top = style.top,
			    height = display.contentHeight - 50,
			    width = display.contentWidth + 40,
			    onRowRender = onRowRender,
			    onRowTouch = onRowTouch,
			    listener = scrollListener,
			    hideScrollBar = true
			}

			tableView.alpha = 0
			
			
			sceneGroup:insert( tableView )
			

			-- Insert rows
			for i = 1, #content do

			    local isCategory = false
			    local rowHeight  = 50
			    local rowColor   = { default = { 1, 1, 1 }, over = { 1, 0.5, 0, 0.2 } }
			    local lineColor  = { 0.5, 0.5, 0.5 }
			    local params     = {
			    						content = content[i]
									}
			    -- Insert a row into the tableView
			    tableView:insertRow(
			        {
			            isCategory = isCategory,
			            rowHeight  = rowHeight,
			            rowColor   = rowColor,
			            lineColor  = lineColor,
			            params     = params
			        }
			    )
			end

			
		end

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
		elseif ( phase == "did" ) then
			-- Called immediately after scene goes off screen.
		end
	end

	-- "scene:destroy()"
	function scene:destroy( event )

		local sceneGroup = self.view

		display.remove( spinner )
		display.remove( tableView )

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


local function callListScene()
	worona:do_action( "go_to_scene", { scene_type = "scene-list", effect = "fade", time = 500 } )
end
worona:add_action( "init", callListScene )

local function downloadContent()
	worona.log:info("scene-list - downloadContent()")
	tableView.alpha = 0
	spinner:start()
	spinner.alpha = 1
	worona.content:update( "post", worona.wp_url )
end
worona:add_action( "init", downloadContent )
worona:add_action("navbar_right_button_pushed", downloadContent)



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
	transition.to( tableView, { time=1000, alpha=1.0 } )

	native.showAlert(worona.lang:get("popup1_title", "scene-list"), worona.lang:get("popup1_description", "scene-list") , { worona.lang:get("popup_button_1", "scene-list"), worona.lang:get("popup_button_2", "scene-list") }, nativeAlertListener )
	
end
worona:add_action( "connection_not_available", loadSavedListData)


local function loadListView( params )
	spinner:stop()
	transition.to( tableView, { time=1000, alpha=1.0 } )
	worona.log:info("scene-list - loadListView()")
end
worona:add_action( "content_file_updated", loadListView )


local function loadAboutScene()

end



-------------------------- TO BE DELETED ------------------------

-- local function rightButtonPushedSimulation()
-- 	worona:do_action("navbar_right_button_pushed")
-- end
-- timer.performWithDelay( 10000, rightButtonPushedSimulation )


-- local function rightButtonPushedSimulation()
-- 	worona:do_action("navbar_left_button_pushed")
-- end
-- timer.performWithDelay( 15000, rightButtonPushedSimulation )
-------------------------------------------------------------------
