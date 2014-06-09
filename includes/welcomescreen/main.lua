local worona = require "worona"

worona:do_action( "register_scene", { scene = "welcomescreen", creator = require( "worona.includes.welcomescreen.scenes.welcomescreen" ) } )

local function loadWelcomeScreen( params )
	worona:do_action( "go_to_scene", { scene = "welcomescreen", options = { params = { title = "Madrid Gay" } } } )
end
worona:add_action( "init", loadWelcomeScreen )