local worona = require "worona"

local content_type = "posts" --. insert content type ( "customcontent" / "posts" )


worona:do_action( "register_service", { service = "content", creator = require("worona.includes.content.services.content") } )

local function downloadContent()
	worona.content:update( content_type, worona.app_url )
end

worona:add_action( "init", downloadContent )