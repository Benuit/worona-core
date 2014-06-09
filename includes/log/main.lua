local worona = require "worona"

worona:do_action( "register_service", { service = "log", creator = require("worona.includes.log.services.log") } )