local worona = require "worona"

worona:do_action( "register_scene", { scene = "webview", creator = require( "worona.includes.webview.scenes.webview" ) } )

local function loadWebview( params )
	--: convert websiteurl to numbers to use as ID
	local websiteurl = params.websiteurl
	local url_in_numbers = ""
	for i = 1, #websiteurl do
		url_in_numbers = url_in_numbers .. websiteurl:byte(i)
	end
	worona:do_action( "go_to_scene", { scene = "webview", scene_id = url_in_numbers, options = { effect = "fade", time = 100, params = { websitetitle = params.websitetitle, websiteurl = params.websiteurl } } } )
end
worona:add_action( "load_webview", loadWebview )