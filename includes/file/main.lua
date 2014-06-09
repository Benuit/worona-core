local worona = require "worona"

worona:do_action( "register_service", { service = "file", creator = require("worona.includes.file.services.file") } )