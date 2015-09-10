local worona = require "worona"

local function newPostScene( scene_name )

	local composer = require "composer"
	local scene    = composer.newScene( scene_name )

	--: private variables
	local webview, content, url, scene_on_screen, basic_navbar
	local postHtmlRender = require "worona-core.includes.scene-post.html-render"

	local function androidListener( event )
		if event.type == "link" then
			worona.log:info( "html_server: We are on Android and user clicked on a link with url '" .. event.url .. "'" )
			worona:do_action( "load_url", { url = event.url } )
		end
	end

	-- -----------------------------------------------------------------------------------------------------------------
	-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
	-- -----------------------------------------------------------------------------------------------------------------

	local function leftButtonHandler()
		worona:do_action( "load_previous_scene", { effect = "slideRight", time = 200 } )
	end

	local function rightButtonHandler()

		worona.favorite:addOrRemoveFavorite( { post_id = content.ID } )

		if worona.favorite:isFavorite( { post_id = content.ID } ) == true then
			basic_navbar:replaceButton( "right", worona.style:get("icons").is_favorite )
		else
			basic_navbar:replaceButton( "right", worona.style:get("icons").favorite )
		end
	end

	-- "scene:create()"
	function scene:create( event )

		worona:do_action( "before_creating_scene_post" )

		local sceneGroup = self.view

		local background = display.newRect( sceneGroup, display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight )

		--
		url     = worona.scene:getCurrentSceneUrl()
		content = worona.content:getPost( worona.content_type, url )

		postHtmlRender:prepareHtmlFile( { name = content.slug, html = content.content, featured_image = content.featured_image } )

		local unescaped_title = worona.string:unescape(content.title)
		local favorite_icon   = worona:do_filter( "filter_navbar_favorite_icon", "favorite", { post_id = content.ID } )
		--: load the navbar
		basic_navbar = worona.ui:newBasicNavBar({
			parent            = sceneGroup,
			text              = unescaped_title,
			left_button_icon  = worona.style:get("icons").back_left,
			right_button_icon = worona.style:get("icons")[favorite_icon]
		})

		worona:do_action( "after_creating_scene_post", { sceneGroup = sceneGroup, post_url = url, post_title = unescaped_title } )
	end

	-- "scene:show()"
	function scene:show( event )

		local sceneGroup = self.view
		local phase = event.phase

		if ( phase == "will" ) then
			-- Called when the scene is still off screen (but is about to come on screen).
		  	worona:do_action( "on_scene_post_show_will", { sceneGroup = sceneGroup } )

		elseif ( phase == "did" ) then

		    -- Called when the scene is now on screen.

		    --: personalise behavior of navbar
			worona:add_action("navbar_right_button_pushed", rightButtonHandler)
			worona:add_action( "navbar_left_button_pushed", leftButtonHandler )
		  	worona:add_action( "android_back_button_pushed", leftButtonHandler )

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
			    local webview_height = worona:do_filter( "filter_scene_post_webview_height", style.height )
			    local webview_y      = worona:do_filter( "filter_scene_post_webview_y", style.y )

			    webview = native.newWebView( display.contentWidth / 2, webview_y, display.contentWidth, webview_height )

		    	worona:do_action( "on_scene_post_webview_creation" )

		    	if worona.device:getPlatformName() == "Android" then
		      		webview:request( "content/html/" .. content.slug .. ".html", system.CachesDirectory )
		      		webview:addEventListener( "urlRequest", androidListener )
		    	else
		      	webview:request( "http://localhost:1024?render=" .. content.slug )
		    	end
		  	end

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

		  --: personalise behavior of navbar
		  worona:remove_action( "navbar_right_button_pushed", rightButtonHandler )
		  worona:remove_action( "navbar_left_button_pushed", leftButtonHandler )
		  worona:remove_action( "android_back_button_pushed", leftButtonHandler )

		  --: move webview out of the screen
		  if webview ~= nil then
		      webview.x = display.contentWidth * 2
		  end

		  scene_on_screen = false

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
worona:do_action( "register_scene", { scene_type = "post", creator = newPostScene } )
