local worona = require "worona"

local function newLangService()
	local lang = {}

	--: private variables
	local lang_list = {}
	local device_lang = "es"--system.getPreference( "locale", "language" )

	--. Imports lang file .--
		--. RETURN: description
		--. ARGUMENTS: 
		--. 	Argument1: description
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