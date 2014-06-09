local worona = require "worona"

local function load_page( params )
	
	local options  = params.options or { effect = "slideLeft", time = 200 }
	options.params = params

	if params ~= nil and params[ params.page_type ] ~= nil then
		params.page_id = params[ params.page_type ].ID
	end

	if current == nil or scene ~= current.scene_name then
		worona:do_action( "go_to_scene", { scene = params.page_type, scene_id = params.page_id, options = options } )
	end
end

return load_page

