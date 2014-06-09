local worona = require "worona"

local function registerService( params )

	worona[ params.service ] = params.creator()

end
worona:add_action( "register_service", registerService )


local function extendService( params )
	
	local service = params.service

	if worona[ service ] == nil then
		worona[ service ] = params.object
	else
		for k, v in pairs( params.object ) do
			worona[service][k] = v
		end
	end
end
worona:add_action( "extend_service", extendService )