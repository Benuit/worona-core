-- UI: uiBlank   
local uiBlank = {}

function uiBlank : new( )

	--. DEFAULT VALUES .--
	local val = {
		height = 10,
		y = 10
	}

	-- creates the display object
	local that = uUI:new( "uiBlank", bloodGroup )

	-- sets the name for that class
	that.classType = "uiBlank"
	-- gets the unique ID
	that.ID = getID()

	-- methods
	function that:refresh()
		
		
	end

	function that:setHeight ( newHeight )
		val.height = newHeight
	end


	function that:setY ( newY )
		val.y = newY
	end


	--. GETTERS

	function that:getHeight()
		return val.height
	end

	function that:getY()
		return val.y
	end

	function that:getRealHeight()
		return that:getHeight()
	end


	return that

end

return uiBlank 
 