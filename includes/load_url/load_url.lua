local worona = require "worona"

function loadUrl( params )

	local url = params.url

	--: check if string doesn't start with http
	if string.find( url, "http" ) ~= 1 then
	  url = string.gsub( url, "file://", "" )
	  worona.log:info("load_url: The url is relative " .. url )
	  url = worona.wp_url .. url
	end

	local scene_type = worona.content:urlCustomPostType(url) or "scene-webview"

	scene_type = worona:do_filter( "filter_load_url_scene_type", scene_type, params )

	worona.log:info("load_url: loading the URL '" .. url .. "' with the scene type '" .. scene_type .. "'" )
	worona:do_action( "go_to_scene", { scene_type = scene_type, scene_url = url, effect = "slideLeft", time = 100, params = params } )
end
worona:add_action( "load_url", loadUrl )