local worona = require "worona"

local function attachNavBar()

	local sceneGroup   = worona.scene:getCurrentSceneGroup()
	local current_type = worona.scene:getCurrentSceneType()

	if current_type == "post" then
		
		local current_url  = worona.scene:getCurrentSceneUrl()
		local content      = worona.content:getPost( current_type, current_url )

		local basic_navbar = worona.ui:newBasicNavBar({
			sceneGroup   = sceneGroup,
			text         = content.title,
			lefthandler  = function() worona:do_action( "load_previous_scene", { effect = "slideRight", time = 200 } ) end
		})
	
	elseif current_type == "scene-list" then

		local basic_navbar = worona.ui:newBasicNavBar({
			sceneGroup   = sceneGroup,
			text         = worona.app_title,
			lefthandler  = function() end
		})
	end


	

	return basic_navbar
end
worona:add_action( "after_creating_scene", attachNavBar )