local worona = require "worona"

function loadUrl( params )

	local url = params.url

	local scene_type = worona.content:urlCustomPostType(url) or "webview"

	worona.log:info("load_url: loading the URL: " .. url )
	worona:do_action( "go_to_scene", { scene_type = scene_type, scene_url = url, effect = "slideLeft", time = 100 } )
end
worona:add_action( "load_url", loadUrl )