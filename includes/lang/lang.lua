local worona = require "worona"

local function newLangService()
	local lang = {}

	--: private variables
	local lang_list = {}
	local device_lang = system.getPreference( "locale", "language" ) or "en"

	--[[	
		lang:load 
		
		Loads a lang file to be used in the plugin "plugin_name"
		 	
		@type: service
		@date: 06/2014
		@since: 0.6
	
		@param: path = path of the lang file, plugin_name = name of the plugin where lang file will be used.
		@return: -
	
		@example: worona.lang:load("worona-core.includes.scene-list.lang.scene-list-lang", "scene-list")
	]]--
	function lang:load( path, plugin_name )

		local plugin_lang_table

		--: get the name of the file
		local filename = string.match( path, '.*%.(.*)$' )
		
		--: try the require of content/lang/, in a pcall to catch the ERROR
		if pcall( function() plugin_lang_table = require( "content.lang." .. filename ) end ) then
			worona.log:info( "Lang: Require of content.lang." .. filename .. " succeed." )
		else
			worona.log:info( "Lang: Require of content.lang." .. filename .. " failed. Loading " .. path .. " instead." )
			plugin_lang_table = require( path )
		end

		lang_list[ plugin_name ] = plugin_lang_table
	end
	--[[	
		lang:get 
		
		Looks for the "string" field in the lang file associated to the plugin_name, and returns the text
		associated with that field in the correct language. 
		To chose which language	should be returned, the function does:
		- 1st tries to return the device language, if it exists in the lang file
		- 2nd tries to return english, if it exists in the lang file
		- 3rd returns any language available in the lang file.
		If "string" is not found in the lang file, the function returns " ... "
		IMPORTANT: before using this function you have to load a lang file for the plugin where
		it is going to be used using the function lang:load.
		 	
		@type: service
		@date: 06/2014
		@since: 0.6
	
		@param: string = field which is going to be looked for in the lang file,
				plugin_name = plugin to which the lang file you are using is associated.
		@return: text in appropiated language, or " ... " if there was an error.
	
		@example: local text = worona.lang:get("popup1_title", "scene-list")
	]]--	
	function lang:get( string, plugin_name )
		--: returns the device language, if it exists
		if lang_list[ plugin_name ][ string ][ device_lang ] ~= nil then
			if type(lang_list[ plugin_name ][ string ][ device_lang ])=="string" then
				return lang_list[ plugin_name ][ string ][ device_lang ]
			else
				worona.log:error("lang.lua/get: 1. lang_list[ plugin_name ][ string ][ device_lang ] value is not a string")
				return " ... "
			end
		--: returns the english language, if it exists
		elseif lang_list[ plugin_name ][ string ][ "en" ] ~= nil then
			if type(lang_list[ plugin_name ][ string ][ "en" ])=="string" then
				return lang_list[ plugin_name ][ string ][ "en" ]
			else
				worona.log:error("lang.lua/get: 2. lang_list[ plugin_name ][ string ][ \"en\" ] value is not a string")
				return " ... "
			end
		--: returns any language
		else
			for k, v in pairs( lang_list[ plugin_name ][ string ] ) do
				if type(v)=="string" then
					return v
				else
					worona.log:error("lang.lua/get: 3. v value is not a string")
					return " ... "
				end
			end
		end
	end

	return lang
end
worona:do_action( "register_service", { service = "lang", creator = newLangService } )