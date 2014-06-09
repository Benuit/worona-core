local worona = require "worona"

local basic_navbar

local function attachNavBar( params )

	basic_navbar = worona.ui:newBasicNavBar({
		sceneGroup = params.sceneGroup,
		text       = params.pagetitle,
		handler    = function() worona:do_action( "load_previous_scene", { options = { effect = "slideRight", time = 200, params = params } } ) end
	})
end

return attachNavBar