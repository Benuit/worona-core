local worona = require "worona"

worona:do_action( "register_service", { service = "date", creator = require("worona.includes.date.services.date") } )