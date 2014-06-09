local worona = require "worona"

local function newScene( scene_name )

   local buttons = {
      { label = "Guía",          action = "load_page", page_type = "customcontent", page_id = 4911 },
      { label = "De Fiesta",     action = "load_page", page_type = "customcontent", page_id = 4831 },
      { label = "Dónde Comer",   action = "load_page", page_type = "customcontent", page_id = 4861 },
      { label = "De Compras",    action = "load_page", page_type = "customcontent", page_id = 5841 },
      { label = "Dónde Dormir",  action = "load_webview", websitetitle = "Google.es/", websiteurl = "http://www.google.es/" }
   }

   local composer      = require "composer"
   local scene         = composer.newScene( scene_name )
   local style         = worona.style:get("welcomescreen")

   -- -----------------------------------------------------------------------------------------------------------------
   -- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
   -- -----------------------------------------------------------------------------------------------------------------


   -- "scene:create()"
   function scene:create( event )

      local sceneGroup = self.view

      -- Initialize the scene here.
      -- Example: add display objects to "sceneGroup", add touch listeners, etc.
      
      --: onRelease function
      local function onRelease( i )
         return function()
            worona:do_action( buttons[i].action, buttons[i] )
         end
      end

      --: BACKGROUND
      local background = display.newImageRect( sceneGroup, style.background.image, display.contentWidth, display.contentHeight )
      background.x, background.y = display.contentWidth/2, display.contentHeight/2

      --: TITLE
      local text_options = {  parent   = sceneGroup,
                              text     = event.params.title,
                              x        = display.contentWidth/2,
                              y        = display.contentCenterY - 170,
                              align    = "center",
                              fontSize = style.title.fontSize or 40,
                              width    = display.contentWidth,
                              font     = style.title.font or native.systemFont
                           }
      local text = display.newText( text_options )

      --: BUTTONS
      local widget = require "widget"
      local button_options = {   big_button_default_image   = style.big_button.image.default,
                                 big_button_over_image      = style.big_button.image.over,
                                 big_button_width           = style.big_button.width,
                                 big_button_height          = style.big_button.height,
                                 big_button_label_size      = style.big_button.size or 30,
                                 big_button_font            = style.big_button.font or native.systemFont,
                                 small_button_default_image = style.small_button.image.default,
                                 small_button_over_image    = style.small_button.image.over,
                                 small_button_width         = style.small_button.width,
                                 small_button_height        = style.small_button.height,
                                 small_button_label_size    = style.small_button.fontSize or 16,
                                 small_button_font          = style.small_button.font or native.systemFont,
                                 small_button_top_gap       = 25,
                                 small_button_bottom_gap    = 25,
                                 height_content_factor      = 250,
                              }
      button_options.small_button_bottom_y = display.contentCenterY + button_options.height_content_factor - button_options.small_button_bottom_gap - button_options.small_button_height
      button_options.small_button_top_y    = display.contentCenterY + button_options.height_content_factor - button_options.small_button_bottom_gap - button_options.small_button_height - button_options.small_button_top_gap - button_options.small_button_height

      local bigButton_options = {   label       = buttons[1].label,
                                    fontSize    = button_options.big_button_label_size,
                                    labelColor  = style.big_button.color,
                                    defaultFile = button_options.big_button_default_image,
                                    overFile    = button_options.big_button_over_image,
                                    width       = button_options.big_button_width,
                                    height      = button_options.big_button_height,
                                    x           = display.contentWidth / 2,
                                    y           = display.contentCenterY + button_options.height_content_factor - button_options.small_button_bottom_gap - button_options.small_button_height - button_options.small_button_top_gap - button_options.small_button_height - button_options.small_button_top_gap - 90,
                                    font        = button_options.big_button_font,
                                    onRelease   = onRelease( 1 )
                                 }

      local bigButton = widget.newButton( bigButton_options )
      sceneGroup:insert( bigButton )

      button_options.small_button_left_x  = ( display.contentWidth - button_options.big_button_width + button_options.small_button_width ) / 2
      button_options.small_button_right_x = ( display.contentWidth - ( display.contentWidth - button_options.big_button_width ) / 2 - button_options.small_button_width ) + button_options.small_button_width / 2

      local smallButtons = {}

      --: Small button 1
      local smallButtons_options = {   label       = buttons[2].label,
                                       fontSize    = button_options.small_button_label_size,
                                       labelColor  = style.small_button.color,
                                       defaultFile = button_options.small_button_default_image,
                                       overFile    = button_options.small_button_over_image,
                                       width       = button_options.small_button_width,
                                       height      = button_options.small_button_height,
                                       y           = button_options.small_button_top_y,
                                       x           = button_options.small_button_left_x,
                                       font        = button_options.small_button_font,
                                       onRelease   = onRelease( 2 )
                                 }

      smallButtons[1] = widget.newButton( smallButtons_options )
      sceneGroup:insert( smallButtons[1] )


      --: Small button 2
      smallButtons_options.label = buttons[3].label
      smallButtons_options.y     = button_options.small_button_top_y
      smallButtons_options.x     = button_options.small_button_right_x
      smallButtons_options.onRelease     = onRelease( 3 )

      smallButtons[2] = widget.newButton( smallButtons_options )
      sceneGroup:insert( smallButtons[2] )


      --: Small button 3
      smallButtons_options.label = buttons[4].label
      smallButtons_options.y     = button_options.small_button_bottom_y
      smallButtons_options.x     = button_options.small_button_left_x
      smallButtons_options.onRelease     = onRelease( 4 )

      smallButtons[3] = widget.newButton( smallButtons_options )
      sceneGroup:insert( smallButtons[3] )

      --: Small button 4
      smallButtons_options.label = buttons[5].label
      smallButtons_options.y     = button_options.small_button_bottom_y
      smallButtons_options.x     = button_options.small_button_right_x
      smallButtons_options.onRelease     = onRelease( 5 )

      smallButtons[4] = widget.newButton( smallButtons_options )
      sceneGroup:insert( smallButtons[4] )

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

return newScene