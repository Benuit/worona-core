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

    function that:append ( field, value )

        for k,v in pairs(value) do 
            data[field][k] = v
        end
    end

    return that

end

return newJsonProxy