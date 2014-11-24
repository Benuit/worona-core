local worona = require "worona"

worona:do_action( "register_service", { service = "local_options", creator = require("worona-core.includes.proxies.newJsonProxy") } )

worona:add_action( "init", function() worona.local_options:read("content/json/local_options.json") end, 9 )