local worona = require "worona"

local function newScene( scene_name )

	local composer = require "composer"
	local scene = composer.newScene( scene_name )

	local webview
	local url
	local webview_counter = 0
	local scene_on_screen = false

	local left_button_handler = function()

	if webview_counter <= 0 then
	  worona:do_action( "load_previous_scene", { effect = "slideRight", time = 200 } )
	else
	  worona.log:info( "scene-webview: User is going back" )
	  webview_counter = webview_counter - 1
	  webview:back()
	end
	end

	local function webListener( event )

	  if event.url and event.type == "link" then
	    worona.log:info( "scene-webview: User has visited: " .. event.url )
	    webview_counter = webview_counter + 1
	  end
	end

  	local function stopWebviewOnSuspend( event )
  		if worona.device:getPlatformName() == "Android" then
  			if webview ~= nil then
      			if event.type == "applicationSuspend" then  
      				webview:request( url )
      			end
      		end
      	end
  	end
  	Runtime:addEventListener( "system", stopWebviewOnSuspend )

    -- -----------------------------------------------------------------------------------------------------------------
    -- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
    -- -----------------------------------------------------------------------------------------------------------------

    -- "scene:create()"
  function scene:create( event )

    local sceneGroup = self.view

    worona:do_action( "before_creating_scene_webview", params )

    url = worona.scene:getCurrentSceneUrl()

    local background = display.newRect( sceneGroup, display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )

    

    --: load the navbar
    local basic_navbar = worona.ui:newBasicNavBar({
     parent            = sceneGroup,
     text              = string.match( url, "^https?://w?w?w?%.?([a-zA-Z0-9-]+%.%a+)" ),
     left_button_icon  = worona.style:get("icons").back_left
    })

    worona:do_action( "after_creating_scene_webview", params ) 
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

          if system.getInfo("platformName") == "Win" then
            rectangle = display.newRect( sceneGroup, display.contentWidth / 2, style.y, display.contentWidth, style.height  )
            rectangle:setFillColor( 0.5 )

            local text = display.newText( {
              parent   = sceneGroup,
              text     = "Everything is working fine, but...\n\nThe post view is not supported by Corona Simulator in Windows.\n\nYou must build your app for Android (File -> Build for Android, or Ctrl + B), or run Corona Simulator in MacOS to be able to see your posts.\n\nFor more info, please visit: http://docs.coronalabs.com/guide/distribution/androidBuild/index.html",
              x        = display.contentWidth / 2,
              y        = 250,
              width    = display.contentWidth - 20 ,     --required for multi-line and alignment
              font     = native.systemFontBold,
              fontSize = 18,
              align    = "center"  --new alignment parameter
            } )
            text:setFillColor( 1, 1, 1 )
          else
            
            webview = native.newWebView( display.contentWidth / 2, style.y, display.contentWidth, style.height )
            webview:request( url or "about:blank" )

            webview:addEventListener( "urlRequest", webListener )
          end

          worona:add_action( "navbar_left_button_pushed", left_button_handler )
          worona:add_action( "android_back_button_pushed", left_button_handler )

          scene_on_screen = true

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

        scene_on_screen = false

        worona:remove_action( "navbar_left_button_pushed", left_button_handler )
        worona:remove_action( "android_back_button_pushed", left_button_handler )

       elseif ( phase == "did" ) then
          -- Called immediately after scene goes off screen.
          if webview ~= nil then
    				webview:request( "about:blank" )
    				webview:stop()
    				timer.performWithDelay( 1000, function()
    					if scene_on_screen ~= true then
    						display.remove( webview )
    						webview = nil
    					end
    				end )
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