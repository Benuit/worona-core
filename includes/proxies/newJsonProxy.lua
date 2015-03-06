local worona = require "worona"
local json   = require "json"

local function newJsonProxy()
    
    local that = {}
    
    local data, file_path

    function that:save( target_file_path )

        if target_file_path == nil and file_path ~= nil then 
            target_file_path = file_path
        end

        worona.file:createFolder( target_file_path , system.CachesDirectory )

        local file = io.open( system.pathForFile( target_file_path, system.CachesDirectory ), "w" )

        if file ~= nil then
            file:write( json.encode( data ) )
            io.close( file )
            return true
        end
        
        worona.log:error("newJsonProxy/save: File '" .. target_file_path .. "' cannot be oppened")
        return -1
    end

    function that:read ( json_file_path )

        file_path = json_file_path --. file_path is a local value above!
        local json_content = worona.file:getFileContent( json_file_path )
        
        if json_content ~= -1 then
            data = json.decode( json_content )
            worona.log:info( "newJsonProxy/read: Json File '" .. json_file_path .. "' read succesfully." )
            return true
        else
            worona.log:info( "newJsonProxy/read: Json File '" .. json_file_path .. "' can't be read." )
            return -1
        end
    end

    function that:get ( field )

    	return data[ field ]
    end

    function that:set ( field, value )

        -- if data is a table and we are passing a table, join them, don't destroy the previous table
        if type(data[field]) == "table" and type(value) == "table" then
            that:append( field, value )
        else
            data[ field ] = value
        end

        that:save()
    end

    --. Adds a value to an array of values in the designated field, ie: "favorite_posts" = {45, 23, 87, value} .--
    	--. RETURN: -
    	--. ARGUMENTS: 
    	--. 	field: name of the field in the json file.
    	--. 	value: (number or string) value to add to the array.
    function that:addValue ( field, value )

    	local previous_values = data[field]
    
    	if type(value) ~= "string" and type(value) ~= "number" then
    		worona.log:error("newJsonProxy/addValue: string or number expected, got " .. type(value))
    		return -1
    	else

	        if previous_values == nil then
	            data[field] = value
	    	elseif type(previous_values) ~= "table" then
	    		local values_array = { previous_values, value }
	    		that:set( field, values_array )
	    	else
	    		previous_values[#previous_values + 1] = value
	    		that:set( field, previous_values )
    		end
        end

        that:save()
    end


    --. Adds a value to an array of values in the designated field, ie: "favorite_posts" = {45, 23, 87, value} .--
    	--. RETURN: -
    	--. ARGUMENTS: 
    	--. 	field: name of the field in the json file.
    	--. 	value: (number or string) value to add to the array.
    function that:removeValue ( field, value )

    	local previous_values = data[field]
    
    	if type(value) ~= "string" and type(value) ~= "number" then
    		worona.log:error("newJsonProxy/removeValue: string or number expected, got " .. type(value))
    		return -1
    	else
    		if type(previous_values) == "table" then
		        for i=1, #previous_values do
		         	if previous_values[i] == value then
		         		table.remove( data[field], i )
		         		break
		         	end
	        	end
	        elseif previous_values == value then
	        	data[field] = nil
	        end
        end

        that:save()
    end


    function that:append ( field, value )

        for k,v in pairs(value) do 
            data[field][k] = v
        end
    end

    return that

end

return newJsonProxy