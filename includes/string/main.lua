local worona = require "worona"

worona:do_action( "register_service", { service = "string", creator = require("worona.includes.string.services.string") } )