local worona = require "worona"

local function newDeviceService()

	device = {}

	device.PLATFORM_VERSION = nil--"8.0"

	function device:getOrientation()
		--: Return: portrait or landscape :--

		if system.orientation == "portrait" 
	   	or system.orientation == "portraitUpsideDown" then
	   		return "portrait"
	   	else
	   		return "landscape"
	   	end
	end

	function device:getPlatformName()
		local env = system.getInfo( "environment" )
		local model = system.getInfo( "model" )

		if env == "simulator" then
			if string.sub( model, 1 , 2 ) == "iP" then
				return "iPhone OS"
			else
				return "Android"
			end
		else
			return system.getInfo( "platformName" )
		end
	end

	function device:getInches()

		local env          = system.getInfo( "environment" )
		local model        = system.getInfo( "model" )
		local platformName = device:getPlatformName()
		local realInches   = {	["Droid"] = 3.7,
								["Nexus One"] = 3.7,
								["Sensation"] = 4.3,
								["Galaxy Tab"] = 7,
								["GT-I9300"] = 4.8,
								["Kindle Fire"] = 7,
								["KFTT"] = 7,
								["KFJWI"] = 9,
								["BNRV200"] = 6
							}

		
		if platformName == "iPhone OS" then				--: it's an iphone or ipad, no matter if simulator or not :--

			if model == "iPhone" or model == "iPhone Simulator" then
				if display.pixelHeight <= 960 then
					return 3.5
				else
					return 4
				end
			elseif model == "iPad" or model == "iPad Simulator" then
				return 10
			end
		
		elseif env == "simulator" then					--: it's an android inside the simulator :--
			
			if realInches[ model ] ~= nil then
				return realInches[ model ]
			else
				return 5
			end

		else 											--: it's an android device :--

			local widthInInches  = display.pixelWidth / system.getInfo("androidDisplayXDpi")
		    local heightInInches = display.pixelHeight / system.getInfo("androidDisplayYDpi")
		    return math.sqrt( widthInInches * widthInInches + heightInInches * heightInInches )
		end	
	end

	function device:getDevice()
		--: Return: iphone3, iphone4, iphone5, iphone6, iphone6plus, ipadnormal, ipadretina, android5, android8, android10 :--

		local platformName    = device:getPlatformName()
		local platformVersion = system.getInfo( "platformVersion" )
		local model           = system.getInfo( "model" )
		local screenInches    = device:getInches()
		

		if platformName == "iPhone OS" then
			if model == "iPad" or model == "iPad Simulator" then
				if display.pixelWidth <= 768 then
					return "ipadnormal"
				else
					return "ipadretina"
				end
			else
				if display.pixelHeight <= 480 then
					return "iphone3"
				elseif display.pixelHeight <= 960 then
					return "iphone4"
				elseif display.pixelHeight <= 1136 then
					return "iphone5"
				elseif display.pixelHeight <= 1334 then
					return "iphone6"
				else
					return "iphone6plus"
				end
			end
		else
			if screenInches <= 5 then
				return "android5"
			elseif screenInches <= 8 then
				return "android8"
			else
				return "android10"
			end
		end
	end

	function device:getPlatformVersion()

		local platformName    = device:getPlatformName()
		local platformVersion = device.PLATFORM_VERSION or system.getInfo( "platformVersion" )

		
		if platformName == "iPhone OS" and string.find( platformVersion, "8." ) == 1 then
		    return "ios8"
		elseif platformName == "iPhone OS" and string.find( platformVersion, "7." ) == 1 then
		    return "ios7"
		elseif platformName == "iPhone OS" and string.find( platformVersion, "6." ) == 1 then
		    return "ios6"
		elseif platformName == "iPhone OS" then
			return "ios"
		elseif string.find( platformVersion, "4." ) == 1 then
			return "android4"
		elseif string.find( platformVersion, "2." ) == 1 then
			return "android2"
		else
			return "android"
		end
	end

	return device
end

worona:do_action( "register_service", { service = "device", creator = newDeviceService } )