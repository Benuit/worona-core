local blood  = require "blood"
local widget = require "widget"

local theme          = "ios7"
local extensions_folder = "extensions.scene-post."
local images_folder  = "themes/" .. theme .. "/scene-post/"

local page = {
   	page_type = "scene-post",
   	page_creator = function( page_name )

    local blood    = require "blood"
    local composer = require "composer"
    local scene    = composer.newScene( page_name )

    -- -----------------------------------------------------------------------------------------------------------------
    -- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
    -- -----------------------------------------------------------------------------------------------------------------

    -- local forward references should go here
    ---------------------------------------------------------------------------------


      -- "scene:create()"
    function scene:create( event )

        local sceneGroup = self.view

        -- Initialize the scene here.
        -- Example: add display objects to "sceneGroup", add touch listeners, etc.
      
        local background = display.newImageRect( sceneGroup, images_folder .. "scene-postBG.png", SCREENWIDTH, SCREENWIDTH/320*570 )
        background.x = display.contentWidth / 2
        background.y = display.contentHeight / 2

        local content = blood.content:getPage( "scene-post", event.params.page_id )
        local pagetitle
        
        if content == nil or content.pagetitle == nil then
           	pagetitle = "Failed to Load"
        else
            	pagetitle = content.pagetitle
        end

        blood:do_action( "add_navbar", { text = pagetitle, parent = sceneGroup } )

        local createScrollview = require( extensions_folder .. "scrollview" )
        local scrollView = createScrollview( { parent = sceneGroup } )

        if content == nil then
            local createSubtitle = require( extensions_folder .. "subtitle" )
            createSubtitle( { text = "Sorry, this page doesn't exist", size = 16, actual_y = 0, parent = scrollView } )
        elseif content.scene-post == nil  or content.scene-post == false then
            local createSubtitle = require( extensions_folder .. "subtitle" )
            createSubtitle( { text = "Sorry, this page is empty", size = 16, actual_y = 0, parent = scrollView } )
        else
            for i = 1, #content.scene-post do
                              
	          	local field    = content.scene-post[i]
	           	field.parent   = scrollView

	           	if i == 1 then
	            	field.actual_y = 0
	           	else
	              	field.actual_y = content.scene-post[ i - 1 ].actual_y
	           	end
	           
	           	if field.acf_fc_layout == "subtitle" then
	              	local createSubtitle = require( extensions_folder .. "subtitle" )
	              	createSubtitle( field )
	           	elseif field.acf_fc_layout == "paragraph" then
	              	local createParagraph = require( extensions_folder .. "paragraph" )
	              	createParagraph( field )
	           	elseif field.acf_fc_layout == "image" then
	              	local createImage = require( extensions_folder .. "image" )
	              	createImage( field )
	           	elseif field.acf_fc_layout == "button" then
	              	local createButton = require( extensions_folder .. "button" )
	              	createButton( field )
               elseif field.acf_fc_layout == "list" then
                  local createList = require( extensions_folder .. "list" )
                  createList( field )
	           	elseif field.acf_fc_layout == "gallery" then
	           	   	local createGallery = require( extensions_folder .. "gallery" )
	           	   	createGallery( field )
              elseif field.acf_fc_layout == "map" then
                local createMap = require ( extensions_folder .. "map")
                createMap( field )
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

            blood:do_action( "add_tabbar", { parent = sceneGroup } )

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
}

blood:do_action( "register_page", page )