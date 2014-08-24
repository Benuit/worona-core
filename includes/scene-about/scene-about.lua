local worona = require "worona"
local widget = require "widget" 


local function loadSceneList()
	worona:do_action( "go_to_scene", { scene_type = "scene-list", effect = "fromLeft", time = 500 } )
end



local function newScene( scene_name )

	local composer = require "composer"
	local scene    = composer.newScene( scene_name )
	-- local style    = worona.style:get("list")


	-- -----------------------------------------------------------------------------------------------------------------
	-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
	-- -----------------------------------------------------------------------------------------------------------------

	-- "scene:create()"
	function scene:create( event )

		worona:do_action( "before_creating_scene" )

		local sceneGroup = self.view

		-- Initialize the scene here.
		-- Example: add display objects to "sceneGroup", add touch listeners, etc.
		
		--: BACKGROUND
		local background = display.newRect( display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )
		sceneGroup:insert( background )

		
		--: load the navbar
		local basic_navbar = worona.ui:newBasicNavBar({
			parent            = sceneGroup,
			text              = "About",
			left_button_icon  = worona.style:get("icons").more,
			right_button_icon = worona.style:get("icons").refresh
		})

		local text_options = 
		{	
			parent = sceneGroup,
		    text     = worona.app_about_description,
		    x        = 10,
		    y        = 60,
		    width    = display.contentWidth - 20,     --required for multi-line and alignment
		    -- font     = style.title.font_type,
		    -- fontSize = style.title.font_size
		}
		local text = display.newText( text_options )
		text:setFillColor( 0 )
		text.anchorX = 0
		text.anchorY = 0
		

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

			worona:add_action("navbar_left_button_pushed", loadSceneList, 10, "loadSceneList")	 
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

			worona:remove_action("navbar_left_button_pushed", loadAboutScene)

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
worona:do_action( "register_scene", { scene_type = "scene-about", creator = newScene } )
