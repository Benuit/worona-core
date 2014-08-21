local worona = require "worona"

local htmlRender = {}

local folders_created = false
local files_copied    = false

local function createFolders()
	if folders_created == false then
		worona.file:createFolder( "content/html", system.DocumentsDirectory )
		worona.file:createFolder( "content/html/css", system.DocumentsDirectory )
		worona.file:createFolder( "content/html/js", system.DocumentsDirectory )
		worona.file:createFolder( "content/html/js/vendor", system.DocumentsDirectory )
		folders_created = true
	end
end

local function copyFiles()
	if files_copied == false then
		worona.file:copyFile( "worona/includes/scene-post/html/css/main.css.txt", system.ResourcesDirectory, "content/html/css/main.css", system.DocumentsDirectory )
		worona.file:copyFile( "worona/includes/scene-post/html/css/normalize.css.txt", system.ResourcesDirectory, "content/html/css/normalize.css", system.DocumentsDirectory )
		worona.file:copyFile( "worona/includes/scene-post/html/js/main.js.txt", system.ResourcesDirectory, "content/html/js/main.js", system.DocumentsDirectory )
		worona.file:copyFile( "worona/includes/scene-post/html/js/plugins.js.txt", system.ResourcesDirectory, "content/html/js/plugins.js", system.DocumentsDirectory )
		worona.file:copyFile( "worona/includes/scene-post/html/js/vendor/jquery-1.11.1.min.js.txt", system.ResourcesDirectory, "content/html/js/vendor/jquery-1.11.1.min.js", system.DocumentsDirectory )
		worona.file:copyFile( "worona/includes/scene-post/html/js/vendor/modernizr-2.8.0.min.js.txt", system.ResourcesDirectory, "content/html/js/vendor/modernizr-2.8.0.min.js", system.DocumentsDirectory )
		files_copied = true
	end
end

local function copyHtml( filename, html )
	
	local headerPath = system.pathForFile( "worona/includes/scene-post/html/header.html.txt", system.ResourceDirectory )
	local headerFile = io.open( headerPath, "r" )
	local headerData = headerFile:read( "*a" )
	headerFile:close()

	local footerPath = system.pathForFile( "worona/includes/scene-post/html/footer.html.txt", system.ResourceDirectory )
	local footerFile = io.open( footerPath, "r" )
	local footerData = footerFile:read( "*a" )
	footerFile:close()

	local htmlPath = system.pathForFile( "content/html/" .. filename .. ".html", system.DocumentsDirectory )
	local htmlFile = io.open( htmlPath, "w" )
	htmlFile:write( headerData .. html .. footerData )
	htmlFile:close()
end

function htmlRender:prepareHtmlFile( options )
	createFolders()
	copyFiles()
	copyHtml( options.name, options.html )
end

return htmlRender