-- UI: uiButton   
uiButton = {}

function uiButton : new( )

	--. DEFAULT VALUES
	local val = {
		width       = 150,
		height      = 50,
		left        = 100,
		top         = 150,
		anchorX     = 0,
		anchorY     = 0,
		baseDir     = system.ResourceDirectory,
		defaultFile = "rsrc/img/default.jpg",
		overFile    = "rsrc/img/over.jpg",
		id          = "button_1",
		label       = "Button",
		label_size  = 16,
		label_font  = native.systemFont,
		label_color = {
	 		default = { 1, 1, 1, 1 },
	    	over 	= { 0.46875, 0.20703125, 0.5, 1 },
		},
		onEvent     = handleButtonEvent
	}	

	


	local widget = require( "widget" )
	local button

	local fileUtils = require "worona.lib.utils.fileUtils"

	-- Create a group
	local this = uUI:new( "uiButton", bloodGroup )

	
	

	-- methods

	function this:removeTexture()
		if button ~= nil then 
			button:removeSelf()
			button = nil 
		end
	end

	local function calculateWidth()
		if val.width == 0 then
			local text_length = string.len(val.label)
			return text_length*11
		else
			return val.width
		end
	end

	function this:refresh ()

		this:removeTexture()

		local _autowidth = calculateWidth()		--: if width = 0 then width should adapt to text width :--

		-- refresh the button
		button = widget.newButton
		{
		    left        = val.left,
		    top         = val.top,
		    width       = _autowidth,
		    height      = val.height,
		    baseDir     = val.baseDir,
		    defaultFile = val.defaultFile,
		    overFile    = val.overFile,
		    id          = val.id,
		    label       = val.label,
		    labelColor  = val.label_color,
		    font        = val.label_font,
		    fontSize    = val.label_size,
		    onEvent     = val.onEvent,
		}

		this:insert(button)
		this.anchorChildren = true
		this.anchorX = val.anchorX
		this.anchorY = val.anchorY
		this.x = val.left
		this.y = val.top
	end


	local function init()	
	end

	function this:setDefaultTextColor( r, g, b, a )
		val.label_color.default = { r, g, b, a }
	end

	function this:setOverTextColor( r, g, b, a )
		val.label_color.over = { r, g, b, a }
	end

	function this:getDefaultTextColor()
		return val.label_color.default[1], val.label_color.default[2], val.label_color.default[3], val.label_color.default[4]
	end

	function this:getOverTextColor()
		return val.label_color.over[1], val.label_color.over[2], val.label_color.over[3], val.label_color.over[4]
	end

	function this:setX ( left )
		val.left = left
	end

	function this:setY ( top )
		val.top = top
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

	function this:setWidth ( width )
		val.width = width
	end

	function this:setHeight ( height )
		val.height = height
	end

	function this:setDefaultImage ( defaultFile )
		val.baseDir     = fileUtils:locateFile( defaultFile )
		val.defaultFile = "rsrc/img/" .. defaultFile
	end

	function this:setOverImage ( overFile )
		val.baseDir  = fileUtils:locateFile( overFile )
		val.overFile = "rsrc/img/" .. overFile
	end

	function this:setId ( id )
		val.id = id
	end

	function this:setLabel( label )
		val.label = label
	end

	function this:setLabelSize( label_size )
		val.label_size = label_size
	end

	function this:addEventHandler ( type, onEvent )
		val.onEvent = onEvent
	end

	function this:getX ()
		return val.left
	end

	function this:getY ()
		return val.top
	end

	function this:getWidth ()
		return val.width
	end

	function this:getHeight ()
		return val.height
	end

	function this:getDefaultImage ()
		return val.defaultFile
	end

	function this:getOverImage ()
		return val.overFile
	end

	function this:getId ()
		return val.id
	end

	function this:getLabel()
		return val.label
	end

	function this:getEventHandler()
		return val.onEvent
	end

	function this:getRealHeight()
		return this:getHeight()
	end

	function this:getRealWidth()
		return calculateWidth()
	end

	init()

	return this

end

return uiButton 