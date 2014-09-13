local worona   = require "worona"
local composer = require "composer"

local function newSceneService()

	--: service table
	local scene = {}
	local random = math.random()

	--: private variables
	local registered_scenes   = {}
	local scenes_history      = {}

	
	--: PRIVATE FUNCTIONS

	--[[-  registerScene
		-
		-  This local function is attached to the 'register_scene' action and will do things such as:
		-  register a scene in the framework to be used later with 'gotoScene'
		-
		-  @type	action (register_scene)
		-  @date	21/08/14
		-  @since	0.6.0
		-
		-  @param	{ scene_type = "name of custom post type or scene", creator = functionReturningTheScene }
		-  @return	N/A
		-
		-  @example: worona:do_action( "register_scene", { scene_type = "post", creator = newPostScene } )
		]]--
	local function registerScene( params )
		registered_scenes[ params.scene_type ] = params.creator
	end
	worona:add_action( "register_scene", registerScene )


	--[[-  gotoScene
		-
		-  This local function is attached to the 'go_to_scene' action and will do things such as:
		-  init the transition to a new scene
		-
		-  @type	action (go_to_scene)
		-  @date	21/08/14
		-  @since	0.6.0
		-
		-  @param	{ scene_type = "name of custom post type or scene", scene_url = "unique url of the post, it is optional", effect = "effect name", time = miliseconds }
		-  @return	N/A
		-
		-  @example: worona:do_action( "go_to_scene", { scene_type = "post", scene_url = "http://www.example.org/name-of-the-post/", effect = "fade", time = 100 } )
		]]--
	local function gotoScene( params )
		
		local scene_with_url = params.scene_type
		
		local url = params.scene_url
		if url ~= nil then
			local url_in_numbers = ""
			for i = 1, #url do
				url_in_numbers = url_in_numbers .. url:byte(i)
			end
			scene_with_url = scene_with_url .. "_" .. url_in_numbers
		end

		scene_with_url = scene_with_url .. random

		if composer.getScene( scene_with_url ) == nil then
			registered_scenes[ params.scene_type ]( scene_with_url )
		end


		worona.log:info("scene: About to load the scene '" .. scene_with_url .. "'" )
		
		scenes_history[ #scenes_history + 1 ] = { scene_type = params.scene_type, scene_url = params.scene_url, scene_with_url = scene_with_url }

		composer.gotoScene( scene_with_url, { effect = params.effect, time = params.time, params = params.params } )
	end
	worona:add_action( "go_to_scene", gotoScene )

	--[[-  loadPreviousScene
		-
		-  This local function is attached to the 'load_previous_scene' action and will do things such as:
		-  init the transition to the previous scene
		-
		-  @type	action (load_previous_scene)
		-  @date	21/08/14
		-  @since	0.6.0
		-
		-  @param	{ effect = "effect name", time = miliseconds }
		-  @return	N/A
		-
		-  @example: worona:do_action( "load_previous_scene", { effect = "slideRight", time = 200 } )
		]]--
	local function loadPreviousScene( params )

		local scene_to_load = scenes_history[ #scenes_history - 1 ]

		if scene_to_load ~= nil then

			if composer.getScene( scene_to_load.scene_with_url ) == nil then
				registered_scenes[ scene_to_load.scene_type ]( scene_to_load.scene_with_url ) 
			end

			worona.log:info("scene: About to load the scene '" .. scene_to_load.scene_with_url .. "'" )

			composer.gotoScene( scene_to_load.scene_with_url, { effect = params.effect, time = params.time, params = params.params } )

			scenes_history[ #scenes_history ] = nil
		else
			worona.log:warning("scene:loadPreviousScene: Can't load the previous scene. Nothing to load.")
		end
	end
	worona:add_action( "load_previous_scene", loadPreviousScene )



	--: PUBLIC FUNCTIONS

	--[[-  getCurrentSceneType
		-
		-  This local function is attached to the service 'worona.scene:getCurrentSceneType()' function and will do things such as:
		-  return the scene_type of the current scene
		-
		-  @type	service (worona.scene:getCurrentSceneType)
		-  @date	21/08/14
		-  @since	0.6.0
		-
		-  @param	N/A
		-  @return	the scene type (string) or -1 if something went wrong
		-
		-  @example: local current_scene_type = worona.scene:getCurrentType() -- returns "post"
		]]--
	function scene:getCurrentSceneType()
		return scenes_history[ #scenes_history ].scene_type or -1
	end

	--[[-  getCurrentSceneUrl
		-
		-  This local function is attached to the service 'worona.scene:getCurrentSceneUrl()' function and will do things such as:
		-  return the scene_url of the current scene
		-
		-  @type	service (worona.scene:getCurrentSceneUrl)
		-  @date	21/08/14
		-  @since	0.6.0
		-
		-  @param	N/A
		-  @return	the scene url (string) or -1 if something went wrong
		-
		-  @example: local current_scene_url = worona.scene:getCurrentSceneUrl() -- returns "http://www.example.org/name-of-the-post/"
		]]--
	function scene:getCurrentSceneUrl()
		return scenes_history[ #scenes_history ].scene_url or -1
	end

	--[[-  getCurrentSceneGroup
		-
		-  This local function is attached to the service 'worona.scene:getCurrentSceneGroup()' function and will do things such as:
		-  return the scene_group of the current scene
		-
		-  @type	service (worona.scene:getCurrentSceneGroup)
		-  @date	21/08/14
		-  @since	0.6.0
		-
		-  @param	N/A
		-  @return	the scene group (display group) or -1 if something went wrong
		-
		-  @example: local current_scene_group = worona.scene:getCurrentSceneGroup()
		-            current_scene_group:insert( some_image )
		]]--
	function scene:getCurrentSceneGroup()
		local scene_object = composer.getScene( scenes_history[ #scenes_history ].scene_with_url )
		return scene_object.view
	end


	return scene
end

worona:do_action( "register_service", { service = "scene", creator = newSceneService } )