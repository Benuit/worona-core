-- UI: newText 

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


local function newText( options )

	local that = display.newGroup()		-- the new instance

	-- default values
	local val = {
		text          = "No text added yet",
		x             = 0,
		y             = display.topStatusBarContentHeight,
		width         = 0, 											-- 0 means no wraping text
		height        = 0, 											-- 0 means multiline
		font          = native.systemFont,
		size          = 16,
		align         = "left",
		red           = 1,
		green         = 1,
		blue          = 1,
		alpha         = 1,
		anchorX       = 0,
		anchorY       = 0,
		margin_top    = 0,
		margin_bottom = 0
	}


	-- private variables
	local txt 		-- the actual display text variable. we need it outside refresh() to be able to remove its texture later


	-- public methods
	function that:refresh()
		
		that:removeTexture()
		
		local options = {
		    text     = val.text,
		    x        = val.x,
		    y        = val.y,
		    width    = val.width,
		    height   = val.height,
		    font     = val.font,   
		    fontSize = val.size,
		    align    = val.align
		}
		
		txt = display.newText( options )
		txt:setFillColor(val.red, val.green, val.blue, val.alpha)
		txt.anchorX = val.anchorX
		txt.anchorY = val.anchorY
		txt.x, txt.y = val.x, val.y + val.margin_top
		that:insert(txt)
	end

	function that:removeTexture()
		display.remove(txt)
		txt = nil
	end


	-- setters and getters
	function that:setText( newText )
		val.text = newText
	end

	function that:getText()
		return val.text
	end

	function that:setRP ( anchorX, anchorY )
		that:setAnchorX( anchorX )
		that:setAnchorY( anchorY )
	end

	function that:getRP()
		return that:getAnchorX(), that:getAnchorY()
	end

	function that:setAnchorX( anchorX )
		val.anchorX = anchorX
	end

	function that:getAnchorX()
		return val.anchorX
	end

	function that:setAnchorY( anchorY )
		val.anchorY = anchorY
	end

	function that:getAnchorY()
		return val.anchorY
	end

	function that:setAlign( newAlign )
		val.align = newAlign
	end

	function that:getAlign()
		return val.align
	end

	-- Width should be multiple of 4, so we increase the value to the nearest multiple
	function that:setWidth( newWidth )
		local modulo = newWidth % 4
		if modulo == 0 then
			val.width = newWidth
		else
			val.width = newWidth + 4 - modulo
		end
	end

	function that:getWidth()
		return val.width
	end

	function that:setHeight( newHeight )
		val.height = newHeight
	end

	function that:getHeight()
		return val.height
	end

	function that:setAlpha( newAlpha )
		val.alpha = newAlpha
	end

	function that:getAlpha()
		return val.alpha
	end

	function that:setX ( newX )
		val.x = newX
	end

	function that:getX()
		return val.x
	end

	function that:setY ( newY )
		val.y = newY
	end

	function that:getY()
		return val.y
	end

	function that:setSize ( newSize )
		val.size = newSize
	end

	function that:getSize()
		return val.size
	end

	function that:setFillColor ( r, g, b, a )
		val.red   = r
		val.green = g
		val.blue  = b
		val.alpha = a or 1
	end

	function that:getFillColor()
		return val.red, val.green, val.blue, val.alpha
	end

	function that:setMarginTop( newMarginTop )
		val.margin_top = newMarginTop
	end

	function that:getMarginTop()
		return val.margin_top
	end

	function that:setMarginBottom( newMarginBottom )
		val.margin_bottom = newMarginBottom
	end

	function that:getMarginBottom()
		return val.margin_bottom
	end

	function that:getRealHeight()
		return that.contentHeight + val.margin_top + val.margin_bottom
	end

	return that

end

return newText