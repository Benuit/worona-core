local worona   = require "worona"
local composer = require "composer"

local function newSceneService()

	--: service table
	local scene = {}

	--: private variables
	local registered_scenes = {}
	local scenes_history    = {}

	--: private functions
	local function registerScene( params )
		registered_scenes[ params.scene ] = params.creator
	end
	worona:add_action( "register_scene", registerScene )


	local function gotoScene( params )
		
		local scene_with_id = params.scene
		
		if params.scene_id ~= nil then
			scene_with_id = params.scene .. "_" .. params.scene_id
		end

		if composer.getScene( scene_with_id ) == nil then
			registered_scenes[ params.scene ]( scene_with_id )
		end

		worona.log:info("scene: About to load the scene '" .. scene_with_id .. "'" )
		
		scenes_history[ #scenes_history + 1 ] = scene_with_id
		composer.gotoScene( scene_with_id, params.options )
	end
	worona:add_action( "go_to_scene", gotoScene )


	function loadUrl( params )

		local url = params.url

		local content_type_if_url_in_content = worona.content:urlExist(url) 
		
		if content_type_if_url_in_content ~= false then	
			worona:do_action( "go_to_scene", { scene = content_type_if_url_in_content, scene_id = url } )
		else
			worona:do_action( "go_to_scene", { scene = "webview", scene_id = url, } )
		end
	end
	worona:add_action( "load_url", loadUrl )

	


	local function loadPreviousScene( params )

		local scene_to_load = scenes_history[ #scenes_history - 1 ]

		if scene_to_load ~= nil then

			if composer.getScene( scene_to_load ) == nil then
				registered_scenes[ params.scene ]( scene_to_load ) 
			end

			worona.log:info("scene: About to load the scene '" .. scene_to_load .. "'" )

			composer.gotoScene( scene_to_load, params.options )

			scenes_history[ #scenes_history ] = nil
		end
	end
	worona:add_action( "load_previous_scene", loadPreviousScene )

	return scene
end

return newSceneService