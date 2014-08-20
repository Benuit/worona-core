local worona = require "worona"

local function newNativeScene( scene_name )

    local composer = require "composer"
    local scene    = composer.newScene( scene_name )

    local plugins_folder = "worona.includes.scene-post.content-blocks."

    -- -----------------------------------------------------------------------------------------------------------------
    -- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
    -- -----------------------------------------------------------------------------------------------------------------

    -- local forward references should go here
    ---------------------------------------------------------------------------------


      -- "scene:create()"
    function scene:create( event )

        local sceneGroup = self.view

        local style = worona.style:get("post")
        
        -- Initialize the scene here.
        -- Example: add display objects to "sceneGroup", add touch listeners, etc.
      
        local background = display.newImageRect( sceneGroup, style.background.image, SCREENWIDTH, SCREENWIDTH/320*570 )
        background.x = display.contentWidth / 2
        background.y = display.contentHeight / 2

        local content = worona.content:getPost( "post", event.params.url )
        local pagetitle
        
        if content == nil or content.title == nil then
           	pagetitle = "Failed to Load"
        else
            pagetitle = content.title
        end

        worona:do_action( "before_creating_scene", { pagetitle = pagetitle, sceneGroup = sceneGroup } )

        local createScrollview = require( plugins_folder .. "scrollview" )
        local scrollView = createScrollview( { parent = sceneGroup } )

        if content == nil then
            local createSubtitle = require( plugins_folder .. "subtitle" )
            createSubtitle( { text = "Sorry, this page doesn't exist", size = 16, actual_y = 0, parent = scrollView } )
        elseif content.worona_content.post == nil  or content.worona_content.post == false then
            local createSubtitle = require( plugins_folder .. "subtitle" )
            createSubtitle( { text = "Sorry, this page is empty", size = 16, actual_y = 0, parent = scrollView } )
        else
            for i = 1, #content.worona_content.post do
                              
	          	local field    = content.worona_content.post[i]
	           	field.parent   = scrollView

	           	if i == 1 then
	            	  field.actual_y = 0
	           	else
	              	field.actual_y = content.worona_content.post[ i - 1 ].actual_y
	           	end
	           
	           	if field.type == "subtitle" then
	              	local createSubtitle = require( plugins_folder .. "subtitle" )
	              	createSubtitle( field )
	           	elseif field.type == "paragraph" then
	              	local createParagraph = require( plugins_folder .. "paragraph" )
	              	createParagraph( field )
	           	elseif field.type == "image" then
	              	local createImage = require( plugins_folder .. "image" )
	              	createImage( field )
	           	-- elseif field.type == "button" then
	            --   	local createButton = require( plugins_folder .. "button" )
	            --   	createButton( field )
             --   elseif field.type == "list" then
             --      local createList = require( plugins_folder .. "list" )
             --      createList( field )
	           	-- elseif field.type == "gallery" then
	           	--    	local createGallery = require( plugins_folder .. "gallery" )
	           	--    	createGallery( field )
             --  elseif field.type == "map" then
             --    local createMap = require ( plugins_folder .. "map")
             --    createMap( field )
	           	end
	      
            end
         end

      end

      -- "scene:show()"
      function scene:show( event )

         local sceneGroup = self.view
         local phase = event.phase

         if ( phase == "will" ) then
            -- Called when the scene is still off screen (but is about to come on screen).

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

local function newWebviewScene( scene_name )

  local composer = require "composer"
  local webview, params
  local scene = composer.newScene( scene_name )

    -- -----------------------------------------------------------------------------------------------------------------
    -- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
    -- -----------------------------------------------------------------------------------------------------------------

    -- "scene:create()"
  function scene:create( event )

       local sceneGroup = self.view

       local background = display.newRect( sceneGroup, display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )

       params            = event.params
       params.sceneGroup = sceneGroup
       params.pagetitle  = params.websitetitle


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
          webview:request( "html/tmp.html", system.ResourceDirectory )

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