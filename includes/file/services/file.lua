local worona = require "worona"

local function newFileService()

	local file = {}

	function file:isFolder( file_or_folder )

		local file_type = string.match(file_or_folder, "\.[0-9a-zA-Z]+$")
		if file_type == file_or_folder then
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
		
		local base_directory = base_directory or system.DocumentsDirectory
		local lfs = require "lfs"

		if base_directory ~= system.DocumentsDirectory and base_directory ~= system.TemporaryDirectory then
			worona.log:error("utils/createFolders: base_directory should be system.DocumentsDirectory or system.TemporaryDirectory ")
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
		--. 	target_baseDirectory      = system.DocumentsDirectory or system.TemporaryDirectoy
		--. 	listenerFunction          = the listener function
	function file:download( options )

		options.target_baseDirectory = options.target_baseDirectory or system.DocumentsDirectory

		options.method = options.method or "GET"

		if options.target_baseDirectory ~= system.DocumentsDirectory and options.target_baseDirectory ~= system.TemporaryDirectory then
			worona.log:error("utils/downloadFile: options.target_baseDirectory should be system.DocumentsDirectory or system.TemporaryDirectory ")
			return
		end


		local isPath = worona.string:split( options.target_file_name_or_path, "/")
		local targetFilePath

		--. Check if options.target_file_name_or_path is a file name or a file path .--
		if #isPath == 1 then --. is file name .--
			targetFilePath = ""
			worona.log:debug("utils/downloadFile: is file name")
		elseif #isPath > 1 then  --. is file path .--
			targetFilePath = options.target_file_name_or_path
			worona.log:debug("utils/downloadFile: is path")
		else
			worona.log:fatal("utils/downloadFile: options.target_file_name_or_path = #" .. options.target_file_name_or_path)
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

		worona.log:debug("utils/downloadFile: folderString = #" .. folderString)
		worona.log:debug("utils/downloadFile: targetFilePath = #" .. targetFilePath)

		local folderCreated = file:createFolder( folderString, options.target_baseDirectory)

		if folderCreated ~= -1 then

			worona.log:debug("utils/downloadFile: download method is GET - URL = #" .. options.url)

			local params = {}
		    params.progress = true

			network.download( 
				options.url, 
				options.method, 
				options.listenerFunction, 
				params,
				targetFilePath, 
				options.target_baseDirectory )	
		end	
	end	


	function file:locateFileBaseDirectory ( file_path )

		local system_path
		local base_directory = nil
		local file_exists = nil
		
		if file_path ~= nil then
			--. First we check in system.TemporaryDirectory
			system_path = system.pathForFile( file_path, system.TemporaryDirectory ) 
			
			file_exists = io.open(system_path, "r")
			
			if file_exists ~= nil then
				io.close(file_exists)
				base_directory = system.TemporaryDirectory
				
			else  --. If the file is not there, we check in system.DocumentsDirectory
				system_path = system.pathForFile( file_path, system.DocumentsDirectory )

				file_exists = io.open(system_path, "r")
				
				if file_exists ~= nil then
					io.close(file_exists)
					base_directory = system.DocumentsDirectory
					
				else  --. If the file is not there, we check in system.ResourceDirectory
					system_path = system.pathForFile( file_path, system.ResourceDirectory )
					if system_path then  --. If base_directory is system.ResourceDirectory and file does not exist, system.pathForFile returns nil .--
						base_directory = system.ResourceDirectory
					end
				end
			end

			return base_directory 
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
			
			--: io.open opens a file at path. returns nil if no file found :--
			local file = io.open( system_file_path, "r" )
			if file then
			   --: read all contents of file into a string :--
			   contents = file:read( "*a" )
			   io.close( file )	--: close the file after using it :--
			end
			
			return contents
		else
			return -1
		end
	end

	return file
end

return newFileService