local worona = require "worona"

local function newLogService()

	local log = {}

	local lfs = require "lfs"

	-- private variables
	local consoleEnabled = false
	local fileEnabled    = false

	local fileObj
	local logLevelNum    = 3 -- default is WARNING
	local indent         = 0
	local single_space   = "   "
	local total_spaces   = ""
	local isWin          = false


	local function getTime ()

	-- Gets the time to be printed on the log message

		local date = os.date( "*t" )

		return date.day .. "/" .. date.month .."/" .. date.year .. " - " .. date.hour .. ":" .. date.min .. ":" .. date.sec
	end

	
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
	

	function log:start( options )
		
		if system.getInfo("platformName") == "Win" then
			--. ONLY IMPORTANT FOR SIMULATOR
			isWin = true
		end

		if options.console == true then
			consoleEnabled = true
		end

		log:setLevel( options.level )

		if options.file ~= nil and options.file ~= false then
			fileEnabled = true

			local folderPath = newFolder( "logs", system.pathForFile("", system.CachesDirectory) )
			local filePath = "logs/" .. options.file .. ".json"
			local fileSystemPath = system.pathForFile( filePath, system.CachesDirectory )

			if options.previous_file ~= nil and options.previous_file ~= false then
				local previous_filePath = "logs/" .. options.previous_file .. ".json"
				local previous_fileSystemPath = system.pathForFile(previous_filePath,system.CachesDirectory)
				
				local removeResults, removeReason = os.remove( previous_fileSystemPath )

				--. Copy previous session file to this session previous_file
				local fileObjTemp = io.open(fileSystemPath, "r" )
				if fileObjTemp ~= nil then
					local fileTemp_content = fileObjTemp:read("*a")
					io.close(fileObjTemp)
					fileObjTemp = io.open( previous_fileSystemPath, "w" )
					fileObjTemp:write(fileTemp_content)
					io.close(fileObjTemp)
				else
					fileObjTemp = io.open( previous_fileSystemPath, "w" )
					io.close(fileObjTemp)
				end
			end
			
			if options.reset_log == true then
				fileObj = io.open( fileSystemPath, "w" )
				fileObj:setvbuf("no")
				fileObj:write( options.file .. " = [{ \"level\":\"[INFO]\",\"msg\":\"LOG START\",\"indent\":0,\"date\":\"" .. getTime() .. "\" }];")
			else
				fileObj = io.open( fileSystemPath, "r" )
				local file_content = fileObj:read("*a")
				io.close(fileObj)
				fileObj = io.open( fileSystemPath, "w" )
				fileObj:setvbuf("no")
				if file_content == "" then
					fileObj:write( options.file .. " = [{ \"level\":\"[INFO]\",\"msg\":\"LOG START\",\"indent\":0,\"date\":\"" .. getTime() .. "\" }];")
				else
					fileObj:write(file_content)
					local pos = fileObj:seek("end", -2) 
					fileObj:write(",{ \"level\":\"[INFO]\",\"msg\":\"LOG START\",\"indent\":0,\"date\":\"" .. getTime() .. "\" }];")		
				end
			end
		end
	end

	function log:stop()
		-- close the file
		if fileObj ~= nil then
			io.close(fileObj)
		end

		-- stop outputing values until restarted
		consoleEnabled = false
		fileEnabled    = false
	end

	function log:setLevel ( level )

		local levelNames = { INFO = 1, DEBUG = 2, WARNING = 3, ERROR = 4, FATAL = 5 }

		logLevelNum = levelNames[ level ] or 3
	end

	function log:setConsole( bool )
		consoleEnabled = bool
	end

	function log:setFile( bool )
		fileEnabled = bool
	end

	local function applyIndent()
	
		total_spaces = ""

		for i=1, indent do
			total_spaces = total_spaces .. single_space
		end
	end

	function log:addIndent()
		indent = indent + 1
		applyIndent()
	end

	function log:removeIndent()
		indent = indent - 1
		if indent < 0 then
			indent = 0
		end
		applyIndent()
	end


	local function logMessage (msg , level)

	-- Prints the logging message into the selected output ("CONSOLE", "FILE")

		if consoleEnabled == true then

			print ( total_spaces .. level .. ": " .. tostring(msg) )

			if isWin == true then
				io.flush()
			end
		end

		if fileEnabled == true then

			local pos = fileObj:seek("end", -2)   
		    fileObj:write(",{ \"level\":\"" .. level .."\",\"msg\":\"" .. tostring(msg) .. "\",\"indent\":" .. indent .. ",\"date\":\"" .. getTime() .. "\" }];")
		end
	end


	function log:info (msg)
		if 1 >= logLevelNum then
			logMessage(msg, "[INFO]")
		end
	end


	function log:debug (msg , doubleSpace)
		if 2 >= logLevelNum then
			logMessage(msg, "[DEBUG]")
		end
	end


	function log:warning (msg, doubleSpace)
		if 3 >= logLevelNum then
			logMessage(msg, "[WARNING]")
		end
	end

	
	function log:error (msg, doubleSpace)
		if 4 >= logLevelNum then
			logMessage(msg, "[ERROR]")
		end
	end


	function log:fatal (msg, doubleSpace)
		if 5 >= logLevelNum then
			logMessage(msg, "[FATAL]")
		end
	end


	return log		
end

worona:do_action( "register_service", { service = "log", creator = newLogService } )