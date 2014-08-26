local worona = require "worona"

local function newScene( scene_name )

  local composer = require "composer"
  local scene = composer.newScene( scene_name )

  local webview
  local first_url, last_url

  local left_button_handler = function()

    first_url = string.match( first_url, "^(.-)/?$" )
    last_url  = string.match( last_url,  "^(.-)/?$" )

    if last_url == first_url then
      worona:do_action( "load_previous_scene", { effect = "slideRight", time = 200 } )
    else
      worona.log:info( "scene-webview: User is going back" )
      webview:back()
    end
  end

  local function webListener( event )
      
      if event.url then
          worona.log:info( "scene-webview: User is visiting: '" .. event.url .. "'" )
          last_url = event.url
      end
  end

    -- -----------------------------------------------------------------------------------------------------------------
    -- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
    -- -----------------------------------------------------------------------------------------------------------------

    -- "scene:create()"
  function scene:create( event )

    local sceneGroup = self.view

    worona:do_action( "before_creating_scene", params )

    local background = display.newRect( sceneGroup, display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )

    --: load the navbar
    local basic_navbar = worona.ui:newBasicNavBar({
     parent            = sceneGroup,
     text              = "Webview",
     left_button_icon  = worona.style:get("icons").back
    })

    worona:do_action( "before_creating_scene", params ) 
  end

    -- "scene:show()"
  function scene:show( event )

       local sceneGroup = self.view
       local phase = event.phase

       if ( phase == "will" ) then
          -- Called when the scene is still off screen (but is about to come on screen).
          --blood:do_action( "add_tabbar", { parent = sceneGroup } )
          --blood:do_action( "add_navbar", { text = params.websitetitle, parent = sceneGroup } )
          

       elseif ( phase == "did" ) then
          
          -- Called when the scene is now on screen.
          -- Insert code here to make the scene come alive.
          -- Example: start timers, begin animation, play audio, etc.
          local style = worona.style:get( "webview" )
          webview = native.newWebView( display.contentWidth / 2, style.y, display.contentWidth, style.height )
          first_url = worona.scene:getCurrentSceneUrl()
          webview:request( first_url or "about:blank" )

          webview:addEventListener( "urlRequest", webListener )

          worona:add_action( "navbar_left_button_pushed", left_button_handler )
          
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

        if webview ~= nil then 
  		    webview.x = display.contentWidth * 2
  	    end

      worona:remove_action( "navbar_left_button_pushed", left_button_handler )

       elseif ( phase == "did" ) then
          -- Called immediately after scene goes off screen.
          if webview ~= nil then 
  	        webview:request( "about:blank" ) 
  	        webview:stop()
          	timer.performWithDelay( 100, 	function() display.remove( webview ) end )
          end
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

worona:do_action( "register_scene", { scene_type = "scene-webview", creator = newScene } )