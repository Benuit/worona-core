-- UI: uiSingleText 
uiSingleText={}


function uiSingleText:new( )

	-- creates the display object
	local this = display.newText("UNDEFINED", 50, 50, native.systemFont, 16)


	-- sets the name for this class
	this.classType = "uiSingleLineText"
	-- gets the unique ID
	this.ID = getID()

	function this:setText( txt )
		this.text = txt
	end

	function this:getText()
		return this.text
	end

	return this

end

return uiSingleText