local worona = require "worona"

function loadUrl( params )

	local url = params.url

	local scene_type = worona.content:urlCustomPostType(url) or "webview"

	local url_in_numbers = ""
	for i = 1, #url do
		url_in_numbers = url_in_numbers .. url:byte(i)
	end
	worona.log:info("load_url: loading the URL: " .. url )
	worona:do_action( "go_to_scene", { scene = scene_type, scene_id = url_in_numbers, options = { effect = "fade", time = 100, params = { url = url  } } } )

end
worona:add_action( "load_url", loadUrl )