local worona = require "worona"

function loadUrl( params )

	local url = params.url

	local content_type_if_url_in_content = worona.content:urlExist(url) 

	local url_in_numbers = ""
	for i = 1, #url do
		url_in_numbers = url_in_numbers .. url:byte(i)
	end

	if content_type_if_url_in_content ~= false then	
		worona:do_action( "go_to_scene", { scene = content_type_if_url_in_content, scene_id = url_in_numbers } )
	else
		worona:do_action( "go_to_scene", { scene = "webview", scene_id = url_in_numbers, options =  { effect = "fade", time = 100, params = { url = url  } } } )
	end
end
worona:add_action( "load_url", loadUrl )