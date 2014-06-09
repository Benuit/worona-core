local blood    = require "blood"
local composer = require "composer"

local scene = composer.newScene( "mapview" )

  -- -----------------------------------------------------------------------------------------------------------------
  -- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
  -- -----------------------------------------------------------------------------------------------------------------

  -- local forward references should go here
  ---------------------------------------------------------------------------------

local mapview, params

  -- "scene:create()"
function scene:create( event )

     local sceneGroup = self.view

     -- Initialize the scene here.
     -- Example: add display objects to "sceneGroup", add touch listeners, etc.
     
     local background = display.newRect( sceneGroup, display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )
     background:setFillColor( 1, 1, 1, 1 )

end

  -- "scene:show()"
function scene:show( event )

     local sceneGroup = self.view
     local phase = event.phase

     if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        

        blood:do_action( "add_tabbar", { parent = sceneGroup } )
        blood:do_action( "add_navbar", { text = params.title, parent = sceneGroup } )
        

     elseif ( phase == "did" ) then
        
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        mapview = native.newMapView( display.contentWidth / 2, display.contentHeight / 2 + display.topStatusBarContentHeight / 2, display.contentWidth, display.contentHeight -  50 - display.topStatusBarContentHeight - 50 )
        mapview:setCenter( params.location.lat, params.location.lng )
        mapview:addMarker( params.location.lat, params.location.lng, {title = params.title, subtitle = params.description })
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

    if mapview ~= nil then 
      
      mapview.x = display.contentWidth * 2
  	end

     elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
        display.remove( mapview )
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

local function load_mapview( remote_params )

	blood:do_action( "add_visited_page", { scene_name = "mapview" } )

	-- Options table for the overlay scene "pause.lua"
	local options = {
	    effect = "fade",
	    time = 100,
	    params = remote_params
	}

	params = remote_params

	-- By some method (a pause button, for example), show the overlay
	composer.gotoScene( "mapview", options )
end


blood:add_action( "load_mapview", load_mapview )
