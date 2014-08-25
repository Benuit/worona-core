local worona = require "worona"

local function newPostScene( scene_name )

  local composer = require "composer"
  local scene    = composer.newScene( scene_name )

  --: private variables
  local webview, content, url
  local postHtmlRender = require "worona.includes.scene-post.html-render"

    -- -----------------------------------------------------------------------------------------------------------------
    -- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
    -- -----------------------------------------------------------------------------------------------------------------

  local function left_button_handler()
    worona:do_action( "load_previous_scene", { effect = "slideRight", time = 200 } )
  end

    -- "scene:create()"
  function scene:create( event )

       worona:do_action( "before_creating_scene" )

       local sceneGroup = self.view

       local background = display.newRect( sceneGroup, display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )

       url     = worona.scene:getCurrentSceneUrl()
       content = worona.content:getPost( "post", url )

       postHtmlRender:prepareHtmlFile( { name = content.slug, html = content.worona_content.html } )

       --: load the navbar
       local basic_navbar = worona.ui:newBasicNavBar({
        parent            = sceneGroup,
        text              = content.title,
        left_button_icon  = worona.style:get("icons").back
       })

       worona:do_action( "after_creating_scene" )
  end

    -- "scene:show()"
  function scene:show( event )

       local sceneGroup = self.view
       local phase = event.phase

       if ( phase == "will" ) then
          -- Called when the scene is still off screen (but is about to come on screen).
          

       elseif ( phase == "did" ) then
          
          -- Called when the scene is now on screen.

          --: personalise behavior of navbar
          worona:add_action( "navbar_left_button_pushed", left_button_handler )

          local style = worona.style:get( "webview" )
          webview = native.newWebView( display.contentWidth / 2, style.y, display.contentWidth, style.height )
          webview:request( "content/html/" .. content.slug .. ".html", system.DocumentsDirectory )

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

          --: personalise behavior of navbar
          worona:remove_action( "navbar_left_button_pushed", left_button_handler )

          --: move webview out of the screen
          if webview ~= nil then 
              webview.x = display.contentWidth * 2
          end

       elseif ( phase == "did" ) then
          -- Called immediately after scene goes off screen.
          if webview ~= nil then 
            webview:request( "about:blank" ) 
            webview:stop()
            timer.performWithDelay( 100,   function() display.remove( webview ); webview = nil end )
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
worona:do_action( "register_scene", { scene_type = "post", creator = newPostScene } )