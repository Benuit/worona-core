local worona = require "worona"
require "worona-core.includes.scene-post.html-filters"

local htmlRender = {}

function htmlRender:prepareHtmlFile( options )

	--: create the folder to store htmls files
	worona.file:createFolder( "content/html", system.CachesDirectory )

	--: read all needed files

	local header_1_Path = system.pathForFile( "worona-core/includes/scene-post/html/header1.html.txt", system.ResourceDirectory )
	local header_1_File = io.open( header_1_Path, "r" )
	local header_1_Data = header_1_File:read( "*a" )
	header_1_File:close()

	local normalize_css_Path = system.pathForFile( "worona-core/includes/scene-post/html/css/normalize.css.txt", system.ResourceDirectory )
	local normalize_css_File = io.open( normalize_css_Path, "r" )
	local normalize_css_Data = "<style>" .. normalize_css_File:read( "*a" ) .. "</style>"
	normalize_css_File:close()

	local main_css_Path = system.pathForFile( "worona-core/includes/scene-post/html/css/main.css.txt", system.ResourceDirectory )
	local main_css_File = io.open( main_css_Path, "r" )
	local main_css_Data = "<style>" .. main_css_File:read( "*a" ) .. "</style>"
	main_css_File:close()

	local modernizr_js_Path = system.pathForFile( "worona-core/includes/scene-post/html/js/vendor/modernizr-2.8.0.min.js.txt", system.ResourceDirectory )
	local modernizr_js_File = io.open( modernizr_js_Path, "r" )
	local modernizr_js_Data = "<script>" .. modernizr_js_File:read( "*a" ) .. "</script>"
	modernizr_js_File:close()

	local header_2_Path = system.pathForFile( "worona-core/includes/scene-post/html/header2.html.txt", system.ResourceDirectory )
	local header_2_File = io.open( header_2_Path, "r" )
	local header_2_Data = header_2_File:read( "*a" )
	header_2_File:close()

	local footer_1_Path = system.pathForFile( "worona-core/includes/scene-post/html/footer1.html.txt", system.ResourceDirectory )
	local footer_1_File = io.open( footer_1_Path, "r" )
	local footer_1_Data = footer_1_File:read( "*a" )
	footer_1_File:close()

	local footer_2_Path = system.pathForFile( "worona-core/includes/scene-post/html/footer2.html.txt", system.ResourceDirectory )
	local footer_2_File = io.open( footer_2_Path, "r" )
	local footer_2_Data = footer_2_File:read( "*a" )
	footer_2_File:close()

	local jquery_js_Path = system.pathForFile( "worona-core/includes/scene-post/html/js/vendor/jquery-1.11.1.min.js.txt", system.ResourceDirectory )
	local jquery_js_File = io.open( jquery_js_Path, "r" )
	local jquery_js_Data = "<script>" .. jquery_js_File:read( "*a" ) .. "</script>"
	jquery_js_File:close()

	local plugins_js_Path = system.pathForFile( "worona-core/includes/scene-post/html/js/plugins.js.txt", system.ResourceDirectory )
	local plugins_js_File = io.open( plugins_js_Path, "r" )
	local plugins_js_Data = "<script>" .. plugins_js_File:read( "*a" ) .. "</script>"
	plugins_js_File:close()

	--: get the device os
	local main_js_Name = "main.iphone.js.txt"
	if worona.device:getPlatformName() == "Android" then
		main_js_Name = "main.android.js.txt"
	end

	local main_js_Path = system.pathForFile( "worona-core/includes/scene-post/html/js/" .. main_js_Name, system.ResourceDirectory )
	local main_js_File = io.open( main_js_Path, "r" )
	local main_js_Data = "<script>" .. main_js_File:read( "*a" ) .. "</script>"
	main_js_File:close()

	local footer_2_Path = system.pathForFile( "worona-core/includes/scene-post/html/footer2.html.txt", system.ResourceDirectory )
	local footer_2_File = io.open( footer_2_Path, "r" )
	local footer_2_Data = footer_2_File:read( "*a" )
	footer_2_File:close()

	--: add filter for html
	local html = worona:do_filter("html_before_render", options.html, options.featured_image)

	--: write html
	local htmlPath = system.pathForFile( "content/html/" .. options.name .. ".html", system.CachesDirectory )
	local htmlFile = io.open( htmlPath, "w" )
	htmlFile:write( header_1_Data .. normalize_css_Data .. main_css_Data .. modernizr_js_Data .. header_2_Data .. jquery_js_Data .. plugins_js_Data .. main_js_Data .. html .. footer_1_Data .. footer_2_Data )
	htmlFile:close()
end

return htmlRender
