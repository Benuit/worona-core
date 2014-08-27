local worona = require "worona"

local function newDateService()

	date = {}

	--[[	
		convertDateToTimestamp 
		
		Converts dates from: "Monday, 20/03/2014 14:43:32 GMT" to Unix Timestamp
		 	
		@type: service
		@date: 06/2014
		@since: 0.6
	
		@param: dateString -> "Monday, 20/03/2014 14:43:32 GMT"
		@return: unixTimeStamp (int)		
	
		@example: local time_stamp = worona.convertDateToTimestamp("Monday, 20/03/2014 14:43:32 GMT")
	]]--
	function date:convertDateToTimestamp( dateString )

		local stringParameters="%a+, (%d+) (%a+) (%d+) (%d+):(%d+):(%d+) (%a+)"
		local day, month, year, hour, min, sec, tz = dateString:match(stringParameters)
		local MON={Jan=1, Feb=2, Mar=3, Apr=4, May=5, Jun=6, Jul=7, Aug=8, Sep=9, Oct=10, Nov=11, Dec=12}
		month=MON[month]

		local unixTimestamp = os.time({tz=tz, day=day, month=month, year=year, hour=hour, min=min, sec=sec})

		--. A-HACK!
		if unixTimestamp == nil then
			unixTimestamp = 0
		end

		return unixTimestamp
	end

	--[[	
		convertTimestampToDate 
		
		Converts unixTimesTamp to: "Monday, 20/03/2014 14:43:32 GMT"
		 	
		@type: service
		@date: 06/2014
		@since: 0.6
	
		@param: unixTimestamp (int)
		@return: dateString (Ex: "Monday, 20/03/2014 14:43:32 GMT")	
	
		@example: local time_stamp = worona.convertTimestampToDate(15464612)
	]]--
	function date:convertTimestampToDate ( unixTimestamp )
		local date = os.date("*t", unixTimestamp);
		
		local MON={"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
		local WDAY = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}

		local dateString = WDAY[date.wday] .. ", " .. date.day .. " " .. MON[date.month] .. " " .. date.year .. " " .. date.hour.. ":" .. date.min.. ":" .. date.sec .. " GMT"

		return dateString
	end

	--[[	
		convertWpDateToTimestamp 
		
		Converts dates from WordPress format: "2014-03-20T14:43:32 GMT" to Unix Timestamp
		 	
		@type: service
		@date: 06/2014
		@since: 0.6
	
		@param: dateString -> "2014-03-20T14:43:32 GMT"
		@return: unixTimeStamp (int)		
	
		@example: local time_stamp = worona.convertWpDateToTimestamp("2014-03-20T14:43:32 GMT")
	]]--
	function date:convertWpDateToTimestamp( dateString )

		local stringParameters="([0-9]+)-([0-9]+)-([0-9]+)T([0-9]+):([0-9]+):([0-9]+)"
		local year, month, day, hour, min, sec, aux1, aux2, aux3, aux4 = dateString:match(stringParameters)
		

		local unixTimestamp = os.time({tz="GMT", day=day, month=month, year=year, hour=hour, min=min, sec=sec})

		--. A-HACK!
		if unixTimestamp == nil then
			unixTimestamp = 0
		end

		return unixTimestamp
	end

	return date
end

worona:do_action( "register_service", { service = "date", creator = newDateService } )