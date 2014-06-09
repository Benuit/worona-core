-- UI: uiTabBar 

---- Setters:
-- setText( text )            => text string
-- setRP( anchorX, anchorY )  => values between 0 and 1
-- setAnchorX( anchorX )      => values between 0 and 1, 0 is left, 1 is right
-- setAnchorY( anchorY )      => values between 0 and 1, 0 is top, 1 is bottom
-- setAlign( newAlign )       => "left", "center" or "right"
-- setWidth( newWidth )       => width 0 means no wraping text
-- setHeight( newHeight )     => height 0 means multiline
-- setAlpha( newAlpha )       => values between 0 and 1
-- setSize ( newSize )        => number in points, default is 16
-- setFillColor( r, g, b, a ) => values between 0 and 1
-- setMarginTop( top )        => number of points
-- setMarginBottom( bottom )  => number of points

---- Getters:
-- getText()         => 
-- getRP()           => return anchorX, anchorY (2 separate values)
-- getAnchorX()      => 
-- getAnchorY()      => 
-- getAlign()        => 
-- getWidth()        => 
-- getHeight()       => 
-- getAlpha()        => 
-- getFillColor()    => return r, g, b, a (4 separate values)
-- getMarginTop()    => 
-- getMarginBottom() => 
-- getRealHeight()   => return real height, including margins


local uUI = require "worona.core.uUI"

--: UI: uiTabBar :--
local uiTabBar = {}

function uiTabBar : new( )

	--. DEFAULT VALUES .--
	local val = {
		id                     = "default_tabBar",
		number_of_tabs         = 5,
		height                 = 52,
		width                  = display.contentWidth,

		backgroundFile         = "rsrc/img/tabBarBg.png",
		tabSelectedLeftFile    = "rsrc/img/tabBar_tabSelectedLeft.png",
		tabSelectedRightFile   = "rsrc/img/tabBar_tabSelectedRight.png",
		tabSelectedMiddleFile  = "rsrc/img/tabBar_tabSelectedMiddle.png",

		alpha                  = 1,
		selectedTab            = 1,

		--: default tab values :--
		imgWidth           = 32,
		imgHeight          = 32,
		defaultTabFile     = "rsrc/img/icon1.png",
		defaultTaboverFile = "rsrc/img/icon1-down.png",
		tabLabel           = "Tab",
		tabLabelColor      =  {
			default = { 255, 255, 255 },
			over    = { 255, 255, 255 }
		},
		tabFont     = native.systemFontBold,
		tabSize     = 8,
		tabSelected = false,
		defaultHandler = function(i) return function () log:info( "Tab " .. i .. " has been pressed" ); this:setSelectedTab( i ) end end 	--: default tabOnPress function :--,
	}
	val.currentX, val.currentY = (display.contentWidth - val.width)/2, display.contentHeight - val.height
	val.tabSelectedFrameWidth  = val.width / val.height / 2
	val.tabSelectedFrameHeight = val.height


	local tabOnPress  = {}	--: this stores the actual functions which are notified when an event ocurrs :--

	--: creates the display object :--
	local this = display.newGroup()

	--: sets the name for this prototype :--
	this.classType = "uiTabBar"
	--: gets the unique ID :--
	this.ID = getID()


	--: widget library :--
	local widget = require "widget"

	--: the actual tabbar object :--
	local tabBar

	--: table to store the tab properties :--
	local tabButtons = {}


	local generateTabs = function( number_of_tabs )
	--: it generates the tabs. if they don't exist, it gives them default values :--

		local realTabButtons = {}

		for i = 1, val.number_of_tabs do
		--: lets do a loop and check if the tabs exist, if they don't lets create them :--
			
			--: create the default tabs if they don't exist. this is used for storage only :--
			if tabButtons[i] == nil then
				tabButtons[i] = {
				    imgWidth    = val.imgWidth, 
				    imgHeight   = val.imgHeight,
				    defaultFile = val.defaultTabFile,
				    overFile    = val.defaultTaboverFile,
				    label       = val.tabLabel,
				    labelColor  = val.tabLabelColor,
				    font        = val.tabFont,
				    size        = val.tabSize,
				    onPress     = val.defaultHandler(i),
				    selected    = val.tabSelected
				}
			end

			--: store the real values which are going to be used in the next refresh() :--
			realTabButtons[i] = {
			    width       = tabButtons[i].imgWidth, 
			    height      = tabButtons[i].imgHeight,
			    defaultFile = tabButtons[i].defaultFile,
			    overFile    = tabButtons[i].overFile,
			    label       = tabButtons[i].label,
			    labelColor  = tabButtons[i].labelColor,
			    font        = tabButtons[i].font,
			    size        = tabButtons[i].size,
			    onPress     = tabButtons[i].onPress,
			    selected    = tabButtons[i].selected
			}
		end

		return realTabButtons
	end

	--: create or recreate the tabBar :--
		--: RETURN: true if succeed,false if not
		--:
	function this:refresh()

		--: attempt to remove it before creating a new one :--
 		this:removeTextureMemory()

		--: create the new one :--
		tabBar = widget.newTabBar ( {
			left                   = val.currentX,
			top                    = val.currentY,
			width                  = val.width,
			height                 = val.height,
			backgroundFile         = val.backgroundFile,
			tabSelectedLeftFile    = val.tabSelectedLeftFile,
			tabSelectedRightFile   = val.tabSelectedRightFile,
			tabSelectedMiddleFile  = val.tabSelectedMiddleFile,
			tabSelectedFrameWidth  = val.tabSelectedFrameWidth,
			tabSelectedFrameHeight = val.tabSelectedFrameHeight,
			buttons                = generateTabs( val.number_of_tabs )
		} )

		--: change other settings :--
		this.alpha = val.alpha

		--: insert it in the group :--
		this:insert( tabBar )		
	end

	function this:removeTextureMemory()
		if tabBar ~= nil then
			display.remove( tabBar )
			tabBar = nil
			return true
		end
		return false
	end

	--: change the number of tabs :--
		--: RETURN: true if succeed, false if not
		--: ARGUMENTS: 
		--: 	numberTabs: new number of tabs
	function this:setNumberTabs( numberTabs )
		
		local number = tonumber( numberTabs )

		if type(number) ~= "number" then
			log:fatal("uiTabBar: setNumberTabs parameter should be a number.")
			return -1
		else
			val.number_of_tabs = number
			return true
		end



	end

	function this:getNumberTabs()
		
		return val.number_of_tabs
	end
	
	--: Add behavior to tabs :--
		--: RETURN: true if succeed, false if not
		--: ARGUMENTS: 
		--: 	event: it only accepts "touch"
		--:		func: function to be added
		--:		tab: tab number. it's optional. if not passed, the func is applied to all tabs and that function can receive the tab number, like `function(tab)`
	function this:addEventHandler( event, func, tab )

		if event == "touch" then

			if tab ~= nil then
				if tab <= val.number_of_tabs then
					tabButtons[ tab ].onPress = function()
														this:setSelectedTab(tab)
														func()
												end
				else
					log:warning("uiTabBar: you are trying to add behavior to a tab which doesn't exist.")
				end
			else
				for i = 1, #tabButtons do
					tabButtons[i].onPress =	function() 
												this:setSelectedTab(i)
												func(i)
											end
				end
			end
			return true
		else
			log:warning("uiTabBar: in tabbars only `touch` is allowed. Do not use " .. event .. ".")
			return false
		end
	end

	--: Simulates the pressing of a tab :--
		--: RETURN: true if succeed, false if not
		--: ARGUMENTS: 
		--: 	event: only accepts "touch"
		--:		tab: tab number (not optional!)
	function this:runHandler( event, tab )

		if event == "touch" then
			if tab == nil then
				log:warning("uiTabBar: you can only run one handler at a time, please use `tab`.")
			elseif tabButtons[ tab ].onPress == nil then
				log:warning("uiTabBar: Tab " .. tab .. " doesn't have any handler. Probably out of range.")
			else
				log:info("uiTabBar: running manually the function of tab " .. tab .. ".")
				tabButtons[ tab ].onPress()
				return true
			end
		else
			log:warning("uiTabBar: in tabbars only `touch` is allowed. Do not use " .. event .. ".")
		end
		return false
	end

	function this:setX( newX )
		
		val.currentX = newX
	end

	function this:setY( newY )
		
		val.currentY = newY
	end

	function this.getX()
		return val.currentX
	end

	function this.getY()
		return val.currentY
	end

	function this:setAlpha( newAlpha )
		val.alpha = newAlpha
	end

	function this:getAlpha()
		return val.alpha
	end

	function this:setLabel( label_text, tab )
		if tab ~= nil then
			if tab <= val.number_of_tabs then
				tabButtons[ tab ].label = label_text
			else
					log:warning("uiTabBar: you are trying to add behavior to a tab which doesn't exist.")
			end
		else 
			for i = 1, #tabButtons do
				tabButtons[ i ].label = label_text
			end
		end
	end

	function this:getLabel( tab )
		return tabButtons[ tab ].label
	end

	function this:setLabelColor( label_color, tab )
		if tab ~= nil then
			if tab <= val.number_of_tabs then
				tabButtons[ tab ].labelColor = label_color
			else
					log:warning("uiTabBar: you are trying to add behavior to a tab which doesn't exist.")
			end
		else 
			for i = 1, #tabButtons do
				tabButtons[ i ].labelColor = label_color
			end
		end
	end

	function this:getLabelColor( tab )
		return tabButtons[ tab ].labelColor
	end

	function this:setDefaultFile( default_file, tab )
		if tab ~= nil then
			if tab <= val.number_of_tabs then
				tabButtons[ tab ].defaultFile = default_file
			else
					log:warning("uiTabBar: you are trying to add behavior to a tab which doesn't exist.")
			end
		else 
			for i = 1, #tabButtons do
				tabButtons[ i ].defaultFile = default_file
			end
		end
	end

	function this:getDefaultFile( tab )
		return tabButtons[ tab ].defaultFile
	end

	function this:setOverFile( over_file, tab )
		if tab ~= nil then
			if tab <= val.number_of_tabs then
				tabButtons[ tab ].overFile = over_file
			else
					log:warning("uiTabBar: you are trying to add behavior to a tab which doesn't exist.")
			end
		else 
			for i = 1, #tabButtons do
				tabButtons[ i ].overFile = over_file
			end
		end
	end

	function this:getOverFile( tab )
		return tabButtons[ tab ].overFile
	end

	--: Local function used to calculate the min width and avoid crashes on setImgWidth and setWidth :--
		--: RETURN: total new width value
		--: ARGUMENTS: 
		--: 	same arguments than setImgWidth, both optional
	local function getImgTotalWidth( img_width, tab )
		local totalWidth = 0

		for i = 1, #tabButtons do
			if (img_width ~= nil and i == tab) or (img_width ~= nil and tab == nil) then
				totalWidth = totalWidth + img_width
			else
				totalWidth = totalWidth + tabButtons[i].imgWidth
			end
		end
		return totalWidth 
	end

	function this:setHeight( newHeight )
		val.height = newHeight
	end

	function this:getHeight( newHeight )
		return val.height
	end

	function this:setWidth( newWidth )

		local tabBarImgWidth = getImgTotalWidth()

		if newWidth <= tabBarImgWidth then
			log:error("uiTabBar: Min TabBar width is " .. tabBarImgWidth .. " and you are trying to set " .. newWidth .. ". Aborting function to avoid a crash.")
		else
			val.width = newWidth
		end
	end

	function this:getWidth( newWidth )
		return val.width
	end

	function this:setImgWidth( img_width, tab )

		local tabBarWidth = this:getWidth()
		local newTabBarWidth = getImgTotalWidth( img_width, tab )

		if tabBarWidth < newTabBarWidth then
			log:error("uiTabBar: TabBar width is " .. tabBarWidth .. " and you are trying to set " .. newTabBarWidth .. ". Aborting function to avoid a crash.")
		else
			if tab ~= nil then
				if tab <= val.number_of_tabs then
					tabButtons[ tab ].imgWidth = img_width
				else
						log:warning("uiTabBar: you are trying to add behavior to a tab which doesn't exist.")
				end
			else 
				for i = 1, #tabButtons do
					tabButtons[ i ].imgWidth = img_width
				end
			end
		end
	end

	function this:getImgWidth( tab )
		return tabButtons[ tab ].imgWidth
	end

	function this:setImgHeight( img_height, tab )
		if tab ~= nil then
			if tab <= val.number_of_tabs then
				tabButtons[ tab ].imgHeight = img_height
			else
					log:warning("uiTabBar: you are trying to add behavior to a tab which doesn't exist.")
			end
		else 
			for i = 1, #tabButtons do
				tabButtons[ i ].imgHeight = img_height
			end
		end
	end

	function this:getImgHeight( tab )
		return tabButtons[ tab ].imgHeight
	end

	function this:setSelectedTab( tab )
		if tab ~= nil then
			if tab <= val.number_of_tabs then
				tabButtons[ val.selectedTab ].selected = false
				val.selectedTab = tab
				tabButtons[ val.selectedTab ].selected = true
				return true
			else
					log:warning("uiTabBar: you are trying to add behavior to a tab which doesn't exist.")
			end
		end
		return false
	end

	function this:getSelectedTab()
		return val.selectedTab
	end

	function this:setBackgroundFile( newBackgroundFile )
		val.backgroundFile = newBackgroundFile
	end

	function this:getBackgroundFile()
		return val.backgroundFile
	end

	function this:setTabSelectedLeftFile( newTabSelectedLeftFile )
		val.tabSelectedLeftFile = newTabSelectedLeftFile
	end

	function this:getTabSelectedLeftFile()
		return val.tabSelectedLeftFile
	end

	function this:setTabSelectedRightFile( newTabSelectedRightFile )
		val.tabSelectedRightFile = newTabSelectedRightFile
	end

	function this:getTabSelectedRightFile()
		return val.tabSelectedRightFile
	end

	function this:setTabSelectedMiddleFile( newTabSelectedMiddleFile )
		val.tabSelectedMiddleFile = newTabSelectedMiddleFile
	end

	function this:getTabSelectedMiddleFile()
		return val.tabSelectedMiddleFile
	end

	function this:setTabSelectedFrameWidth( newTabSelectedFrameWidth )
		val.tabSelectedFrameWidth = newTabSelectedFrameWidth
	end

	function this:getTabSelectedFrameWidth()
		return val.tabSelectedFrameWidth
	end

	function this:setTabSelectedFrameHeight( newTabSelectedFrameHeight )
		val.tabSelectedFrameHeight = newTabSelectedFrameHeight
	end

	function this:getTabSelectedFrameHeight()
		return val.tabSelectedFrameHeight
	end

	function this:setFont( da_font )
		val.tabFont = da_font
		for i = 1, #tabButtons do
			tabButtons[i].font = da_font
		end
	end

	function this:getFont( )
		return val.tabFont
	end

	function this:setSize( newSize )
		val.tabSize = newSize
		for i = 1, #tabButtons do
			tabButtons[i].size = newSize
		end
	end

	function this:getSize( )
		return val.tabSize
	end

	function this:hide()
		val.alpha = 0
		this:refresh()
	end

	function this:show()
		val.alpha = 1
		this:refresh()
	end

	local init = function()
	--: creates the first tabbar :--
		this:refresh()
	end

	--: start :--
	init()

	return this

end

return uiTabBar 
 				