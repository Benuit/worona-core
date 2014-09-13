-- UI: uiMap   
uiMap = {}

function uiMap:new( bloodGroup )

	local deviceUtils = require "worona.lib.utils.deviceUtils"
	local statusBarHeight = deviceUtils:getSetting( { ios7 = 0, default = display.topStatusBarContentHeight } )

	--. DEFAULT VALUES .--
	local val = {
		width               = display.contentWidth,
		height              = display.contentHeight - statusBarHeight - UDEF.NAVBAR_HEIGHT,
		x                   = 0,
		y                   = statusBarHeight + UDEF.NAVBAR_HEIGHT,
		anchorX             = 0,
		anchorY             = 0,
		alpha               = 1,
		isScrollEnabled     = true,
		isZoomEnabled       = true,
		mapType             = "standard",
		markersList         = {},
		centerLatitude      = 0,
		centerLongitude     = 0,
		regionLatitude      = 0,
		regionLongitude     = 0,
		regionLatitudeSpan  = 0,
		regionLongitudeSpan = 0,
		isAminated          = true,
		allowMarkerTitle    = true,
		allowMarkerSubtitle = true
	}

	-- creates the display object

	local this = uUI:new( "uiMap", bloodGroup )

	

	local navBar = this.blood:getInjection( this, "uiNavBar" )

	local map 	--. the actual map .--

	local eventBlackHole  --. A rectangle that makes other layers under the map stop listening to touch events .--

	local environment = system.getInfo( "environment" )  --. Get where the app is being executed (simulator or device) .--

	--. Map adress handler and user location values .--
	local _mapNearestAddress   = {}
	local _userLocation        = {}

	--. NavBar default values .--
	local _navBarText = "Mapa"
	local _navBarHeight = UDEF.NAVBAR_HEIGHT

	
	--. private functions .--
	
	local function markerCoordinatesHandler( event )
	    -- handle mapLocation event here

	    log:debug(event.errorMessage)
	    log:debug(event.isError)
	    log:debug(event.name)
	    log:debug(event.latitude)
	    log:debug(event.longitude)

	    if event.isError ~= nil then
	    	log:error("uiMap/markerCoordinatesHandler: " .. event.errorMessage)
	    else
	    	log:warning("uiMap/markerCoordinatesHandler: function not programmed yet. Please insert marker by its COORDINATES or program functionality with an array of functions (ask Luis)")
		end
	end

	local function parseMarkers( )
		for i=1, #val.markersList, 1 do
			if val.markersList[i].latitude ~= nil and val.markersList[i].longitude ~= nil then
				if val.allowMarkerTitle == true then
					if val.allowMarkerSubtitle == true then
						map:addMarker( val.markersList[i].latitude , val.markersList[i].longitude, {title = val.markersList[i].title, subtitle = val.markersList[i].subtitle } )
					else
						map:addMarker( val.markersList[i].latitude , val.markersList[i].longitude, {title = val.markersList[i].title} )
					end
				else
					map:addMarker( val.markersList[i].latitude , val.markersList[i].longitude )
				end

			elseif val.markersList[i].address ~= nil then
				map:requestLocation(val.markersList[i].address, markerCoordinatesHandler)
			else
				log:error("uiMap/parseMarkers: val.markersList['" .. i .. "'] is not a valid marker value.")
			end
		end
	end

	local function mapNearestAddressHandler( event )
	    -- handle mapAddress event here
	    _mapNearestAddress.city         = event.city
	    _mapNearestAddress.cityDetail   = event.cityDetail
	    _mapNearestAddress.countryCode  = event.countryCode
	    _mapNearestAddress.country      = event.country
	    _mapNearestAddress.errorMessage = event.errorMessage
	    _mapNearestAddress.isError      = event.isError
	    _mapNearestAddress.name         = event.name
	    _mapNearestAddress.postalCode   = event.postalCode
	    _mapNearestAddress.region       = event.region
	    _mapNearestAddress.regionDetail = event.regionDetail
	    _mapNearestAddress.street       = event.street
	    _mapNearestAddress.streetDetail = event.streetDetail
	end

	local function stopListeningToEventsUnderMap( )
		eventBlackHole = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
		eventBlackHole:addEventListener("touch", function() return true end)
	end

	

	-- methods
	
	function this:refresh()

		this:removeTexture()

		stopListeningToEventsUnderMap()

		if environment == "simulator" then
			map = display.newRect( val.x, val.y, val.width, val.height )
		    map:setFillColor(0.5, 0.5, 0.5)
		else
			--. all the methods that can only be applied to the mapView .--
			map = native.newMapView( val.x, val.y, val.width, val.height )
			if map ~= nil then
				map.isScrollEnabled     = this:getIsScrollEnabled()
				map.isZoomEnabled       = this:getIsZoomEnabled()
				map.mapType             = this:getMapType()
				
				if val.regionLatitudeSpan ~= 0 or val.regionLongitudeSpan ~= 0 then
					map:setRegion(val.regionLatitude, val.regionLongitude, val.regionLatitudeSpan, val.regionLongitudeSpan, val.isAminated)
				else
					map:setCenter(val.centerLatitude, val.centerLongitude, val.isAminated)
				end

				--. Aondroid devices need a delay before drawing the markers. .--
				local platform = deviceUtils:getPlatformName()
				if platform == "Android" then
					timer.performWithDelay( 500, parseMarkers )
				else
					parseMarkers()
				end

			end
		end
		
		if map ~= nil then
			--. methods that can be applied to mapView and newRect .--
			map.anchorX = val.anchorX
			map.anchorY = val.anchorY
			map.alpha   = val.alpha
		else
			log:error("uiMap/refresh: map = nil")
		end

		--. navBar .--
		navBar:setText(_navBarText)
		navBar:setBgImageRight( false )
		navBar:setBgImageLeft( false )
		navBar:setBgImageMiddle( "navBarBg.png" )
		navBar:setBgImageRightWidth( 0 )
		navBar:setBgImageLeftWidth( 0 )
		navBar:setBgImageMiddleWidth( display.contentWidth )
		navBar:setBackButtonDefaultImage( "navBarButtonDefault.png" )
		navBar:setBackButtonOverImage( "navBarButtonOver.png" )
		navBar:setBackButtonHeight( 68 )
		navBar:setBackButtonWidth( 68 )
		navBar:setTextX(50)	
		navBar:refresh()
	end

	function this:removeTexture()
		if eventBlackHole ~= nil then
			eventBlackHole:removeSelf()
			eventBlackHole = nil
		end
		if map ~= nil then
			map:removeSelf()
			map = nil
			if navBar ~= nil then
				navBar:removeTexture()
				navBar = nil
				return true
			end
		end
		return UDEF.ERROR_CODE
	end


	--. HANDLERS .--

	function this:addBackButtonEventHandler( type, func )
		if type == "touch" then
			navBar:addEventHandler(type, func)
			navBar:refresh()
		else
			log:warning( "uiNavBar: Only touch handlers are allowed. Do not use `" .. type .. "`" )
		end
	end


	--. SETTERS .--

	function this:setMapTitle ( newValue )
		_navBarText = newValue
	end

	function this:setAllowMarkerTitle ( newValue )
		val.allowMarkerTitle = newValue
	end

	function this:setAllowMarkerSubtitle ( newValue )
		if newValue == true then
			val.allowMarkerSubtitle = true
			val.allowMarkerTitle = true
		else
			val.allowMarkerSubtitle = false
		end
	end

	function this:setWidth ( newWidth )
		val.width = newWidth
	end

	function this:setHeight ( newHeight )
		val.height = newHeight
	end

	function this:setAlpha ( newAlpha )
		if newAlpha >= 0 and newAlpha <= 1 then
			val.alpha = newAlpha
		else
			log:warning("Alpha value must be in the range [0 , 1]")
		end
	end

	function this:setX ( newX )
		val.x = newX
	end

	function this:setY ( newY )
		val.y = newY
	end

	function this:setRP ( anchorX, anchorY )
		this:setAnchorX( anchorX )
		this:setAnchorY( anchorY )
	end

	function this:getRP()
		return this:getAnchorX(), this:getAnchorY()
	end

	function this:setAnchorX( anchorX )
		val.anchorX = anchorX
	end

	function this:getAnchorX()
		return val.anchorX
	end

	function this:setAnchorY( anchorY )
		val.anchorY = anchorY
	end

	function this:getAnchorY()
		return val.anchorY
	end

	function this:setIsScrollEnabled ( newValue ) 
		_isScrollEnabled = newValue  --. newValue must be true or false .--
	end

	function this:setIsZoomEnabled ( newValue ) 
		val.isZoomEnabled = newValue  --. newValue must be true or false .--
	end

	function this:setMapType ( newValue ) 
		val.mapType = newValue  --. newValue must be "standard", "satellite" or "hybrid" .--
	end

	--. Sets a marker in the map .--
		--. RETURN: -
		--. ARGUMENTS: 
		--. 	(address, [title], [subtitle])
		--. 	OR:
		--. 	(latitude, longitude, [title], [subtitle])
	function this:setMarker( ... )
		if type(arg[1]) == "string" then
			local markerAddress = arg[1]
			local markerTitleName = arg[2]
			local markerSubtitleName = arg[3]

			val.markersList[#val.markersList + 1] = { address = markerAddress, latitude = nil, longitude = nil, title = markerTitleName, subtitle = markerSubtitleName }
		else
			local latitudeValue = arg[1]
			local longitudeValue = arg[2]
			local markerTitleName = arg[3]
			local markerSubtitleName = arg[4]

			val.markersList[#val.markersList + 1] = { address = nil, latitude = latitudeValue, longitude = longitudeValue, title = markerTitleName, subtitle = markerSubtitleName }
		end

		
	end

	function this:deleteMarkerByCoordinates( latitude, longitude )
		if environment == "simulator" then
			log:warning("uiMap/getLocation: cannot run method in simulator environment")
			return UDEF.ERROR_CODE
		else
			for i=1, #val.markersList, 1 do
				if val.markersList[i].latitude == latitude then
					if val.markersList[i].longitude == longitude then
						table.remove (val.markersList, i)
						this:refresh()
						return true
					end
				end
			end
			log:error("uiMap/deleteMarkerByCoordinates: marker with latitude = " .. latitude .. " longitude = " .. longitude .. " was not found.")
			return UDEF.ERROR_CODE
		end


	end

	function this:deleteMarkerByTitle ( markerTitle )
		if environment == "simulator" then
			log:warning("uiMap/getLocation: cannot run method in simulator environment")
			return UDEF.ERROR_CODE
		else
			for i=1, #val.markersList, 1 do
				if val.markersList[i].title == markerTitle then
					table.remove (val.markersList, i)
					this:refresh()
					return true
				end
			end
			log:error("uiMap/deleteMarkerByCoordinates: marker with title = " .. markerTitle .. " was not found.")
			return UDEF.ERROR_CODE
		end
	end

	function this:deleteAllMarkers ( )
		if environment == "simulator" then
			log:warning("uiMap/getLocation: cannot run method in simulator environment")
			return UDEF.ERROR_CODE
		else
			for i=1, #val.markersList, 1 do
				val.markersList[i] = nil
			end
			map:removeAllMarkers()
			return true
		end
	end

	function this:setMapCenter ( latitude, longitude )
		val.centerLatitude  = latitude
		val.centerLongitude = longitude
	end

	function this:setMapRegion( latitude, longitude, latitudeSpan, longitudeSpan )
		val.regionLatitude      = latitude
		val.regionLongitude     = longitude
		val.regionLatitudeSpan  = latitudeSpan
		val.regionLongitudeSpan = longitudeSpan
	end

	function this:setMapAnimation ( newValue )
		val.isAminated = newValue
	end




	--. GETTERS

	function this:getMapTitle ( )
		return _navBarText
	end

	function this:getLocation( latitude, longitude )
		if environment == "simulator" then
			log:warning("uiMap/getLocation: cannot run method in simulator environment")
			return UDEF.ERROR_CODE
		else
			_userLocation = map:getUserLocation()
			if _userLocation.isError then
				log:error("uiMap/getLocation: " .. _userLocation.errorMessage)
				return UDEF.ERROR_CODE
			else
				return _userLocation
			end
		end
	end

	function this:getMapNearestAddress( latitude, longitude )
		if environment == "simulator" then
			log:warning("uiMap/getMapNearestAddress: cannot run method in simulator environment")
			return UDEF.ERROR_CODE
		else
			map:nearestAddress( latitude, longitude, mapNearestAddressHandler )
			return _mapNearestAddress
		end
	end

	function this:getMapAnimation ()
		return val.isAminated
	end

	function this:getMapRegion( )
		local mapRegion = {val.regionLatitude, val.regionLongitude, val.regionLatitudeSpan, val.regionLongitudeSpan}
		return mapRegion
	end

	function this:getMapCenter( )	
		local mapCenter = {val.centerLatitude, val.centerLongitude}
		return mapCenter
	end

	function this:markerExistsByCoordinates( latitude, longitude )
		for i=1, #val.markersList, 1 do
			if val.markersList[i].latitude == latitude then
				if val.markersList[i].longitude == longitude then
					return true
				end
			end
		end
		log:info("uiMap/markerExistsByCoordinates: marker with latitude = " .. latitude .. " longitude = " .. longitude .. " was not found.")
		return false	
	end

	function this:markerExistsByTitle ( markerTitle )
		for i=1, #val.markersList, 1 do
			if val.markersList[i].val.title == markerTitle then
				return true
			end
		end
		log:info("uiMap/markerExistsByTitle: marker with title = " .. title .. " was not found.")
		return false
	end

	function this:getIsScrollEnabled ()
		if environment == "simulator" then
			log:warning("uiMap/getIsScrollEnabled: cannot run method in simulator environment")
			return UDEF.ERROR_CODE
		else
			return _isScrollEnabled
		end
	end

	function this:getIsZoomEnabled ()
		if environment == "simulator" then
			log:warning("uiMap/getIsZoomEnabled: cannot run method in simulator environment")
			return UDEF.ERROR_CODE
		else
			return val.isZoomEnabled
		end
	end

	function this:getMapType ()
		if environment == "simulator" then
			log:warning("uiMap/getMapType: cannot run method in simulator environment")
			return UDEF.ERROR_CODE
		else
			return val.mapType
		end
	end

	--. 	A read-only Boolean value indicating whether the user's current location is visible within the area currently displayed on the map
		--. This is based on an approximation, so it may be that the value is true when the user's position is slightly offscreen.
		--. Will always return false if the current location is unknown.
	function this:getIsLocationVisible ()
		if environment == "simulator" then
			log:warning("uiMap/isLocationVisible: cannot run method in simulator environment")
			return UDEF.ERROR_CODE
		else
			return map.isLocationVisible
		end
	end

	function this:getWidth()
		return val.width
	end

	function this:getHeight()
		return val.height
	end

	function this:getAlpha()
		return val.alpha
	end

	function this:getX()
		return val.x
	end

	function this:getY()
		return val.y
	end

	function this:getRealHeight()
		return this:getHeight()
	end

	return this
end


return uiMap 
 