local worona = require "worona"

worona:do_action( "register_service", { service = "content", creator = require("worona.includes.content.services.content") } )

local function downloadContent()

	local json_read = worona.local_options:read( "content/json/ignition.json" )

	if json_read == true then
		local app_url = worona.local_options:get( "app_url" )
		worona.content:update( "customcontent", app_url )
	else
		worona.log:warning("downloadContent: cannot get app url from ignition.json")
	end	
end

worona:add_action( "init", downloadContent )