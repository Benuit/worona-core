local worona = require "worona"

local content_type = "posts" --. insert content type ( "customcontent" / "posts" )


worona:do_action( "register_service", { service = "content", creator = require("worona.includes.content.services.content") } )


local function readContent()
	local content_types_array = { "posts", "customcontent" }
	
	for i=1, #content_types_array do
		worona.log:info("content/main.lua - Reading content type: '" .. content_types_array[i] .. "'")
		worona.content:readContentFile( content_file_path )
	end
end
-- worona:add_action( "init", readContent )



local function downloadContent()
	worona.content:update( content_type, worona.wp_url )
end

worona:add_action( "init", downloadContent )