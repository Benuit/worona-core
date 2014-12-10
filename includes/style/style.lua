local worona = require "worona"

local function newStyleService()

	--: service table
	local style = {}

	--: private variables
	local registered_functions = {}
	local registered_style = {}

	--: private functions
	local function registerStyle( params )
		registered_functions[ params.style ] = params.creator
	end
	worona:add_action( "register_style", registerStyle )

	--: loads the style which is currently selected
	local function loadStyle( params )
		if type( registered_functions[ worona.current_style ] ) == "function" then
			registered_style = registered_functions[ worona.current_style ]()
		else
			worona.log:warning("Style: the style '" .. worona.current_style .. "' couldn't be loaded." )
		end
	end
	worona:add_action( "load_style", loadStyle)
	

	--: public methods
	function style:set( new_style )
		worona.current_style = new_style
	end

	function style:get( class )
		if registered_style[ class ] ~= nil then
			return registered_style[ class ]
		else
			return nil
		end
	end

	function style:getSetting( array )
		--: Accepts: 	iphone3, iphone4, iphone5, iphone
		--:				ipadnormal, ipadretina, ipad
		--:				ios8, ios7, ios6, ios
		--:
		--: 			android5, android8, android10, android
		--:
		--:				screen5, screen8, screen10, default
		--: & landscape:
		--:				iphone3_l, iphone4_l, iphone5_l, iphone_l
		--:				ipadnormal_l, ipadretina_l, ipad_l
		--:				ios7_l, ios6_l, ios_l
		--:
		--: 			android5_l, android8_l, android10_l, android_l
		--:
		--:				screen5_l, screen8_l, screen10_l, default_l
		
		local value
		local device          = worona.device:getDevice()
		local platformVersion = worona.device:getPlatformVersion()
		local orientation

		if worona.device:getOrientation() == "landscape" then
			orientation = "_l"
		else
			orientation = ""
		end

		if device == "iphone3"
		or device == "iphone4"
		or device == "iphone5"
		or device == "iphone6"
		or device == "iphone6plus" then
				value = array[device .. orientation] 
					 or array[device]
					 or array["screen5" .. orientation]
					 or array["screen5"]
					 or array["iphone" .. orientation]
					 or array["iphone"]
					 or array[platformVersion .. orientation]
					 or array[platformVersion]
					 or array["ios" .. orientation]
					 or array["ios"]
					 or array["default" .. orientation]
					 or array["default"]
					 or false
		elseif device == "ipadnormal"
			or device == "ipadretina" then
				value = array[device .. orientation] 
					 or array[device]
					 or array["screen10" .. orientation]
					 or array["screen10"]
					 or array["ipad" .. orientation]
					 or array["ipad"]
					 or array[platformVersion .. orientation]
					 or array[platformVersion]
					 or array["ios" .. orientation]
					 or array["ios"]
					 or array["default" .. orientation]
					 or array["default"]
					 or false
		elseif device == "android5" then
				value = array[device .. orientation] 
					 or array[device]
					 or array["screen5" .. orientation]
					 or array["screen5"]
					 or array[platformVersion .. orientation]
					 or array[platformVersion]
					 or array["android" .. orientation]
					 or array["android"]
					 or array["default" .. orientation]
					 or array["default"]
					 or false	
		elseif device == "android8" then
				value = array[device .. orientation] 
					 or array[device]
					 or array["screen8" .. orientation]
					 or array["screen8"]
					 or array[platformVersion .. orientation]
					 or array[platformVersion]
					 or array["android" .. orientation]
					 or array["android"]
					 or array["default" .. orientation]
					 or array["default"]
					 or false
		elseif device == "android10" then
				value = array[device .. orientation] 
					 or array[device]
					 or array["screen10" .. orientation]
					 or array["screen10"]
					 or array[platformVersion .. orientation]
					 or array[platformVersion]
					 or array["android" .. orientation]
					 or array["android"]
					 or array["default" .. orientation]
					 or array["default"]
					 or false
		else
			value = false
		end

		return value
	end

	return style
end
worona:do_action( "register_service", { service = "style", creator = newStyleService } )