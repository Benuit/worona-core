local worona = require "worona"

worona:do_action( "register_service", { service = "style", creator = require("worona.includes.style.services.style") } )