local worona = require "worona"

local function newFileService()

	local file = {}

	--. Returns true if "file_or_folder" is a folder, and false if its a file.
	function file:isFolder( file_or_folder )

		local dot_in_file = string.match(file_or_folder, "%.")
		if dot_in_file == nil then
			return true
		end
		return false
	end

	--. Creates a or various folders in base_directory  (previously known as createDirectory).--
		--. RETURN: true if success, -1 if error
		--. ARGUMENTS:
		--. 	folder_path    = path for the directory to be created
		--. 	base_directory = target Base Directory (Documents or Temporary)
	function file:createFolder( folder_path, base_directory )

		local base_directory = base_directory or system.CachesDirectory
		local lfs = require "lfs"

		if base_directory ~= system.CachesDirectory and base_directory ~= system.TemporaryDirectory and base_directory ~= system.DocumentsDirectory then
			worona.log:error("file/createFolder: base_directory should be system.CachesDirectory or system.TemporaryDirectory ")
			return -1
		end

		--. Store the folders names in an array .--
		local folder_array = worona.string:split(folder_path, "/")

		local function newFolder ( name, base )
			local success = lfs.chdir( base )
			local newFolderPath

			if success == true then
				--. First we check if the folder exists .--
				local folderExists = lfs.chdir ( name )
				if folderExists == true then
					newFolderPath = lfs.currentdir()
				else
					lfs.mkdir( name )
					newFolderPath = lfs.currentdir() .. "/" .. name
				end
				return newFolderPath
			else
				return -1
			end
		end

		--. get raw path to app's base_directory
		local basePath = system.pathForFile( "", base_directory )

		for i=1, #folder_array do
			if file:isFolder(folder_array[i]) == true then
				basePath = newFolder(folder_array[i], basePath)
			end
		end

		if basePath ~= -1 then
			return true
		else
			return -1
		end
	end

	--. Downloads a file from an URL Address and stores it in the options.target_file_name_or_path in target_baseDirectory .--
		--. RETURN: -
		--. ARGUMENTS:
		--. 	url                       = URL
		--.  	target_file_name_or_path  = name of the file file will be stored.
		--. 	method                    = "GET" or "HEAD"
		--. 	target_baseDirectory      = system.CachesDirectory or system.TemporaryDirectoy
		--. 	listenerFunction          = the listener function
	function file:download( options )

		options.target_baseDirectory = options.target_baseDirectory or system.CachesDirectory

		options.method = options.method or "GET"

		if options.target_baseDirectory ~= system.CachesDirectory and options.target_baseDirectory ~= system.TemporaryDirectory then
			worona.log:error("file:download - options.target_baseDirectory should be system.CachesDirectory or system.TemporaryDirectory ")
			return
		end


		local isPath = worona.string:split( options.target_file_name_or_path, "/")
		local targetFilePath

		--. Check if options.target_file_name_or_path is a file name or a file path .--
		if #isPath == 1 then --. is file name .--
			targetFilePath = ""
		elseif #isPath > 1 then  --. is file path .--
			targetFilePath = options.target_file_name_or_path
		else
			worona.log:fatal("file:download - options.target_file_name_or_path = '" .. options.target_file_name_or_path .. "'")
		end

		--. Create the directory where the file is going to be placed. .--
		local folderArray = worona.string:split( targetFilePath, "/")
		local folderString = ""

		for i = 1, #folderArray - 1 do
			folderString = folderString .. folderArray[i]
			if i < #folderArray - 1 then
				folderString = folderString .. "/"
			end
		end
		worona.log:info("file:download - Downloading '" .. targetFilePath .. "'")

		local folderCreated = file:createFolder( folderString, options.target_baseDirectory)

		if folderCreated ~= -1 then

			worona.log:info("file:download - download method is GET - URL = '" .. options.url .. "'")

			local params = {}
		    params.progress = true
		    params.timeout = 10
		    --params.header   = { ["Cache-Control"] = "no-cache, no-store, must-revalidate", Pragma = "no-cache", Expires = 0 }

			network.download(
				options.url,
				options.method,
				options.listenerFunction,
				params,
				targetFilePath,
				options.target_baseDirectory )
		end
	end

	--. Returns the base directory of a file located in "file_path"
	function file:locateFileBaseDirectory ( file_path )

		local system_path
		local file_exists

		if file_path ~= nil then
			--. First we check in system.TemporaryDirectory
			system_path = system.pathForFile( file_path, system.TemporaryDirectory )
			file_exists = io.open(system_path, "r")

			if file_exists ~= nil then
				io.close(file_exists)
				return system.TemporaryDirectory

			else  --. If the file is not there, we check in system.CachesDirectory
				system_path = system.pathForFile( file_path, system.CachesDirectory )
				file_exists = io.open(system_path, "r")
				if file_exists ~= nil then
					io.close(file_exists)
					return system.CachesDirectory
				else  --. If the file is not there, we check in system.ResourceDirectory
					system_path = system.pathForFile( file_path, system.ResourceDirectory )
					if system_path ~= nil then
						file_exists = io.open(system_path, "r")
						if file_exists ~= nil then  --. If base_directory is system.ResourceDirectory and file does not exist, system.pathForFile returns nil .--
							return system.ResourceDirectory
						end
					end
				end
			end
		end

		return -1  --. if file DOES NOT EXIST, return -1
	end

	--. Returns content as a string from a file .--
		--. RETURN: content as a string
		--. ARGUMENTS:
		--. 	file_path: path of the file.
	function file:getFileContent( file_path )

		local base_directory = file:locateFileBaseDirectory( file_path )
		local system_file_path

		if base_directory ~= -1 and file_path ~= -1 then
			--: create a file path for corona i/o :--
			system_file_path = system.pathForFile( file_path, base_directory )

			--: will hold contents of file :--
			local contents

			if system_file_path ~= nil then
				--: io.open opens a file at path. returns nil if no file found :--
				local file = io.open( system_file_path, "r" )
				if file then
				   --: read all contents of file into a string :--
				   contents = file:read( "*a" )
				   io.close( file )	--: close the file after using it :--
				end

				return contents
			end
		end

		return -1
	end

	--. Copies file "srcName" located in "srcPath" path to destination "dstName" located in "dstPath"
	function file:copyFile( srcName, srcPath, dstName, dstPath, overwrite )

	        -- assume no errors
	        local results = true

	        -- Copy the source file to the destination file
	        local rfilePath = system.pathForFile( srcName, srcPath )
	        local wfilePath = system.pathForFile( dstName, dstPath )

	        local rfh = io.open( rfilePath, "rb" )
	        local wfh = io.open( wfilePath, "wb" )

	        if  not wfh then
	                print( "writeFileName open error!")
	                results = false
	        else
	                -- Read the file from the Resource directory and write it to the destination directory
	                local data = rfh:read( "*a" )
	                if not data then
	                    print( "read error!" )
	                    results = false     -- error
	                else
	                    if not wfh:write( data ) then
	                        print( "write error!" )
	                        results = false -- error
	                    end
	                end
	        end

	        -- Clean up our file handles
	        rfh:close()
	        wfh:close()
	        return results
	end

	return file
end

worona:do_action( "register_service", { service = "file", creator = newFileService } )
