local worona = require "worona"

local function attachNavBar( params )

	local SceneGroup   = worona.scene:getCurrentSceneGroup()
	local current_type = worona.scene:getCurrentSceneType()
	local current_url  = worona.scene:getCurrentSceneUrl()
	local content      = worona.content:getPost( current_type, current_url )

	local basic_navbar = worona.ui:newBasicNavBar({
		sceneGroup   = SceneGroup,
		text         = content.title,
		lefthandler  = function() worona:do_action( "load_previous_scene", { effect = "slideRight", time = 200, params = params } ) end
	})

	return basic_navbar
end
worona:add_action( "before_creating_scene", attachNavBar )