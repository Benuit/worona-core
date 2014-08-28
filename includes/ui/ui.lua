local worona = require "worona"

local function newUiService()
	return {}
end

worona:do_action( "register_service", { service = "ui", creator = newUiService } )