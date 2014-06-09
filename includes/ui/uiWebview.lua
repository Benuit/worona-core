-- UI: uiExample   
local uiWebview = {}

function uiWebview : new( bloodGroup )

	--. DEFAULT VALUES .--
	-- wv : webView
	-- bb : bottonBar
	-- nv : navBar
	-- butB : ButtonB
	local val = {
		url      = "http://www.google.com",
		title    = "",
	
		x        = 0,
		y        = display.topStatusBarContentHeight,
		width    = display.contentWidth,
		height   = display.contentHeight - 70,
	
		nvHeight                 = 40,
		nvBgImageMiddle          = "webviewTabBarBg.png",
		nvBackButtonY            = 0,
		nvBackButtonX            = 0,
		nvBackButtonHeight       = 40,
		nvBackButtonWidth        = 40,
		nvBackButtonDefaultImage = "webviewBackButtonDefault.png",
		nvBackButtonOverImage    = "webviewBackButtonOver.png",
	
		bbHeight = 40,
    	bbRed    = 0.203125,
    	bbGreen  = 0.59375,
    	bbBlue   = 0.85546875,
    	bbAlpha  = 1 ,

    	link             = function () print(" the Event Handler will overwrite this function ") end,

    	butBDefaultImage = "webViewBottonBack.png",
    	butBOverImage    = "webViewBottonBackOver.png",
    	butBWidth        = 40,
    	butBHeigth       = 40,


    	butFDefaultImage = "webViewBottonForward.png",
    	butFOverImage    = "webViewBottonForwardOver.png",
    	butFWidth        = 40,
    	butFHeigth       = 40
    }
	val.butBLeft         = 	val.width * 0.30
	val.butBTop          = 	val.bbTop 
	val.butFLeft         = 	val.width * 0.60
	val.butFTop          = 	val.bbTop 
	--. END OF DEFAULT VALUES .--


	local this = uUI:new( "uiWebview", bloodGroup )

	-- creates the display object
	local webview 
	local navBar 	= this.blood:getInjection( this, "uiNavBar" )
	local bottomBar

	local BackgroundGroup = display.newGroup()
	local FrontGroup      = display.newGroup()

	--local buttonF	= this.blod:getInjection( this, "uiButton" )-- 
	-- sets the name for this class
	this.classType = "uiWebview"
	-- gets the unique ID
	this.ID = getID()



    
    local buttonB	= this.blood:getInjection( this, "uiButton" )
    local buttonF	= this.blood:getInjection( this, "uiButton" )

    
	-- init
	function this:addEventHandler( type, func )
		if type == "touch" then
			val.link = func
		else
			log:warning( "uiNavBar: Only touch handlers are allowed. Do not use `" .. type .. "`" )
		end
	end

	function this:removeTexture()

		-- display.remove(webview)
		-- webview = nil
		navBar:removeTexture()
		buttonB:removeTexture()
		buttonF:removeTexture()
		display.remove(bottomBar)
		bottomBar = nil
		if webview ~= nil then 
			webview:request( "about:blank" ) 
			webview:stop()
		end
		webview.x = display.contentWidth
		timer.performWithDelay( 1000, 	function()
											display.remove( webview )
										end )
		
	end

	local function webListener( event )
	    if event.url then
	        val.title = event.url 
	    end
	end

	function this:refresh ()

		native.setActivityIndicator(true)

		timer.performWithDelay( 50,
		    function()
				

				local deviceUtils = require "worona.lib.utils.deviceUtils"
				local device = deviceUtils:getDevice()

				-- webview.alpha = 0.9
				-- webview.alpha = 1.0

				local _wvX      = val.x
				local _wvY      = val.y + val.nvHeight
				local _wvWidth  = val.width
				local _wvHeight = val.height - val.nvHeight - val.bbHeight + 1

				if webview == nil then webview = native.newWebView( _wvX, _wvY, _wvWidth, _wvHeight ) end
				webview.anchorX, webview.anchorY = 0, 0
				webview.x = _wvX
				webview:request( val.url )
						    	
		    	
		    	bottomBar = display.newRect( val.x, val.y + val.height, val.width, val.bbHeight)
		    	bottomBar.anchorX, bottomBar.anchorY = 0, 1
				bottomBar:setFillColor(val.bbRed, val.bbGreen, val.bbBlue, val.bbAlpha)
				bottomBar:addEventListener( "touch", function() return true end )
				BackgroundGroup:insert( bottomBar )

				navBar:setText(val.title)
				navBar:addEventHandler("touch",val.link)
				
				navBar:setBgImageRight( false )
				navBar:setBgImageLeft( false )
				navBar:setBgImageMiddle( val.nvBgImageMiddle )
				navBar:setBgImageRightWidth( 0 )
				navBar:setBgImageLeftWidth( 0 )
				navBar:setBgImageMiddleWidth( display.contentWidth )
				navBar:setBackButtonDefaultImage( val.nvBackButtonDefaultImage )
				navBar:setBackButtonOverImage( val.nvBackButtonOverImage )
				navBar:setBackButtonHeight( val.nvHeight )
				navBar:setBackButtonWidth( val.nvHeight )
				navBar:setBackButtonX( val.nvBackButtonX )
				navBar:setBackButtonY( val.nvBackButtonY )
				navBar:setTextX(50)
				navBar:setY(val.y)
				navBar:setX(val.x)
				navBar:setHeight(val.nvHeight)

				navBar:refresh()
				
				
				buttonB:setX(val.butBLeft)
				buttonB:setY(val.y + val.height - val.bbHeight, val.width, val.bbHeight)
				buttonB:setWidth(val.butBWidth)
				buttonB:setHeight(val.butBHeigth)
				buttonB:setDefaultImage(val.butBDefaultImage)
				buttonB:setOverImage(val.butBOverImage)
				buttonB:addEventHandler("touch", 	function (event)
														if event.phase == "ended" then
															webview:back()
														end
														return true
													end) -- ontouch -> webview:back()
				buttonB:setLabel("")
				buttonB:refresh()
				FrontGroup:insert(buttonB)

				buttonF:setX(val.butFLeft)
				buttonF:setY(val.y + val.height - val.bbHeight, val.width, val.bbHeight)
				buttonF:setWidth(val.butFWidth)
				buttonF:setHeight(val.butFHeigth)
				buttonF:setDefaultImage(val.butFDefaultImage)
				buttonF:setOverImage(val.butFOverImage)
				buttonF:addEventHandler("touch",	function (event)
														if event.phase == "ended" then
															webview:forward()
														end
														return true
													end) -- ontouch -> webview:back()
				buttonF:setLabel("")
				buttonF:refresh()
				FrontGroup:insert(buttonF)

				native.setActivityIndicator(false)
		    end
		)

		
		
	end

	local init = function()
		--this:refresh()
	end

	function this:setUrl(url)
		val.url = url
	end

	function this:setX ( x )
		val.x = x
	end

	function this:setY ( y )
		val.y = y
	end

	function this:setWidth ( width )
		val.width = width
	end

	function this:setHeight ( height )
		val.height = height
	end

	function this:getHeight()
		return val.height
	end

	function this:setNavBarHeight( newNavBarHeight )
		val.nvHeight = newNavBarHeight
	end

	function this:getNavBarHeight()
		return val.nvHeight
	end

	function this:setNavBarBgImageMiddle( image )
		val.nvBgImageMiddle = image
	end

	function this:getNavBarBgImageMiddle()
		return val.nvBgImageMiddle
	end

	function this:setNavBarBackButtonY( y )
		val.nvBackButtonY = y
	end

	function this:getNavBarBackButtonY()
		return val.nvBackButtonY
	end

	function this:setNavBarBackButtonX( x )
		val.nvBackButtonX = x
	end

	function this:getNavBarBackButtonX()
		return val.nvBackButtonX
	end

	function this:setNavBarBackButtonHeight( height )
		val.nvBackButtonHeight = height
	end

	function this:getNavBarBackButtonHeight()
		return val.nvBackButtonHeight
	end

	function this:setNavBarBackButtonWidth( width )
		val.nvBackButtonWidth = width
	end

	function this:getNavBarBackButtonWidth()
		return val.nvBackButtonHeight
	end

	function this:setNavBarBackButtonDefaultImage( image )
		val.nvBackButtonDefaultImage = image
	end

	function this:getNavBarBackButtonDefaultImage()
		return val.nvBackButtonDefaultImage
	end

	function this:setNavBarBackButtonOverImage( image )
		val.nvBackButtonOverImage = image
	end

	function this:getNavBarBackButtonOverImage()
		return val.nvBackButtonOverImage
	end

	function this:setTitle ( title )
		val.title = title
	end

	init()

	return this

end

return uiWebview 
 