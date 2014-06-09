local worona = require "worona"

worona:do_action( "register_service", { service = "device", creator = require("worona.includes.device.services.device") } )