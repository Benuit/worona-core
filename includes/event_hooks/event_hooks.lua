local worona = require "worona"

local function registerHooks()
	
	--: key based hooks
	local function onKeyEvent(event)
		
		--: android_back_button_pushed hook
		if ( event.keyName == "back" and event.phase == "up" ) then
			worona:do_action( "android_back_button_pushed" )
			return true
		end
	end

	Runtime:addEventListener( "key", onKeyEvent )
end

worona:add_action( "init", registerHooks )