local widget = require "widget"

local function scrollListener( event )
   local phase = event.phase
   local direction = event.direction
   
   if "began" == phase then
      --print( "Began" )
   elseif "moved" == phase then
      --print( "Moved" )
   elseif "ended" == phase then
      --print( "Ended" )
   end
   
   -- If the scrollView has reached it's scroll limit
   if event.limitReached then
      if "up" == direction then
         -- print( "Reached Top Limit" )
      elseif "down" == direction then
         -- print( "Reached Bottom Limit" )
      elseif "left" == direction then
         -- print( "Reached Left Limit" )
      elseif "right" == direction then
         -- print( "Reached Right Limit" )
      end
   end
         
   return true
end

local function createScrollview( params )

	local scrollView = widget.newScrollView
	{
	    top                      = 50 + display.topStatusBarContentHeight,
	    left                     = 0,
	    width                    = display.contentWidth,
	    height                   = display.contentHeight -  50 - display.topStatusBarContentHeight - 50,
	    horizontalScrollDisabled = true,
	    verticalScrollDisabled   = false,
       topPadding               = 10,
       bottomPadding            = 30,
       hideBackground           = true,
	    listener                 = scrollListener
	}
	params.parent:insert( scrollView )

	return scrollView
end

return createScrollview