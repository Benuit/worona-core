local worona = require "worona"
local widget = require( "widget" )

local function newScene( scene_name )

	local composer = require "composer"
	local scene    = composer.newScene( scene_name )
	-- local style    = worona.style:get("scene-list")

	-- -----------------------------------------------------------------------------------------------------------------
	-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
	-- -----------------------------------------------------------------------------------------------------------------


	-- "scene:create()"
	function scene:create( event )

		local sceneGroup = self.view

		-- Initialize the scene here.
		-- Example: add display objects to "sceneGroup", add touch listeners, etc.
	
		
		--: BACKGROUND
		-- local background = display.newRect( display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )
		-- sceneGroup:insert( background )

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
			    local rowWidth  = row.contentWidth

			    --. POST TITLE
			    local rowTitle = display.newText( row, row.params.content.title, 0, 0, nil, 14 )
			    rowTitle:setFillColor( 0 )

			    -- Align the label left and vertically centered
			    rowTitle.anchorX = 0
			    rowTitle.x = 50
			    rowTitle.anchorY = 0
			    rowTitle.y = 0


			    --. POST CONTENT SUMMARY
			    local rowContent = display.newText( row, row.params.content.content, 0, 0, nil, 14 )
			    rowContent:setFillColor( 0 )

			    -- Align the label left and vertically centered
			    rowContent.anchorX = 0
			    rowContent.x = 0
			    rowContent.anchorY = 0
			    rowContent.y = rowTitle.height

			end

			local function onRowTouch( event )
				local params = event.target.params
				worona:do_action( "load_url", { url = params.content.link } )
			end

			-- Create the widget
			local tableView = widget.newTableView
			{
			    left = 0,
			    top = 50,
			    height = display.contentHeight - 50,
			    width = display.contentWidth,
			    onRowRender = onRowRender,
			    onRowTouch = onRowTouch,
			    listener = scrollListener
			}
			
			sceneGroup:insert( tableView )

			-- Insert rows
			for i = 1, #content do

			    local isCategory = false
			    local rowHeight  = 60
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

local function loadListView( params )
	worona.log:info("scene-list/main - do action: go_to_scene -> scene-list")
	worona:do_action( "go_to_scene", { scene_type = "scene-list", effect = "slideLeft", time = 500 , params = { title = "Example Title" } } )
end
worona:add_action( "init", loadListView )