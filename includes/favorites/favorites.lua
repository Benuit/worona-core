--[[
Extension Name: Favorite Posts
Extension URI:
Description: enables users to mark posts as favorites.
Version: 0.8
Compatible with: worona-mobile-app-0.6.6 and above.
Author: Worona
Author URI: http://www.worona.org/
Copyright: Worona
]]--


local worona = require "worona"
local config = require "worona-core.includes.favorites.config"
 
local function newFavoriteService()

	local fav = {}

	--[[.	
		addOrRemoveFavorite 
		
		If this function is called with a post_id, it will add or remove the post from the favorites list
		depending on the previous state of that post with id post_id.
		 	
		@type: service
		@date: 02/15
		@since: 0.6.8
	
		@param: params.post_id
		@return: -
	
		@example: worona.favorite:addOrRemoveFavorite( { post_id = 123 } )
	]]--
	function fav:addOrRemoveFavorite( params )

		if fav:isFavorite( params ) == false then
			worona.local_options:addValue( "favorite_posts", params.post_id )
		else
			worona.local_options:removeValue( "favorite_posts", params.post_id )
		end
	end

	--[[.	
		isFavorite 
		
		Returns true if a post is in the favorites list. False if not.
		 	
		@type: service
		@date: 02/15
		@since: 0.6.8
	
		@param: params.post_id
		@return: true/false
	
		@example: worona.favorite:isFavorite( { post_id = 123 } )
	]]--
	function fav:isFavorite( params )

		local favorite_posts_array = worona.local_options:get( "favorite_posts" )

		if favorite_posts_array ~= nil then
			if type(favorite_posts_array) == "table" then
				for i = 1, #favorite_posts_array do
					if params.post_id == favorite_posts_array[i] then
						return true
					end
				end
			elseif params.post_id == favorite_posts_array then
				return true
			end
		end

		return false
	end
	
   	return fav
end
worona:do_action( "register_service", { service = "favorite", creator = newFavoriteService } )

local function filterFavoriteIcon( image, params )
	
	if worona.favorite:isFavorite( { post_id = params.post_id } ) == true then
		return "is_favorite"
	else
		return "favorite"
	end
end
worona:add_filter( "filter_navbar_favorite_icon", filterFavoriteIcon )
