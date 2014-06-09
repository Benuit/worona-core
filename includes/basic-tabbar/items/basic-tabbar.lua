local worona = require "worona"
local composer = require "composer"

local basic_tabbar

local function attachTabBar( params )

	local pages = {
		{ page_type = "customcontent", page_id = 4911 },
		{ page_type = "customcontent", page_id = 4831 },
		{ page_type = "customcontent", page_id = 4861 },
		{ page_type = "customcontent", page_id = 4901 },
		{ page_type = "customcontent", page_id = 5841 }
	}

	basic_tabbar = worona.ui:newBasicTabBar({ pages = pages })
	
	if params ~= nil and params.sceneGroup ~= nil then
		params.sceneGroup:insert( basic_tabbar )
	end
end

return attachTabBar

