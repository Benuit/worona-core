local worona = require "worona"

worona:do_action( "register_scene", { scene = "scene-list", creator = require( "worona.includes.scene-list.scenes.scene-list" ) } )

local function loadListView( params )
	worona.log:info("scene-list/main - do action: go_to_scene -> scene-list")
	worona:do_action( "go_to_scene", { scene = "scene-list", options = { params = { title = "Example Title" } } } )
end
worona:add_action( "init", loadListView )