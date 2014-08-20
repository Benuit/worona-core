local worona = require "worona"

local function newWebviewScene( scene_name )

  local composer = require "composer"
  local htmlRender = require "worona.includes.scene-post.html-render"
  local webview, params, content
  local scene = composer.newScene( scene_name )

    -- -----------------------------------------------------------------------------------------------------------------
    -- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
    -- -----------------------------------------------------------------------------------------------------------------

    -- "scene:create()"
  function scene:create( event )

       local sceneGroup = self.view

       local background = display.newRect( sceneGroup, display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )

       params  = event.params
       content = worona.content:getPost( "post", params.url )

       htmlRender:createFolders()
       htmlRender:copyFiles()
       htmlRender:copyHtml( content.worona_content.html )

       worona:do_action( "before_creating_scene", params )

       -- Initialize the scene here.
       -- Example: add display objects to "sceneGroup", add touch listeners, etc.

       

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
          webview:request( "content/html/index.html", system.DocumentsDirectory )

          local function webListener( event )
              if event.url then
                  print( "You are visiting: " .. event.url )
                  if event.url == "file:///historia" then
                    print( "GOING TO A NEW HTML")
                    webview:request( "about:blank" ) 
                    webview:stop()
                    webview:request( "html2/historia.html", system.ResourceDirectory )
                  end
              end

              if event.type then
                  print( "The event.type is " .. event.type ) -- print the type of request
              end

              if event.errorCode then
                  --native.showAlert( "Error!", event.errorMessage, { "OK" } )
              end
          end

          webview:addEventListener( "urlRequest", webListener )
          
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

       elseif ( phase == "did" ) then
          -- Called immediately after scene goes off screen.
          if webview ~= nil then 
            webview:request( "about:blank" ) 
            webview:stop()
            timer.performWithDelay( 1000,   function() display.remove( webview ) end )
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
worona:do_action( "register_scene", { scene = "post", creator = newWebviewScene } )